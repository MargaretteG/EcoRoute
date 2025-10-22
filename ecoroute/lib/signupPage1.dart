import 'package:ecoroute/homePage.dart';
import 'package:ecoroute/login.dart';
import 'package:ecoroute/main_screen.dart';
import 'package:ecoroute/signupPage2.dart';
import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/custom_button.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:ecoroute/api_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class SignUpPage1 extends StatefulWidget {
  const SignUpPage1({super.key});

  @override
  State<SignUpPage1> createState() => _SignUpPage1State();
}

class _SignUpPage1State extends State<SignUpPage1> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  bool _obscurePassword = true;
  String nationality = '';
  String gender = '';
  String id = 'Passport';
  XFile? _selectedImage;

  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> idoptions = [
    'Passport',
    'Driver\'s License',
    'National ID',
  ];

  @override
  void initState() {
    super.initState();
    // Ensure everything is cleared when page is loaded
    _clearFields();
  }

  void _clearFields() {
    _usernameController.clear();
    _passwordController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _addressController.clear();
    _emailController.clear();
    _phoneController.clear();
    _dobController.clear();
    nationality = '';
    gender = 'Male';
    id = 'Passport';
    _selectedImage = null;
  }

  int _genderToInt(String g) {
    if (g.toLowerCase() == 'male') return 1;
    if (g.toLowerCase() == 'female') return 2;
    return 3;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    // Show a dialog to let the user choose between camera or gallery
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context); // Close the bottom sheet
                  final status = await Permission.camera.request();
                  if (status.isGranted) {
                    final XFile? pickedFile = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        _selectedImage = pickedFile;
                      });
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Camera permission denied')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final status = await Permission.photos.request();
                  if (status.isGranted) {
                    final XFile? pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        _selectedImage = pickedFile;
                      });
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gallery permission denied'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (nationality.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nationality is required')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = ApiService();

      // Pass validId and imageId only if they are provided
      final result = await api.signUp(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        address: _addressController.text.trim(),
        email: _emailController.text.trim(),
        phoneNum: _phoneController.text.trim(),
        nationality: nationality,
        dateBirth: _dobController.text.trim(),
        gender: gender,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        validId: (_selectedImage != null && id.isNotEmpty) ? id : null,
        imageId: _selectedImage != null
            ? File(_selectedImage!.path)
            : null, 
      );

      if (!mounted) return;

      final statusValue = result['status']?.toString().toLowerCase().trim();
      if (statusValue == 'success' ||
          statusValue == 'ok' ||
          statusValue == 'true') {
        // Navigate to login page after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      } else {
        // Show error message from API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Sign up failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF011901),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    Widget requiredTextField({
      required TextEditingController controller,
      required String label,
      TextStyle? style,
      InputDecoration? decoration,
      bool readOnly = false,
      bool obscureText = false,
    }) {
      return TextFormField(
        controller: controller,
        style: style,
        readOnly: readOnly,
        obscureText: obscureText,
        decoration:
            decoration ??
            InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(fontSize: 10, color: Colors.grey),
              hintText: label,
              hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
              border: const OutlineInputBorder(),
            ),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Input required' : null,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF011901),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  PreferredSize(
                    preferredSize: const Size.fromHeight(25),
                    child: AppBar(
                      backgroundColor: const Color(0xFF011901),
                      elevation: 0,
                      automaticallyImplyLeading: true,
                      iconTheme: const IconThemeData(color: Colors.white),
                    ),
                  ),
                  Container(
                    color: const Color(0xFF011901),
                    width: double.infinity,
                    child: Column(
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -23),
                          child: Image.asset(
                            'images/logo-green.png',
                            height: 80,
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -40),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -30),
                          child: const Text(
                            'You’re about to join a trusted travel community, \nso tell us a bit about yourself!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              height: 1.1,
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w100,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 5,
                    ),
                    child: Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: FractionallySizedBox(
                            widthFactor: 0.95,
                            child: Column(
                              children: [
                                requiredTextField(
                                  controller: _usernameController,
                                  label: 'Create Username',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    height: 1,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Create Username',
                                    labelStyle: TextStyle(fontSize: 13),
                                    border: OutlineInputBorder(),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                requiredTextField(
                                  label: 'Create Password',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    height: 1,
                                  ),
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'Create Password',
                                    labelStyle: TextStyle(fontSize: 13),
                                    border: const OutlineInputBorder(),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  obscureText: _obscurePassword,
                                ),

                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: requiredTextField(
                                        label: 'First Name:',
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          height: 1,
                                        ),
                                        controller: _firstNameController,
                                        decoration: const InputDecoration(
                                          labelText: 'First Name',
                                          labelStyle: TextStyle(fontSize: 13),
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: requiredTextField(
                                        label: 'Last Name',
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          height: 1,
                                        ),
                                        controller: _lastNameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Last Name',
                                          labelStyle: TextStyle(fontSize: 13),
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                requiredTextField(
                                  label: 'Address',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    height: 1,
                                  ),
                                  controller: _addressController,
                                  decoration: const InputDecoration(
                                    labelText: 'Address',
                                    labelStyle: TextStyle(fontSize: 13),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                requiredTextField(
                                  label: 'Email Address',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    height: 1,
                                  ),
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email Address',
                                    labelStyle: TextStyle(fontSize: 13),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: requiredTextField(
                                        label: 'Phone Number',
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          height: 1,
                                        ),
                                        controller: _phoneController,
                                        decoration: const InputDecoration(
                                          labelText: 'Phone Number',
                                          labelStyle: TextStyle(fontSize: 13),
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          height: 1,
                                        ),
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Nationality',
                                          labelStyle: TextStyle(fontSize: 13),
                                          border: OutlineInputBorder(),
                                          suffixIcon: Icon(
                                            Icons.arrow_drop_down,
                                          ),
                                        ),
                                        controller: TextEditingController(
                                          text: nationality,
                                        ),
                                        validator: (value) =>
                                            value == null ||
                                                value.trim().isEmpty
                                            ? 'Input required'
                                            : null,
                                        onTap: () {
                                          showCountryPicker(
                                            context: context,
                                            showPhoneCode: false,
                                            onSelect: (Country country) {
                                              setState(() {
                                                nationality = country.name;
                                              });
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: requiredTextField(
                                        label: 'Date of Birth',

                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          height: 1,
                                        ),
                                        controller: _dobController,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          labelStyle: TextStyle(fontSize: 13),
                                          labelText: 'Date of Birth',
                                          border: const OutlineInputBorder(),
                                          suffixIcon: IconButton(
                                            icon: const Icon(
                                              Icons.calendar_today,
                                            ),
                                            onPressed: () async {
                                              final DateTime? pickedDate =
                                                  await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime(2000),
                                                    firstDate: DateTime(1900),
                                                    lastDate: DateTime.now(),
                                                  );
                                              if (pickedDate != null) {
                                                String formattedDate =
                                                    "${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.year}";
                                                setState(() {
                                                  _dobController.text =
                                                      formattedDate;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          height: 1,
                                          color: Colors.black,
                                          fontFamily: 'BricolageGrotesque',
                                        ),
                                        value: gender,
                                        isExpanded: true,
                                        items: genderOptions.map((
                                          String gender,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: gender,
                                            child: Text(gender),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            gender = newValue ?? '';
                                          });
                                        },
                                        validator: (value) =>
                                            value == null ||
                                                value.trim().isEmpty
                                            ? 'Input required'
                                            : null,
                                        decoration: const InputDecoration(
                                          labelText: 'Gender',
                                          labelStyle: TextStyle(fontSize: 13),
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          height: 1,
                                          color: Colors.black,
                                          fontFamily: 'BricolageGrotesque',
                                        ),

                                        value: id,
                                        items: idoptions.map((String idValue) {
                                          return DropdownMenuItem<String>(
                                            value: idValue,
                                            child: Text(
                                              idValue,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            id = newValue!;
                                          });
                                        },
                                        decoration: const InputDecoration(
                                          labelText: 'Valid ID',
                                          labelStyle: TextStyle(fontSize: 13),
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: InkWell(
                                        onTap: _pickImage,
                                        child: InputDecorator(
                                          decoration: const InputDecoration(
                                            labelText: 'Upload Valid ID',
                                            labelStyle: TextStyle(fontSize: 13),
                                            border: OutlineInputBorder(),
                                          ),
                                          child: _selectedImage == null
                                              ? const Text('Upload Valid ID')
                                              : Image.file(
                                                  File(_selectedImage!.path),
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        LngButton(
                          text: _isLoading ? 'Signing Up...' : 'Sign Up',
                          isOrange: true,
                          onPressed: _submitSignUp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

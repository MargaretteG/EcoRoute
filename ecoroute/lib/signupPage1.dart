import 'package:ecoroute/signupPage2.dart';
import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ecoroute/widgets/custom_button.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class SignUpPage1 extends StatefulWidget {
  const SignUpPage1({super.key});

  @override
  State<SignUpPage1> createState() => _SignUpPage1State();
}

class _SignUpPage1State extends State<SignUpPage1> {
  bool _obscurePassword = true;
  final TextEditingController _dobController = TextEditingController();
  String gender = 'Male';
  String id = 'National ID';
  String nationality = 'Filipino';
  final List<String> genderOptions = ['Male', 'Female', 'Prefer not to say'];
  final List<String> idoptions = ['National ID', 'Passport', 'Drivers License'];

  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final double screenWidth = MediaQuery.of(context).size.width;
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF011901),
        statusBarIconBrightness: Brightness.light,
      ),
    );

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
                      backgroundColor: Color(0xFF011901),
                      elevation: 0,
                      automaticallyImplyLeading: true,
                      iconTheme: const IconThemeData(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ),
                  Container(
                    color: const Color(0xFF011901),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -23),
                          child: Image.asset(
                            '../assets/images/logo-green.png',
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
                  // The rest of your form content (unchanged)
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Form(
                          child: FractionallySizedBox(
                            widthFactor: 0.95,
                            child: Container(
                              padding: const EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: 'Create Username',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            labelText: 'Create Password',
                                            border: const OutlineInputBorder(),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscurePassword =
                                                      !_obscurePassword;
                                                });
                                              },
                                            ),
                                          ),
                                          obscureText: _obscurePassword,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 25),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: 'First Name',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: 'Last Name',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 25),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Address',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Email Address',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),

                                  const SizedBox(height: 25),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: 'Phone Number',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextFormField(
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            labelText: 'Nationality',
                                            border: OutlineInputBorder(),
                                            suffixIcon: const Icon(
                                              Icons.arrow_drop_down,
                                            ),
                                          ),
                                          controller: TextEditingController(
                                            text: nationality,
                                          ),
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

                                  // TextFormField(
                                  //   decoration: InputDecoration(
                                  //     labelText: 'Password',
                                  //     border: const OutlineInputBorder(),
                                  //     suffixIcon: IconButton(
                                  //       icon: Icon(
                                  //         _obscurePassword
                                  //             ? Icons.visibility_off
                                  //             : Icons.visibility,
                                  //       ),
                                  //       onPressed: () {
                                  //         setState(() {
                                  //           _obscurePassword =
                                  //               !_obscurePassword;
                                  //         });
                                  //       },
                                  //     ),
                                  //   ),
                                  //   obscureText: _obscurePassword,
                                  // ),
                                  const SizedBox(height: 25),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _dobController,
                                          readOnly: true,
                                          decoration: InputDecoration(
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
                                                      initialDate: DateTime(
                                                        2000,
                                                      ),
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
                                              gender = newValue!;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            labelText: 'Gender',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 25),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: id,
                                          items: idoptions.map((String id) {
                                            return DropdownMenuItem<String>(
                                              value: id,
                                              child: Text(id),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              id = newValue!;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            labelText: 'Valid ID',
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
                                              labelText: 'Upload Photo',
                                              border: OutlineInputBorder(),
                                            ),
                                            child: _selectedImage == null
                                                ? const Text(
                                                    'Tap to select image',
                                                  )
                                                : Image.network(
                                                    _selectedImage!.path,
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
                        ),
                        const SizedBox(height: 30),
                        LngButton(
                          text: 'Next >',
                          isOrange: true,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpPage2(),
                              ),
                            );
                          },
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

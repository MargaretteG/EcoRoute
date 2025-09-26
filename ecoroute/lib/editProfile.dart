import 'package:ecoroute/widgets/popup.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfile({super.key, required this.userData});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _api = ApiService();

  bool _changed = false;
  bool _loading = true;
  Map<String, dynamic>? _user;
  File? _imageFile;

  final Map<String, FocusNode> _focusNodes = {};

  // controllers
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _genderCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _changed = true;
      });
    }
  }

  Future<void> _uploadProfilePicture(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getInt("accountId");
    if (accountId == null) return;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
        "https://ecoroute-taal.online/uploadProfilePic.php",
      ), // <-- use the actual PHP script
    );

    request.fields['accountId'] = accountId.toString();
    request.files.add(
      await http.MultipartFile.fromPath('profile_picture', imageFile.path),
    );

    var response = await request.send();
    if (response.statusCode == 200) {
      print("✅ Upload success");
      _loadUser(); // reload updated data
    } else {
      print("❌ Upload failed");
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getInt("accountId");
    if (accountId == null) return;

    final data = await _api.fetchProfile(accountId: accountId);
    setState(() {
      _user = data;
      _loading = false;
    });

    // fill controllers
    _firstNameCtrl.text = data['firstName'] ?? '';
    _lastNameCtrl.text = data['lastName'] ?? '';
    _usernameCtrl.text = data['userName'] ?? '';
    _emailCtrl.text = data['email'] ?? '';
    _phoneCtrl.text = data['phoneNumber'] ?? '';
    _addressCtrl.text = data['address'] ?? '';
    _genderCtrl.text = data['gender'] ?? '';
  }

  Future<void> _saveChanges() async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getInt("accountId");
    if (accountId == null) return;

    if (_imageFile != null) {
      await _uploadProfilePicture(_imageFile!);
      _imageFile = null; // reset after upload
    }

    final result = await _api.updateProfile({
      "accountId": accountId.toString(),
      "firstName": _firstNameCtrl.text,
      "lastName": _lastNameCtrl.text,
      "username": _usernameCtrl.text,
      "email": _emailCtrl.text,
      "phoneNum": _phoneCtrl.text,
      "address": _addressCtrl.text,
      "gender": _genderCtrl.text,
    }, imageFile: _imageFile);

    if (result["status"] == "success") {
      setState(() => _changed = false);

      // ✅ Update local user map

      //  Merge with current _user so we keep profilePic
      final updatedUser = {
        ...?_user, // preserve anything already there like profilePic
        "firstName": _firstNameCtrl.text,
        "lastName": _lastNameCtrl.text,
        "userName": _usernameCtrl.text,
        "email": _emailCtrl.text,
        "phoneNumber": _phoneCtrl.text,
        "address": _addressCtrl.text,
        "gender": _genderCtrl.text,
      };

      await prefs.setString("userData", jsonEncode(updatedUser));

      setState(() {
        _user = updatedUser; // profilePic preserved
      });

      // ✅ Show SuccessPopup
      showDialog(
        context: context,
        builder: (context) => const SuccessPopup(
          message: "Profile updated successfully!",
          icon: Icons.check_circle_rounded,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (_loading) {
    //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }
    final fullName = "${_firstNameCtrl.text} ${_lastNameCtrl.text}";

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 255, 240),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              height: 270,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 130, 87, 47),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
              child: Stack(
                children: [
                  Opacity(
                    opacity: 0.2,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(60),
                        bottomRight: Radius.circular(60),
                      ),
                      child: _imageFile != null
                          ? Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: double.infinity,
                            )
                          : (_user != null &&
                                    _user!['profilePic'] != null &&
                                    _user!['profilePic'].isNotEmpty
                                ? Image.network(
                                    "https://ecoroute-taal.online/uploads/profile_pics/${_user!['profilePic']}",
                                    fit: BoxFit.cover,
                                    height: double.infinity,
                                    width: double.infinity,
                                  )
                                : Image.asset(
                                    "images/profile_picture.png",
                                    fit: BoxFit.cover,
                                    height: double.infinity,
                                    width: double.infinity,
                                  )),
                    ),
                  ),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 30),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.green, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (_user != null &&
                                                _user!['profilePic'] != null &&
                                                _user!['profilePic'].isNotEmpty
                                            ? NetworkImage(
                                                "https://ecoroute-taal.online/uploads/profile_pics/${_user!['profilePic']}",
                                              )
                                            : AssetImage(
                                                "images/profile_picture.png",
                                              ))
                                        as ImageProvider,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Text(
                          _usernameCtrl.text,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _emailCtrl.text,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Info Cards
            _buildInfoCard("First Name", _firstNameCtrl.text),
            _buildInfoCard("Last Name", _lastNameCtrl.text),
            _buildInfoCard("Username", _usernameCtrl.text),
            _buildInfoCard("Email", _emailCtrl.text),
            _buildInfoCard("Phone", _phoneCtrl.text),
            _buildInfoCard("Address", _addressCtrl.text),
            _buildInfoCard("Gender", _genderCtrl.text),

            if (_changed)
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7C11),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 7, // shadow depth
                    shadowColor: Colors.black.withOpacity(1),
                  ),
                  onPressed: _saveChanges,
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Set<String> _editingFields = {};

  Widget _buildInfoCard(String title, String value) {
    // pick correct controller
    TextEditingController controller;
    switch (title.toLowerCase()) {
      case 'first name':
        controller = _firstNameCtrl;
        break;
      case 'last name':
        controller = _lastNameCtrl;
        break;
      case 'username':
        controller = _usernameCtrl;
        break;
      case 'email':
        controller = _emailCtrl;
        break;
      case 'phone':
        controller = _phoneCtrl;
        break;
      case 'address':
        controller = _addressCtrl;
        break;
      case 'gender':
        controller = _genderCtrl;
        break;
      default:
        controller = TextEditingController(text: value);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          // when tapping this container, close all others
          _editingFields.clear();
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(_getIconForTitle(title), color: Color(0xFFFF7C11)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _editingFields.clear();
                            _editingFields.add(title);
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _editingFields.contains(title)
                                ? Color(0xFF367E3D)
                                : Colors.transparent,
                            border: Border.all(
                              color: Color(0xFF367E3D),
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Icon(
                              Icons.edit,
                              size: 13,
                              color: _editingFields.contains(title)
                                  ? Colors.white
                                  : Color(0xFF367E3D),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  _editingFields.contains(title)
                      ? Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),

                            decoration: BoxDecoration(
                              color: Color.fromARGB(141, 223, 239, 223),

                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Color(0xFF367E3D),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: controller,
                              onChanged: (_) {
                                setState(() => _changed = true);
                              },
                              onEditingComplete: () {
                                setState(() {
                                  _editingFields.remove(title);
                                });
                              },
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          controller.text,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'first name':
        return Icons.person_outlined;
      case 'last name':
        return Icons.badge_outlined;
      case 'username':
        return Icons.account_circle_outlined;
      case 'email':
        return Icons.email_outlined;
      case 'phone':
        return Icons.phone_outlined;
      case 'address':
        return Icons.location_on_outlined;
      case 'gender':
        return Icons.wc_rounded;
      default:
        return Icons.info_outline;
    }
  }
}

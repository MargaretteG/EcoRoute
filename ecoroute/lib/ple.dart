import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart'; // <-- you already have this

class EditProfile1 extends StatefulWidget {
  const EditProfile1({super.key});

  @override
  State<EditProfile1> createState() => _EditProfileState1();
}

class _EditProfileState1 extends State<EditProfile1> {
  final _api = ApiService();

  bool _changed = false;
  bool _loading = true;
  Map<String, dynamic>? _user;

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

    final result = await _api.updateProfile({
      "accountId": accountId.toString(),
      "firstName": _firstNameCtrl.text,
      "lastName": _lastNameCtrl.text,
      "username": _usernameCtrl.text,
      "email": _emailCtrl.text,
      "phoneNum": _phoneCtrl.text,
      "address": _addressCtrl.text,
      "gender": _genderCtrl.text,
    });

    if (result["status"] == "success") {
      setState(() => _changed = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Profile updated successfully")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final fullName = "${_firstNameCtrl.text} ${_lastNameCtrl.text}";

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 255, 240),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // header
            Container(
              height: 270,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 91, 65, 40),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
              child: Stack(
                children: [
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white,
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
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage(
                            'images/profile_picture.png',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _usernameCtrl.text,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // info cards
            _buildInfoCard("Email", _emailCtrl),
            _buildInfoCard("Phone", _phoneCtrl),
            _buildInfoCard("Address", _addressCtrl),
            _buildInfoCard("Gender", _genderCtrl),

            if (_changed)
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7C11),
                  ),
                  onPressed: _saveChanges,
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, TextEditingController controller) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(_getIconForTitle(title), color: Color(0xFFFF7C11)),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: title,
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() => _changed = true),
            ),
          ),
          // edit icon circle
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFF7C11),
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(6.0),
              child: Icon(Icons.edit, size: 15, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'email':
        return Icons.email_outlined;
      case 'phone':
        return Icons.phone_outlined;
      case 'address':
        return Icons.location_on_outlined;
      case 'gender':
        return Icons.person_outline;
      default:
        return Icons.info_outline;
    }
  }
}

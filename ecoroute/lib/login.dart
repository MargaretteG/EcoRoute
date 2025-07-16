import 'package:ecoroute/main_screen.dart';
import 'package:ecoroute/signupPage1.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ecoroute/widgets/custom_button.dart';
import 'package:flutter/services.dart';

// ... imports ...

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();

  Widget _buildTextField(String label) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Password is required';
        }
        if (value.length < 8) {
          return 'Must be at least 8 characters';
        }
        if (!RegExp(r'[A-Z]').hasMatch(value)) {
          return 'Include at least one uppercase letter';
        }
        if (!RegExp(r'[a-z]').hasMatch(value)) {
          return 'Include at least one lowercase letter';
        }
        if (!RegExp(r'\d').hasMatch(value)) {
          return 'Include at least one digit';
        }
        if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
          return 'Include at least one special character (!@#\$&*~)';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
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
                            'images/logo-green.png',
                            height: 80,
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -40),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -40),
                          child: const Text(
                            'Let’s start your eco journey!',
                            style: TextStyle(
                              height: 1.1,
                              fontSize: 18,
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
                          key: _formKey,
                          child: FractionallySizedBox(
                            widthFactor: 0.85,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  _buildTextField('Username'),
                                  const SizedBox(height: 10),
                                  _buildPasswordField(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        LngButton(
                          text: 'Sign In',
                          isOrange: true,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MainScreen(),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22),
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 22),
                                  child: SizedBox(width: 10),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Color(0xFF011901),
                                    thickness: 0.7,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'or',
                                    style: TextStyle(
                                      color: Color(0xFF011901),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Color(0xFF011901),
                                    thickness: 0.7,
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(right: 22)),
                              ],
                            ),
                          ),
                        ),
                        LngButton.icon(
                          icon: const FaIcon(
                            FontAwesomeIcons.google,
                            color: Colors.white,
                          ),
                          text: 'Continue with Google',
                          isOrange: false,
                          resize: true,
                          onPressed: () {},
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22),
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 22),
                                  child: SizedBox(width: 10),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Color(0xFF011901),
                                    thickness: 0.7,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'Does not have an Account yet?',
                                    style: TextStyle(
                                      color: Color(0xFF011901),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w100,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Color(0xFF011901),
                                    thickness: 0.7,
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(right: 22)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.40,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignUpPage1(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF003F0C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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

import 'package:ecoroute/login.dart';
import 'package:ecoroute/signupPage1.dart';
import 'package:ecoroute/widgets/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ecoroute/widgets/custom_button.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoRoute',
      theme: ThemeData(
        fontFamily: 'BricolageGrotesque',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const SplashScreen(),
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key, required this.title});

  final String title;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFF011901),
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      backgroundColor: Color(0xFF011901),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Color(0xFF011901),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  Image.asset('images/logo-green.png', height: 90),

                  Transform.translate(
                    offset: Offset(0, -20),
                    child: Text(
                      'EcoRoute',
                      style: TextStyle(
                        // height: 1.1,
                        fontSize: 55,
                        color: Color(0xFF62ED7A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Color(0xFF011901),
              width: double.infinity,
              child: Stack(
                children: [
                  ClipRect(
                    child: Opacity(
                      opacity: 0.59,
                      child: Transform.translate(
                        offset: Offset(
                          20,
                          30,
                        ),
                        child: Transform.scale(
                          scale: 1.3, // zoom in
                          child: Image.asset(
                            'images/tagaytay-bg-1.jpg',
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Text(
                            'Welcome to EcoRoute!\nSign up or sign in to start\nexploring  Taal, Batangas',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              fontSize: 16,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 65),
                        LngButton(
                          text: 'Sign In',
                          isOrange: true,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 15),
                        LngButton(
                          text: 'Sign Up',
                          isOrange: true,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpPage1(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: SizedBox(
                            height: 80,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 32),
                                  child: const SizedBox(width: 10),
                                ),
                                const Expanded(
                                  child: Divider(
                                    color: Colors.white,
                                    thickness: 0.7,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'or',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),

                                const Expanded(
                                  child: Divider(
                                    color: Colors.white,
                                    thickness: 0.7,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(right: 32),
                                  child: SizedBox(width: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        LngButton.icon(
                          icon: FaIcon(
                            FontAwesomeIcons.google,
                            color: Colors.white,
                          ),
                          text: 'Continue with Google',
                          isOrange: false,
                          resize: true,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}

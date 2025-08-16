import 'package:flutter/material.dart';
import 'dart:async';
import 'package:ecoroute/main.dart';
import 'dart:ui';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(_createBlurRoute());
    });
  }

  Route _createBlurRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const WelcomePage(title: 'EcoRoute'),
      transitionDuration: const Duration(milliseconds: 800),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final blurTween = Tween<double>(begin: 10.0, end: 0.0);
        final opacityTween = Tween<double>(begin: 0.0, end: 1.0);

        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurTween.evaluate(animation),
                sigmaY: blurTween.evaluate(animation),
              ),
              child: FadeTransition(
                opacity: animation.drive(opacityTween),
                child: child,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFF142900),
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      backgroundColor: const Color(0xFF142900), // Dark green background
      body: Center(
        child: Image.asset(
          'images/animated-logo-3.gif',
          height: 270, // adjust size as needed
        ),
      ),
    );
  }
}

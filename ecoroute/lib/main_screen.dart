// main_screen.dart
import 'package:ecoroute/MapPage.dart';
import 'package:ecoroute/TravelPage.dart';
import 'package:ecoroute/communityPage.dart';
import 'package:ecoroute/homePage.dart';
import 'package:ecoroute/profile.dart';
import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/bottomNavBar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  Widget _getCurrentContent() {
    switch (_currentIndex) {
      case 0:
        return const MyHomePage();
      case 1:
        return const CommunityPage();
      case 2:
        return const MapPage(); // includes its own header
      case 3:
        return const TravelPage(); // includes its own header
      case 4:
        return const Profile(); // includes its own header
      default:
        return const MyHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF011901),
      body: Stack(
        children: [
          Column(children: [Expanded(child: _getCurrentContent())]),

          // Bottom Nav
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

// main_screen.dart
import 'dart:convert';
import 'package:ecoroute/MapPage.dart';
import 'package:ecoroute/TravelPage.dart';
import 'package:ecoroute/communityPage.dart';
import 'package:ecoroute/homePage.dart';
import 'package:ecoroute/profile.dart';
import 'package:ecoroute/widgets/customHeaderHome.dart';
import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/bottomNavBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final Map<String, dynamic>? userData; 

  const MainScreen({super.key, this.userData});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString("userData");
    if (userString != null) {
      setState(() {
        _userData = jsonDecode(userString);
      });
    } else {
      setState(() {
        _userData = widget.userData;
      });
    }
  }

  Widget _getCurrentContent() {
    switch (_currentIndex) {
      case 0:
        return const MyHomePage();
      case 1:
        return const CommunityPage();
      case 2:
        return const MapPage();
      case 3:
        return const TravelPage();
      case 4:
        return Profile(userData: _userData);

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

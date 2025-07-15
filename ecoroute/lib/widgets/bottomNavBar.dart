// import 'package:ecoroute/ProfilePage.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // void _handleNavigation(BuildContext context, int index) {
  //   // Call the parent's onTap if needed
  //   onTap(index);

  //   // Navigate to corresponding screen
  //   switch (index) {
  //     case 0:
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => const MyHomePage()),
  //       );
  //       break;
  //     case 1:
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => const CommunityPage()),
  //       );
  //       break;
  //     case 2:
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => const MapPage()),
  //       );
  //       break;
  //     case 3:
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => const TravelPage()),
  //       );
  //       break;
  //     case 4:
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => const Profile()),
  //       );
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: kBottomNavigationBarHeight + 1.5,
          decoration: const BoxDecoration(color: Colors.transparent),
        ),

        Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: BottomNavigationBar(
              backgroundColor: const Color(0xFF011901),
              currentIndex: currentIndex,
              onTap: onTap,
              // onTap: (index) => _handleNavigation(context, index),
              elevation: 0,
              selectedItemColor: const Color(0xFFFF9616),
              unselectedItemColor: Colors.white,
              selectedFontSize: 12,
              unselectedFontSize: 10,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.house_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_alt_rounded),
                  label: 'Community',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.wallet_travel_rounded),
                  label: 'Travels',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

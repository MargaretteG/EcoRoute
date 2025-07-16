import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/customHeaderHome.dart';
import 'package:ecoroute/widgets/bottomNavBar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _currentIndex = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF011901),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(130),
                        bottomRight: Radius.circular(130),
                      ),
                    ),
                    child: Column(
                      children: [
                        SearchHeader(
                          showSearch: false,
                          iconColor: Colors.black,
                          logoPath: 'images/logo-dark-green.png',
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 5,
                          ),
                          child: Divider(
                            color: Color(0xFF011901),
                            thickness: 0.5,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 5,
                            bottom: 15,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 45,
                                backgroundImage: AssetImage(
                                  'images/profile-sample.jpg',
                                ),
                              ),
                              const SizedBox(height: 10),

                              const Text(
                                'marissaGarcia',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF011901),
                                ),
                              ),
                              Transform.translate(
                                offset: Offset(0, -7),
                                child: Text(
                                  'marissa@gmail.com',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF011901),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '20',
                                        style: TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF011901),
                                        ),
                                      ),
                                      Text('Followers'),
                                    ],
                                  ),
                                  SizedBox(width: 15),

                                  // Vertical Divider
                                  Container(
                                    height: 30,
                                    width: 1,
                                    color: Colors.grey,
                                  ),

                                  SizedBox(width: 15),
                                  Column(
                                    children: [
                                      Text(
                                        '50',
                                        style: TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF011901),
                                        ),
                                      ),
                                      Text('Following'),
                                    ],
                                  ),
                                ],
                              ),
                              Transform.translate(
                                offset: Offset(0, 35),

                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF9616),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        color: Color(0xFF011901),
                                        fontWeight: FontWeight.bold,
                                      ),
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
                ],
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

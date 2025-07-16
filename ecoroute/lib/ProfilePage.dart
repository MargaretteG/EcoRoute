import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/customHeaderHome.dart';
import 'package:ecoroute/widgets/bottomNavBar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF011901),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ✅ Use your SearchHeader (logo + styling consistent)
              SearchHeader(
                showSearch: false,
                iconColor: Colors.black,
                logoPath: 'images/logo-dark-green.png',
              ),

              // ✅ Curved white container holding the profile info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(80)),
                ),
                child: Column(
                  children: [
                    // 🟢 Profile Image
                    const CircleAvatar(
                      radius: 45,
                      backgroundImage: AssetImage('images/profile-sample.jpg'),
                    ),
                    const SizedBox(height: 10),

                    // 🟢 Username & Email
                    const Text(
                      'vanessa_travels',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      'travelerv@gmail.com',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 12),

                    // 🟢 Followers & Following
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Column(
                          children: [
                            Text(
                              '20',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Followers'),
                          ],
                        ),
                        SizedBox(width: 30),
                        Column(
                          children: [
                            Text(
                              '50',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Following'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 🟠 Edit Profile Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9616),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text('Edit Profile'),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              // ✅ Feed & History Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Feed',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Travel History',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24),

              // ✅ Add a Post Card
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF06350A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('images/profile-sample.jpg'),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Share your travel experiences',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    Icon(Icons.image, color: Colors.white70),
                  ],
                ),
              ),

              // ✅ Sample Post
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF06350A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: AssetImage(
                            'images/profile-sample.jpg',
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Traveler’s Name",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Date",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Icon(Icons.more_vert, color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Input Caption",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'images/home-photo1.jpg',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 180,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),

      // ✅ Bottom Navigation Bar
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

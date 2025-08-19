import 'package:ecoroute/widgets/customHeaderHome.dart';
import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:ecoroute/widgets/custom_button.dart';
import 'package:flutter/services.dart';
import 'package:ecoroute/widgets/customTopCategory.dart';
import 'package:ecoroute/widgets/customCard.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _currentIndex = 0;

  // final List<Widget> _screens = [const MyHomePage(), const CommunityPage()];

  final homeCategories = [
    {'text': 'All', 'icon': Icons.eco, 'isFilled': false},
    {'text': 'Eco Parks', 'icon': Icons.park, 'isFilled': false},
    {'text': 'Things to do', 'icon': Icons.local_activity, 'isFilled': false},
    {'text': 'Popular', 'icon': Icons.star_border, 'isFilled': false},
    {'text': 'Filter', 'icon': Icons.filter_list, 'isFilled': true},
  ];

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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SearchHeader(),
                CategoryRow(categories: homeCategories),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text column
                        Expanded(
                          flex: 2,

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Welcome to',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              Transform.translate(
                                offset: Offset(0, -10),
                                child: Text(
                                  'EcoRoute',
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: Color(0xFF62ED7A),
                                    fontWeight: FontWeight.w900,
                                  ), 
                                ),
                              ),
                              Transform.translate(
                                offset: Offset(0, -10),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Start your EcoTravel trips in',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: 'BricolageGrotesque',
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' Taal,\nBatangas',
                                        style: TextStyle(
                                          color: Color(0xFFFF9616),
                                          fontSize: 12,
                                          fontFamily: 'BricolageGrotesque',
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' with us!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: 'BricolageGrotesque',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Image side
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 5,
                            ),
                            child: AspectRatio(
                              aspectRatio: 1, // square image
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'images/home-photo1.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(150),
                          ),
                        ),
                        child: Column(
                          children: const [
                            Text(
                              'Stack content goes here',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(
                              height: 400,
                            ), // Simulate long scrollable content
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        TouristSpotCard(
                          imagePath: 'images/taal-basilica-sample.JPG',
                          name: 'Taal Basilica -Church',
                          location: 'Brgy. Taal, Batangas',
                          starRating: 5,
                          ecoRating: 4,
                          badgeColor: Colors.yellow,
                          badgeIcon: Icons.location_on,
                        ),
                        TouristSpotCard(
                          imagePath: 'images/tourist-spot2.jpg',
                          name: 'Another Tourist Spot',
                          location: 'Brgy. Example, Batangas',
                          starRating: 5,
                          ecoRating: 4,
                          badgeColor: Colors.yellow,
                          badgeIcon: Icons.location_on,
                        ),

                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: BottomNavBar(
          //     currentIndex: _currentIndex,
          //     onTap: (index) {
          //       setState(() {
          //         _currentIndex = index;
          //       });
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}

import 'package:ecoroute/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecoroute/widgets/customHeaderHome.dart';
import 'package:ecoroute/widgets/promoCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecoroute/widgets/customTopCategory.dart';
import 'package:ecoroute/widgets/customCard.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final homeCategories = [
    {'text': 'All', 'icon': Icons.eco, 'isFilled': false},
    {'text': 'Eco Park', 'icon': Icons.park, 'isFilled': false},
    {'text': 'Amusement Park', 'icon': Icons.local_activity, 'isFilled': false},
    {'text': 'Cultural Cite', 'icon': Icons.museum, 'isFilled': false},
    {'text': 'Church', 'icon': Icons.church, 'isFilled': false},
    {'text': 'Restaurant', 'icon': Icons.restaurant, 'isFilled': false},
    {'text': 'Hotel', 'icon': Icons.hotel, 'isFilled': false},
    {'text': 'Local Market', 'icon': Icons.storefront, 'isFilled': false},
    {'text': 'Filter', 'icon': Icons.filter_list, 'isFilled': true},
  ];
  String _selectedCategory = "all";

  // ✅ Keep your tourist spots in a list
  final List<Map<String, dynamic>> _touristSpots = [
    {
      'imagePath': 'images/taal-basilica-sample.JPG',
      'name': 'Taal Basilica -Church',
      'location': 'Brgy. Taal, Batangas',
      'starRating': 3,
      'ecoRating': 1,
      'badgeIcon': Icons.workspace_premium_outlined,
      'category': 'church',
    },
    {
      'imagePath': 'images/tourist-spot2.jpg',
      'name': 'Another Tourist Spot',
      'location': 'Brgy. Example, Batangas',
      'starRating': 5,
      'ecoRating': 2,
      'badgeIcon': Icons.workspace_premium_outlined,
      'category': 'cultural cite',
    },
    {
      'imagePath': 'images/taal-basilica-sample.JPG',
      'name': 'Food Place',
      'location': 'Brgy. Taal, Batangas',
      'starRating': 3,
      'ecoRating': 3,
      'badgeIcon': Icons.workspace_premium_outlined,
      'category': 'restaurant',
    },
    {
      'imagePath': 'images/tourist-spot2.jpg',
      'name': 'Hotel Stay',
      'location': 'Brgy. Example, Batangas',
      'starRating': 4,
      'ecoRating': 4,
      'badgeIcon': Icons.workspace_premium_outlined,
      'category': 'hotel',
    },
    {
      'imagePath': 'images/taal-basilica-sample.JPG',
      'name': 'Fun Park',
      'location': 'Brgy. Taal, Batangas',
      'starRating': 5,
      'ecoRating': 5,
      'badgeIcon': Icons.workspace_premium_outlined,
      'category': 'amusement park',
    },
    {
      'imagePath': 'images/taal-basilica-sample.JPG',
      'name': 'Green Park',
      'location': 'Brgy. Taal, Batangas',
      'starRating': 5,
      'ecoRating': 2,
      'badgeIcon': Icons.workspace_premium_outlined,
      'category': 'eco park',
    },
    {
      'imagePath': 'images/tourist-spot2.jpg',
      'name': 'Local Market',
      'location': 'Brgy. Example, Batangas',
      'starRating': 2,
      'ecoRating': 0,
      'badgeIcon': Icons.workspace_premium_outlined,
      'category': 'local market',
    },
  ];

  Map<String, dynamic>? _user;
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getInt("accountId");
    if (accountId == null) return;

    final userData = await _api.fetchProfile(accountId: accountId);

    if (!mounted) return; // prevent setState after dispose

    setState(() {
      _user = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter spots depending on category
    final filteredSpots = _selectedCategory == "all"
        ? _touristSpots
        : _touristSpots
              .where(
                (spot) =>
                    spot['category'].toString().toLowerCase() ==
                    _selectedCategory.toLowerCase(),
              )
              .toList();

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
                SearchHeader(
                  profilePicUrl:
                      _user?['profilePic'] != null &&
                          _user!['profilePic'].isNotEmpty
                      ? "https://ecoroute-taal.online/uploads/profile_pics/${_user!['profilePic']}"
                      : null,
                ),

                Padding(
                  padding: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    bottom: 0,
                    top: 10,
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
                                  'images/home-photo1.png',
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      PromoCard(
                        title: "Taste Taal",
                        description:
                            "Savor unique flavors and local delicacies.",
                        buttonText: "Explore",
                        imagePath: "images/promo-delicacy.png",
                        startColor: const Color(0xFF62ED7A),
                        onPressed: () {
                          // navigate or action
                        },
                      ),

                      PromoCard(
                        title: "Cultural Gems",
                        description:
                            "Step into history through Taal’s heritage sites.",
                        buttonText: "Visit",
                        imagePath: "images/promo-culture.png",
                        startColor: const Color(0xFFE24C88),

                        onPressed: () {},
                      ),
                      PromoCard(
                        title: "Festive Taal",
                        description:
                            "Join vibrant celebrations all year round.",
                        buttonText: "Explore",
                        imagePath: "images/promo-festive.png",
                        startColor: const Color(0xFF4CC9F0),

                        onPressed: () {
                          // navigate or action
                        },
                      ),
                    ],
                  ),
                ),
                // Categories button
                CategoryRow(
                  categories: homeCategories,
                  onCategorySelected: (index) {
                    setState(() {
                      _selectedCategory =
                          (homeCategories[index]['text'] as String)
                              .toLowerCase();
                    });
                  },
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 225, 240, 226),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        for (var spot in filteredSpots)
                          TouristSpotCard(
                            imagePath: spot['imagePath'],
                            name: spot['name'],
                            location: spot['location'],
                            starRating: spot['starRating'],
                            ecoRating: spot['ecoRating'],
                            badgeIcon: spot['badgeIcon'],
                            category: spot['category'],
                          ),
                        // TouristSpotCard(
                        //   imagePath: 'images/taal-basilica-sample.JPG',
                        //   name: 'Taal Basilica -Church',
                        //   location: 'Brgy. Taal, Batangas',
                        //   starRating: 3,
                        //   ecoRating: 1,
                        //   badgeIcon: Icons.workspace_premium_outlined,
                        //   category: 'church',
                        // ),
                        // TouristSpotCard(
                        //   imagePath: 'images/tourist-spot2.jpg',
                        //   name: 'Another Tourist Spot',
                        //   location: 'Brgy. Example, Batangas',
                        //   starRating: 5,
                        //   ecoRating: 2,
                        //   badgeIcon: Icons.workspace_premium_outlined,
                        //   category: 'cultural cites',
                        // ),
                        // TouristSpotCard(
                        //   imagePath: 'images/taal-basilica-sample.JPG',
                        //   name: 'Taal Basilica -Church',
                        //   location: 'Brgy. Taal, Batangas',
                        //   starRating: 3,
                        //   ecoRating: 3,
                        //   badgeIcon: Icons.workspace_premium_outlined,
                        //   category: 'restaurant',
                        // ),
                        // TouristSpotCard(
                        //   imagePath: 'images/tourist-spot2.jpg',
                        //   name: 'Another Tourist Spot',
                        //   location: 'Brgy. Example, Batangas',
                        //   starRating: 4,
                        //   ecoRating: 4,
                        //   badgeIcon: Icons.workspace_premium_outlined,
                        //   category: 'hotel',
                        // ),
                        // TouristSpotCard(
                        //   imagePath: 'images/taal-basilica-sample.JPG',
                        //   name: 'Taal Basilica -Church',
                        //   location: 'Brgy. Taal, Batangas',
                        //   starRating: 5,
                        //   ecoRating: 5,
                        //   badgeIcon: Icons.workspace_premium_outlined,
                        //   category: 'amusement parks',
                        // ),
                        // TouristSpotCard(
                        //   imagePath: 'images/taal-basilica-sample.JPG',
                        //   name: 'Taal Basilica -Church',
                        //   location: 'Brgy. Taal, Batangas',
                        //   starRating: 5,
                        //   ecoRating: 2,
                        //   badgeIcon: Icons.workspace_premium_outlined,
                        //   category: 'eco parks',
                        // ),
                        // TouristSpotCard(
                        //   imagePath: 'images/tourist-spot2.jpg',
                        //   name: 'Another Tourist Spot',
                        //   location: 'Brgy. Example, Batangas',
                        //   starRating: 2,
                        //   ecoRating: 0,
                        //   badgeIcon: Icons.workspace_premium_outlined,
                        //   category: 'local markets',
                        // ),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
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

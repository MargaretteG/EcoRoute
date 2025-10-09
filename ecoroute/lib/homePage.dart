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
  Map<String, dynamic>? _user;
  final _api = ApiService();

  List<Map<String, dynamic>> _establishments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Refetch data whenever this page becomes active
    _refreshData();
  }

  Future<void> _refreshData() async {
    if (_userId != null) {
      await Future.wait([_fetchEstablishments(), _fetchUserFavorites()]);
    }
  }

  Future<void> _initializeData() async {
    await _loadUser();
    await Future.wait([_fetchEstablishments(), _fetchUserFavorites()]);
    if (mounted) setState(() => _isLoading = false);

    if (_userId == null) {
      print(" Cannot initialize: userId is null");
      return;
    }

    await Future.wait([_fetchEstablishments(), _fetchUserFavorites()]);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  int? _userId;
  int? _establishmentId;
  List<int> _favoriteEstablishments = [];

  Future<void> _fetchUserFavorites() async {
    if (_userId == null) {
      print("Cannot fetch favorites: userId is null");
      return;
    }

    try {
      final favorites = await fetchUserFavorites(_userId!);
      print("Fetched favorites: $favorites");

      if (!mounted) return;
      setState(() {
        _favoriteEstablishments = favorites;
      });
    } catch (e) {
      print("Error fetching user favorites: $e");
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getInt("accountId");
    if (accountId == null) {
      print(" No accountId found in SharedPreferences");
      return;
    }

    setState(() {
      _userId = accountId;
    });

    try {
      final userData = await _api.fetchProfile(accountId: accountId);
      if (!mounted) return;

      setState(() {
        _user = userData;
      });
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  Future<void> _fetchEstablishments() async {
    try {
      final data = await fetchAllEstablishments();
      print("Fetched ${data.length} establishments");

      if (!mounted) return;

      if (data.isNotEmpty) {
        final firstEstab = data.first;
        final estId = firstEstab['establishment_id'];

        if (estId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('establishment_id', estId);
          print(" Saved establishmentId: $estId");

          setState(() {
            _establishmentId = estId;
          });
        } else {
          print(" No establishmentId found in first establishment");
        }
      }

      setState(() {
        _establishments = data;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching establishments: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter by category
    final filteredSpots = _selectedCategory == "all"
        ? _establishments
        : _establishments
              .where(
                (spot) =>
                    (spot['establishmentCategory'] ?? '')
                        .toString()
                        .toLowerCase() ==
                    _selectedCategory.toLowerCase(),
              )
              .toList();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF011901),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF011901),
      body: Stack(
        children: [
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF62ED7A)),
                )
              : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
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
                          top: 0,
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
                                              text:
                                                  'Start your EcoTravel trips in',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontFamily:
                                                    'BricolageGrotesque',
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' Taal,\nBatangas',
                                              style: TextStyle(
                                                color: Color(0xFFFF9616),
                                                fontSize: 12,
                                                fontFamily:
                                                    'BricolageGrotesque',
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' with us!',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontFamily:
                                                    'BricolageGrotesque',
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

                      // Promo cards
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
                              onPressed: () {},
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
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),

                      // Categories
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

                      // Establishments
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 225, 240, 226),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(25),
                            ),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              for (var spot in filteredSpots)
                                TouristSpotCard(
                                  imagePath:
                                      (spot['images'] != null &&
                                          spot['images'].isNotEmpty)
                                      ? "https://ecoroute-taal.online/EcoRoute/Includes/Images/tourist-estab/managelisting/${spot['images'][0]['imageUrl']}"
                                      : 'images/default-placeholder.png',
                                  name: spot['establishmentName'] ?? '',
                                  location: spot['address'] ?? '',
                                  starRating: spot['userRating'] ?? 0.0,
                                  ecoRating: spot['recognitionRating'] ?? 0,
                                  badgeIcon: Icons.workspace_premium_outlined,
                                  category: spot['establishmentCategory'] ?? '',
                                  establishmentId:
                                      spot['establishment_id'] ?? 0,
                                  userId: _userId ?? 0,
                                  isFavorite: _favoriteEstablishments.contains(
                                    spot['establishment_id'],
                                  ),
                                  description: spot['listingDescription'] ?? '',
                                  highlightDescription:
                                      spot['highlightedDescription'] ?? '',
                                  phoneNumber: spot['phoneNumber'] ?? '',
                                  emailAdd: spot['emailAddress'] ?? '',
                                ),

                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

import 'package:ecoroute/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecoroute/widgets/emptyPage.dart';
import 'package:ecoroute/widgets/wishlistCard.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BottomPopup extends StatelessWidget {
  final String category;
  final String name;
  final List<String> faqs;
  final List<String> faqsAnswers;

  const BottomPopup({
    Key? key,
    required this.category,
    required this.name,
    required this.faqs,
    required this.faqsAnswers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  const Icon(
                    Icons.live_help,
                    color: Color(0xFF011901),
                    size: 30,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      "FAQs about $name",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF011901),
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // FAQ list
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: faqs.length,
                  itemBuilder: (_, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.help_outline_rounded,
                                color: Color(0xFFFF9616),
                                size: 16,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  faqs[index],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFFF9616),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Answer
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 22,
                            ), // align with text
                            child: Text(
                              faqsAnswers[index],
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Bottom Pop Up for Add Travel containing Wishlist
class WishlistsBottomPopup {
  static Future<void> show(
    BuildContext context,
    Function(Map<String, dynamic> pinnedPlace) onPinned,
  ) async {
    // Fetch favorites dynamically
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('accountId') ?? 0;

    if (userId == 0) {
      // If no user, show empty state
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => _emptyPopup(),
      );
      return;
    }

    // Fetch establishments & user favorites
    final establishments = await fetchAllEstablishments();
    final favoriteIds = await fetchUserFavorites(userId);

    final favorites = establishments.where((est) {
      final estId = int.tryParse(est['establishment_id'].toString()) ?? 0;
      return favoriteIds.contains(estId);
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext _) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.only(top: 5),
              child: Column(
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5,
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.favorite,
                          color: Color(0xFFFF9616),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Your Wishlist",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF011901),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Orange indicator
                  SizedBox(
                    height: 4,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        const Divider(color: Colors.black, thickness: 0.5),
                        Container(
                          height: 3,
                          width: 120,
                          color: Color(0xFFFF9616),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Favorites List
                  Expanded(
                    child: favorites.isEmpty
                        ? _emptyPopup()
                        : ListView.builder(
                            controller: controller,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 8,
                            ),
                            itemCount: favorites.length,
                            itemBuilder: (context, index) {
                              final spot = favorites[index];
                              return WishlistSpotCard(
                                establishmentId: spot['establishment_id'] ?? 0,
                                imagePath:
                                    (spot['images'] != null &&
                                        spot['images'].isNotEmpty)
                                    ? "https://ecoroute-taal.online/EcoRoute/Includes/Images/tourist-estab/managelisting/${spot['images'][0]['imageUrl']}"
                                    : 'images/image_load.png',
                                name: spot['establishmentName'] ?? '',
                                location: spot['address'] ?? '',
                                starRating: spot['userRating'] ?? 0.0,
                                ecoRating: spot['recognitionRating'] ?? 0,
                                category:
                                    spot['establishmentCategory'] ?? 'unknown',
                                type: "addTravel",
                                onPin: () {
                                  Navigator.pop(context);
                                  onPinned({
                                    'name':
                                        spot['establishmentName'] ?? 'Unknown',
                                    'establishment_id':
                                        int.tryParse(
                                          spot['establishment_id']
                                                  ?.toString() ??
                                              '0',
                                        ) ??
                                        0,
                                    'ecoRating':
                                        int.tryParse(
                                          spot['recognitionRating']
                                                  ?.toString() ??
                                              '0',
                                        ) ??
                                        0,
                                    'latitude':
                                        double.tryParse(
                                          spot['latitude']?.toString() ?? '0',
                                        ) ??
                                        0.0,
                                    'longitude':
                                        double.tryParse(
                                          spot['longitude']?.toString() ?? '0',
                                        ) ??
                                        0.0,
                                  });
                                },

                                // onPin: () {
                                //   Navigator.pop(context);
                                //   onPinned(spot['establishmentName'] ?? '');
                                // },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _emptyPopup() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: EmptyState(
        imagePath: 'images/16.png',
        title: "No Wishlist Yet",
        description:
            "Looks like your travel wishlist is empty. Start adding destinations you’d love to visit!",
        centerVertically: false,
      ),
    );
  }
}

//Recommendation Pop Up
class RecommendationBottomPopup {
  static void show(
    BuildContext context,
    Function(Map<String, dynamic> pinnedPlace) onPinned, {
    int? lastPinnedId,
  }) {
    double _degreesToRadians(double degrees) => degrees * pi / 180;


    // Get user location
    Future<Position?> getUserLocation() async {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    }

    // Fetch all establishments and calculate distance from user
    Future<List<Map<String, dynamic>>> fetchNearbyEstablishments() async {
      final prefs = await SharedPreferences.getInstance();
      final int userId = prefs.getInt('accountId') ?? 0;
      if (userId <= 0) return [];

      final uri = Uri.parse(
        'https://ecoroute-taal.online/getLastNearbyPin.php?user_id=$userId',
      );

      try {
        final response = await http.get(uri).timeout(ApiService.requestTimeout);
        if (response.statusCode != 200) return [];

        final data = jsonDecode(response.body);
        if (data['status'] != 'success') return [];

        final List<dynamic> recommendations = data['recommendations'] ?? [];

        return recommendations.map<Map<String, dynamic>>((spot) {
          // Build main image URL
          String imageUrl = 'images/image_load.png';
          if (spot['images'] is List && spot['images'].isNotEmpty) {
            final firstImage = spot['images'][0];
            if (firstImage['imageUrl'] != null &&
                firstImage['imageUrl'].toString().isNotEmpty) {
              imageUrl =
                  "https://ecoroute-taal.online/EcoRoute/Includes/Images/tourist-estab/managelisting/${firstImage['imageUrl']}";
            }
          }

          // Convert distance from km → meters
          double distanceMeters = (spot['distance_km'] ?? 0).toDouble() * 1000;

          return {
            'establishment_id': spot['establishment_id']?.toInt() ?? 0,
            'establishmentName': spot['establishmentName']?.toString() ?? '',
            'establishmentCategory':
                spot['establishmentCategory']?.toString() ?? 'unknown',
            'address': spot['address']?.toString() ?? '',
            'latitude': spot['latitude']?.toDouble() ?? 0.0,
            'longitude': spot['longitude']?.toDouble() ?? 0.0,
            'userRating': (spot['userRating'] ?? 0).toDouble(),
            'recognitionRating': spot['recognitionRating']?.toInt() ?? 0,
            'highlightedDescription':
                spot['highlightedDescription']?.toString() ?? '',
            'images': spot['images'] ?? [],
            'distanceMeters': distanceMeters,
            'imageUrl': imageUrl,
          };
        }).toList();
      } catch (e) {
        throw Exception("Network error: ${e.toString()}");
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DefaultTabController(
          length: 2,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (_, controller) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Column(
                  children: [
                    // Handle
                    Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    // Tab Bar
                    const TabBar(
                      labelColor: Color(0xFF011901),
                      indicatorColor: Color(0xFF64F67A),
                      tabs: [
                        Tab(text: "Nearby"),
                        Tab(text: "Popular"),
                      ],
                    ),

                    // Tab Views
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Nearby recommendations
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: fetchNearbyEstablishments(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Center(
                                  child: Text('No nearby destinations found.'),
                                );
                              } else {
                                final spots = snapshot.data!;
                                return ListView.builder(
                                  controller: controller,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 8,
                                  ),
                                  itemCount: spots.length,
                                  itemBuilder: (context, index) {
                                    final spot = spots[index];
                                    double distanceMeters =
                                        (spot['distanceMeters'] ?? 0)
                                            .toDouble();

                                    // Determine display value
                                    String displayDistance;
                                    double distanceForSorting;
                                    if (distanceMeters >= 1000) {
                                      displayDistance =
                                          "${(distanceMeters / 1000).toStringAsFixed(2)} km";
                                      distanceForSorting =
                                          distanceMeters; // sorting still in meters
                                    } else {
                                      displayDistance =
                                          "${distanceMeters.toStringAsFixed(0)} m";
                                      distanceForSorting = distanceMeters;
                                    }

                                    return WishlistSpotCard(
                                      cardType: "nearby",
                                      distanceMeters: distanceMeters,
                                      // distanceKm:
                                      //     double.tryParse(
                                      //       displayDistance.replaceAll(
                                      //         RegExp('[^0-9.]'),
                                      //         '',
                                      //       ),
                                      //     ) ??
                                      //     0,
                                      establishmentId:
                                          int.tryParse(
                                            spot['establishment_id']
                                                    ?.toString() ??
                                                '0',
                                          ) ??
                                          0,
                                      imagePath: spot['imageUrl'],
                                      name: spot['establishmentName'] ?? '',
                                      location: spot['address'] ?? '',
                                      starRating:
                                          double.tryParse(
                                            spot['userRating']?.toString() ??
                                                '0',
                                          ) ??
                                          0.0,
                                      ecoRating:
                                          int.tryParse(
                                            spot['recognitionRating']
                                                    ?.toString() ??
                                                '0',
                                          ) ??
                                          0,
                                      category:
                                          spot['establishmentCategory'] ??
                                          'unknown',
                                      type: "addTravel",
                                      onPin: () {
                                        Navigator.pop(context);
                                        onPinned({
                                          'name':
                                              spot['establishmentName'] ??
                                              'Unknown',
                                          'establishment_id':
                                              int.tryParse(
                                                spot['establishment_id']
                                                        ?.toString() ??
                                                    '0',
                                              ) ??
                                              0,
                                          'ecoRating':
                                              int.tryParse(
                                                spot['recognitionRating']
                                                        ?.toString() ??
                                                    '0',
                                              ) ??
                                              0,
                                          'latitude':
                                              double.tryParse(
                                                spot['latitude']?.toString() ??
                                                    '0',
                                              ) ??
                                              0.0,
                                          'longitude':
                                              double.tryParse(
                                                spot['longitude']?.toString() ??
                                                    '0',
                                              ) ??
                                              0.0,
                                        });
                                      },
                                    );
                                  },
                                );
                              }
                            },
                          ),

                          // Popular recommendations
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: fetchMostPinned(limit: 10),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Center(
                                  child: Text('No popular destinations found.'),
                                );
                              } else {
                                final popularSpots = snapshot.data!;
                                return ListView.builder(
                                  controller: controller,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 8,
                                  ),
                                  itemCount: popularSpots.length,
                                  itemBuilder: (context, index) {
                                    final spot = popularSpots[index];
                                    return WishlistSpotCard(
                                      cardType: "popular",
                                      rank: index + 1,
                                      establishmentId:
                                          int.tryParse(
                                            spot['establishment_id'].toString(),
                                          ) ??
                                          0,
                                      imagePath:
                                          (spot['images'] is List &&
                                              (spot['images'] as List)
                                                  .isNotEmpty &&
                                              (spot['images'][0] is Map &&
                                                  (spot['images'][0]['imageUrl']
                                                          ?.toString()
                                                          .isNotEmpty ??
                                                      false)))
                                          ? "https://ecoroute-taal.online/EcoRoute/Includes/Images/tourist-estab/managelisting/${spot['images'][0]['imageUrl']}"
                                          : 'images/image_load.png',
                                      name: spot['establishmentName'] ?? '',
                                      location: spot['address'] ?? '',
                                      starRating:
                                          double.tryParse(
                                            spot['userRating'].toString(),
                                          ) ??
                                          0.0,
                                      ecoRating:
                                          int.tryParse(
                                            spot['recognitionRating']
                                                .toString(),
                                          ) ??
                                          0,
                                      category:
                                          spot['establishmentCategory'] ??
                                          'unknown',
                                      type: "addTravel",
                                      onPin: () {
                                        Navigator.pop(context);
                                        onPinned({
                                          'name':
                                              spot['establishmentName'] ??
                                              'Unknown',
                                          'establishment_id':
                                              int.tryParse(
                                                spot['establishment_id']
                                                        ?.toString() ??
                                                    '0',
                                              ) ??
                                              0,
                                          'ecoRating':
                                              int.tryParse(
                                                spot['recognitionRating']
                                                        ?.toString() ??
                                                    '0',
                                              ) ??
                                              0,
                                          'latitude':
                                              double.tryParse(
                                                spot['latitude']?.toString() ??
                                                    '0',
                                              ) ??
                                              0.0,
                                          'longitude':
                                              double.tryParse(
                                                spot['longitude']?.toString() ??
                                                    '0',
                                              ) ??
                                              0.0,
                                        });
                                      },
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

//Snackbar

void showCustomSnackBar({
  required BuildContext context,
  required IconData icon,
  required String message,
  bool warning = false,
  bool alert = false,
  Color backgroundColor = const Color.fromARGB(220, 46, 158, 63),
  int durationSeconds = 3,
}) {
  final Color bgColor = warning
      ? const Color.fromARGB(223, 227, 67, 52)
      : alert
      ? const Color.fromARGB(223, 227, 145, 52)
      : backgroundColor;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: bgColor,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: durationSeconds),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

import 'package:ecoroute/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecoroute/widgets/emptyPage.dart';
import 'package:ecoroute/widgets/wishlistCard.dart';
import 'package:flutter/material.dart';

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

// Bottom Pop Up for Add Travelncontaining Wishlist
class WishlistsBottomPopup {
  static Future<void> show(
    BuildContext context,
    Function(String pinnedTitle) onPinned,
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
                                imagePath:
                                    (spot['images'] != null &&
                                        spot['images'].isNotEmpty)
                                    ? "https://ecoroute-taal.online/EcoRoute/Includes/Images/tourist-estab/managelisting/${spot['images'][0]['imageUrl']}"
                                    : 'images/image_load.png',
                                name: spot['establishmentName'] ?? '',
                                location: spot['address'] ?? '',
                                starRating: spot['userRating'] ?? 0.0,
                                ecoRating: spot['recognitionRating'] ?? 0,
                                category: spot['category'] ?? 'unknown',
                                type: "addTravel",
                                onPin: () {
                                  Navigator.pop(context);
                                  onPinned(spot['establishmentName'] ?? '');
                                },
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

//Recommendations Bottom Pop Up
class RecommendationBottomPopup {
  static void show(
    BuildContext context,
    Function(String pinnedTitle) onPinned,
  ) {
    // For now static sample data; in future replace this with DB data
    final List<Map<String, dynamic>> travelWishlist = [
      {
        "imagePath": "images/home-photo1-1.jpg",
        "name": "Taal Basilica",
        "location": "Taal, Philippines",
        "starRating": 5.0,
        "ecoRating": 4,
      },
      {
        "imagePath": "images/home-photo1-1.jpg",
        "name": "Chocolate Hills",
        "location": "Bohol, Philippines",
        "starRating": 5.0,
        "ecoRating": 5,
      },
      {
        "imagePath": "images/home-photo1-1.jpg",
        "name": "Mayon Volcano",
        "location": "Albay, Philippines",
        "starRating": 5.0,
        "ecoRating": 2,
      },
      {
        "imagePath": "images/home-photo1-1.jpg",
        "name": "Mayon Volcano",
        "location": "Albay, Philippines",
        "starRating": 2.0,
        "ecoRating": 1,
      },
      {
        "imagePath": "images/home-photo1-1.jpg",
        "name": "Mayon Volcano",
        "location": "Albay, Philippines",
        "starRating": 5.0,
        "ecoRating": 3,
      },
    ];
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
                          ListView.builder(
                            controller: controller, // use the sheet controller
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 8,
                            ),
                            itemCount: travelWishlist.length,
                            itemBuilder: (context, index) {
                              final spot = travelWishlist[index];
                              return WishlistSpotCard(
                                imagePath: spot["imagePath"],
                                name: spot["name"],
                                location: spot["location"],
                                starRating: spot["starRating"],
                                ecoRating: spot["ecoRating"],
                                category: "unknown",
                                type: "addTravel",
                                onPin: () {
                                  Navigator.pop(context);
                                  onPinned(spot["name"]);
                                },
                              );
                            },
                          ),

                          // Popular / Eco Rating recommendations
                          // ListView(
                          //   controller: controller,
                          //   padding: const EdgeInsets.all(16),
                          //   children: [
                          //     _buildRecommendationCard(
                          //       "Banaue Rice Terraces",
                          //       "Ifugao, Philippines",
                          //       5,
                          //       5,
                          //     ),
                          //     _buildRecommendationCard(
                          //       "Palawan Underground River",
                          //       "Puerto Princesa, Philippines",
                          //       5,
                          //       5,
                          //     ),
                          //   ],
                          // ),
                          ListView.builder(
                            controller: controller, // use the sheet controller
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 8,
                            ),
                            itemCount: travelWishlist.length,
                            itemBuilder: (context, index) {
                              final spot = travelWishlist[index];
                              return WishlistSpotCard(
                                imagePath: spot["imagePath"],
                                name: spot["name"],
                                location: spot["location"],
                                starRating: spot["starRating"],
                                ecoRating: spot["ecoRating"],
                                category: "unknown",
                                type: "addTravel",
                                onPin: () {
                                  Navigator.pop(context);
                                  onPinned(spot["name"]);
                                },
                              );
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

  static Widget _buildRecommendationCard(
    String name,
    String location,
    int starRating,
    int ecoRating,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF64F67A),
          child: Icon(Icons.place, color: Colors.black),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(location),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                starRating,
                (i) => const Icon(Icons.star, color: Colors.orange, size: 16),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Eco $ecoRating/5",
              style: const TextStyle(fontSize: 12, color: Colors.green),
            ),
          ],
        ),
        onTap: () {
          // Navigator.pop(context);
          // Later: integrate adding this to destinations
        },
      ),
    );
  }
}

//Snackbar

void showCustomSnackBar({
  required BuildContext context,
  required IconData icon,
  required String message,
  Color backgroundColor = const Color(0xFF2E9E3F),
  int durationSeconds = 3,
}) {
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
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: durationSeconds),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

import 'package:ecoroute/widgets/emptyPage.dart';
import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/customTravelheader.dart';
import 'package:ecoroute/widgets/wishlistCard.dart'; // Import the new card widget

class WishlistsContent extends StatelessWidget {
  const WishlistsContent({super.key});

  @override
  Widget build(BuildContext context) {
    // For now static sample data; in future replace this with DB data
    final List<Map<String, dynamic>> travelWishlist = [
      {
        "imagePath": "images/home-photo1-1.jpg",
        "name": "Taal Basilica",
        "location": "Taal, Philippines",
        "starRating": 5,
        "ecoRating": 4,
      },
      {
        "imagePath": "images/home-photo1-1.jpg",
        "name": "Taal Basilica",
        "location": "Taal, Philippines",
        "starRating": 5,
        "ecoRating": 5,
      },
      {
        "imagePath": "images/home-photo1-1.jpg",
        "name": "Taal Basilica",
        "location": "Taal, Philippines",
        "starRating": 5,
        "ecoRating": 2,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF011901),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TravelHeader(
              title: 'Travel Wishlist',
              subtitle: '.',
              showBottomRow: false,
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(50),
                      ),
                    ),
                    child: travelWishlist.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                EmptyState(
                                  imagePath: 'images/16.png',
                                  title: "No Wishlist Yet",
                                  description:
                                      "Looks like your travel wishlist is empty. Start adding destinations you’d love to visit!",
                                  centerVertically: false,
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 17,
                              horizontal: 10,
                            ),
                            child: Column(
                              children: travelWishlist.map((spot) {
                                return WishlistSpotCard(
                                  imagePath: spot["imagePath"],
                                  name: spot["name"],
                                  location: spot["location"],
                                  starRating: spot["starRating"],
                                  ecoRating: spot["ecoRating"],

                                  category: "unknown",
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

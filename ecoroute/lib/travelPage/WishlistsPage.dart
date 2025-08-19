import 'package:ecoroute/widgets/emptyPage.dart';
import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/customTravelheader.dart';

class WishlistsContent extends StatelessWidget {
  const WishlistsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> travelWishlist = [];

    return Scaffold(
      backgroundColor: Color(0xFF011901),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TravelHeader(
              title: 'Your Travel Wishlist',
              subtitle: '.',
              showBottomRow: false,
            ),
            SizedBox(height: 20),
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
                        : Column(children: const [SizedBox(height: 500)]),
                  ),
                ),
                Column(children: [
                    
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

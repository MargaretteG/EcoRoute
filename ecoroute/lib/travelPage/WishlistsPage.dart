import 'package:ecoroute/widgets/emptyPage.dart';
import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/customTravelheader.dart';
import 'package:ecoroute/widgets/wishlistCard.dart';
import 'package:ecoroute/api_service.dart'; // ✅ connect API
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistsContent extends StatefulWidget {
  const WishlistsContent({super.key});

  @override
  State<WishlistsContent> createState() => _WishlistsContentState();
}

class _WishlistsContentState extends State<WishlistsContent> {
  List<dynamic> favoriteEstablishments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavoritesData();
  }

  Future<void> fetchFavoritesData() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      // ✅ Use the correct key exactly as in homepage
      final userId = prefs.getInt('accountId') ?? 0;

      if (userId == 0) {
        debugPrint("❌ No user logged in");
        setState(() {
          favoriteEstablishments = [];
          isLoading = false;
        });
        return;
      }

      // Fetch all establishments
      final establishments = await fetchAllEstablishments();

      // Fetch user's favorite IDs
      final favoriteIds = await fetchUserFavorites(userId);

      // Debug prints
      debugPrint("✅ User ID: $userId");
      debugPrint("✅ Fetched favorite IDs: $favoriteIds");
      debugPrint("✅ Establishments fetched: ${establishments.length}");

      // Filter only favorites
      final favorites = establishments.where((est) {
        final estId = int.tryParse(est['establishment_id'].toString()) ?? 0;
        final isFav = favoriteIds.contains(estId);
        debugPrint(
          "Checking ${est['establishment_name']} (ID: $estId) -> Favorite: $isFav",
        );
        return isFav;
      }).toList();

      setState(() {
        favoriteEstablishments = favorites;
        isLoading = false;
      });

      debugPrint("✅ Wishlist fetched: ${favorites.length} items");
    } catch (e) {
      debugPrint("❌ Error fetching wishlist: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : favoriteEstablishments.isEmpty
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
                              children: favoriteEstablishments.map((spot) {
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
                                  onRemoveFavorite: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final userId =
                                        prefs.getInt('accountId') ?? 0;
                                    final estId =
                                        int.tryParse(
                                          spot['establishment_id'].toString(),
                                        ) ??
                                        0;

                                    if (userId != 0 && estId != 0) {
                                      await removeUserFavorite(userId, estId);
                                      await fetchFavoritesData();
                                    }
                                  },
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

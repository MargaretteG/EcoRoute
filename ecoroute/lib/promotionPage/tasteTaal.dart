import 'package:ecoroute/api_service.dart';
import 'package:ecoroute/widgets/wishlistCard.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TasteTaalPage extends StatefulWidget {
  const TasteTaalPage({super.key});

  @override
  State<TasteTaalPage> createState() => _TasteTaalPageState();
}

class _TasteTaalPageState extends State<TasteTaalPage> {
  bool isLoading = true;
  Map<String, dynamic>? analyticsData;
  List<Map<String, dynamic>> allEstablishments = [];
  bool isEstablishmentsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasteTaalAnalytics();
    _fetchAllEstablishments();
  }

  Future<void> _fetchAllEstablishments() async {
    try {
      final ests = await fetchAllEstablishments();
      setState(() {
        allEstablishments = ests;
        isEstablishmentsLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching establishments: $e");
    }
  }

  Map<String, dynamic>? getEstablishmentDetails(int estId) {
    try {
      return allEstablishments.firstWhere(
        (est) => est['establishment_id'] == estId,
        orElse: () => {},
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _fetchTasteTaalAnalytics() async {
    try {
      final response = await http.get(
        Uri.parse("https://ecoroute-taal.online/getTasteTaalAnalytics.php"),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            analyticsData = data;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching analytics: $e");
    }
  }

  // Get image from establishment details
  String getImagePath(int estId) {
    final est = getEstablishmentDetails(estId);
    if (est != null && est['images'] != null && est['images'].isNotEmpty) {
      return "https://ecoroute-taal.online/EcoRoute/Includes/Images/tourist-estab/managelisting/${est['images'][0]['imageUrl']}";
    }
    return 'images/image_load.png';
  }

  double getStarRating(int estId) {
    final est = getEstablishmentDetails(estId);
    if (est != null && est['userRating'] != null) {
      return double.tryParse(est['userRating'].toString()) ?? 0.0;
    }
    return 0.0;
  }

  int getEcoRating(int estId) {
    final est = getEstablishmentDetails(estId);
    if (est != null && est['recognitionRating'] != null) {
      return int.tryParse(est['recognitionRating'].toString()) ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || isEstablishmentsLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 46, 4),
        title: const Text(
          "Taste Taal",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Taste the Best of Taal",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 4, 46, 4),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Discover the top-rated and most loved restaurants that showcase Taal’s local flavors and sustainability.",
              style: TextStyle(
                fontSize: 13,
                color: Color.fromARGB(150, 4, 46, 4),
              ),
            ),
            const SizedBox(height: 18),

            // Summary Section
            if (analyticsData?['summary'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Restaurant Analytics",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 4, 46, 4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildSummaryCard(
                    "Total Restaurants",
                    "${analyticsData!['summary']['totalRestaurants']}",
                    Colors.teal,
                    Icons.restaurant,
                  ),
                  _buildSummaryCard(
                    "Eco-rated Restaurants",
                    "${analyticsData!['summary']['ecoRatedRestaurants']} "
                        "(${analyticsData!['summary']['ecoRatedPercentage']}%)",
                    Colors.green,
                    Icons.eco,
                  ),
                  _buildSummaryCard(
                    "Highly Recognized",
                    "${analyticsData!['summary']['highlyRecognized']} "
                        "(${analyticsData!['summary']['highlyRecognizedPercentage']}%)",
                    Colors.amber[700]!,
                    Icons.star,
                  ),
                ],
              ),

            const SizedBox(height: 25),

            // Top 10 Most Pinned Restaurants
            const Text(
              "Top 10 Most Pinned Restaurants",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 4, 46, 4),
              ),
            ),
            const SizedBox(height: 8),
            if (analyticsData?['topPinnedRestaurants'] != null)
              Column(
                children: List.generate(
                  analyticsData!['topPinnedRestaurants'].length,
                  (index) {
                    final restaurant =
                        analyticsData!['topPinnedRestaurants'][index];
                    final estId =
                        int.tryParse(
                          restaurant['establishment_id'].toString(),
                        ) ??
                        0;

                    return WishlistSpotCard(
                      imagePath: getImagePath(estId),
                      name: restaurant['establishmentName'],
                      location: restaurant['address'] ?? "Taal, Batangas",
                      starRating: getStarRating(estId),
                      ecoRating: getEcoRating(estId),
                      cardType: "popular",
                      rank: index + 1,
                      establishmentId: estId,
                      type: "addTravel",
                      showPinIcon: false,
                    );
                  },
                ),
              ),

            const SizedBox(height: 25),

            // Highest Recognition & Eco-Rated
            const Text(
              "Highest Recognition & Eco-Rated Restaurants",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 4, 46, 4),
              ),
            ),
            const SizedBox(height: 8),
            if (analyticsData?['topEcoRated'] != null)
              Column(
                children: List.generate(analyticsData!['topEcoRated'].length, (
                  index,
                ) {
                  final restaurant = analyticsData!['topEcoRated'][index];
                  final estId =
                      int.tryParse(restaurant['establishment_id'].toString()) ??
                      0;

                  return WishlistSpotCard(
                    imagePath: getImagePath(estId),
                    name: restaurant['establishmentName'],
                    location: restaurant['address'] ?? "Taal, Batangas",
                    starRating: getStarRating(estId),
                    ecoRating: getEcoRating(estId),
                    type: "addTravel",
                    cardType: "popular",
                    rank: index + 1,
                    establishmentId: estId,
                    showPinIcon: false,
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(50, 0, 0, 0),
            blurRadius: 6,
            offset: Offset(2, 4),
          ),
        ],
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 4, 46, 4),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
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

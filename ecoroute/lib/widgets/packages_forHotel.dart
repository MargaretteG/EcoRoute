import 'package:flutter/material.dart';

class HotelPackage extends StatefulWidget {
  const HotelPackage({super.key});

  @override
  State<HotelPackage> createState() => _HotelPackageState();
}

class _HotelPackageState extends State<HotelPackage> {
  final List<Map<String, dynamic>> hotelPackages = [
    {
      "name": "Deluxe Room",
      "image": "images/home-photo1-1.jpg",
      "minPax": 1,
      "maxPax": 4,
      "dayRate": 2500.00,
      "nightRate": 3200.00,
    },
    {
      "name": "Suite Room",
      "image": "images/home-photo1-1.jpg",
      "minPax": 2,
      "maxPax": 6,
      "dayRate": 4000.00,
      "nightRate": 5200.00,
    },
    {
      "name": "Family Villa",
      "image": "images/home-photo1-1.jpg",
      "minPax": 4,
      "maxPax": 10,
      "dayRate": 6500.00,
      "nightRate": 8000.00,
    },
  ];
  void _showFullScreenImage(String imagePath) {
    showDialog(
      context: context,
      barrierColor: const Color.fromARGB(217, 0, 0, 0),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack( 
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 25,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: InteractiveViewer(
                      child: Image.asset(imagePath, fit: BoxFit.contain),
                    ),
                  ),
                ],
              ),
            ),
      
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      width: MediaQuery.of(context).size.width,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: hotelPackages.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          final item = hotelPackages[index];

          return Container(
            width: 200,
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black26, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.asset(
                          item["image"],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => _showFullScreenImage(item["image"]),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(107, 0, 0, 0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.fullscreen,
                              size: 18,
                              color: Color.fromARGB(193, 255, 255, 255),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Name
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        item["name"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 3),

                      // Pax input row
                      Row(
                        children: [
                          const Icon(
                            Icons.people,
                            size: 18,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${item["minPax"]}-${item["maxPax"]} pax",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Day & Night rate row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.wb_sunny,
                                  size: 18,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "₱${item["dayRate"].toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.nightlight_round,
                                  size: 18,
                                  color: Colors.blueAccent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "₱${item["nightRate"].toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
  }
}

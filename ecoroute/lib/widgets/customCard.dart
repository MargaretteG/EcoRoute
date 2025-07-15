import 'package:flutter/material.dart';

class TouristSpotCard extends StatefulWidget {
  final String imagePath;
  final String name;
  final String location;
  final int starRating;
  final int ecoRating;
  final Color badgeColor;
  final IconData badgeIcon;

  const TouristSpotCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.location,
    required this.starRating,
    required this.ecoRating,
    required this.badgeColor,
    required this.badgeIcon,
  });

  @override
  State<TouristSpotCard> createState() => _TouristSpotCardState();
}

class _TouristSpotCardState extends State<TouristSpotCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 45),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: widget.badgeColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 10,
            offset: const Offset(6, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Container(
                  color: const Color.fromARGB(255, 4, 46, 4),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(widget.badgeIcon, color: widget.badgeColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.location,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Star Rating
                          Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                Icons.star,
                                size: 14,
                                color: index < widget.starRating
                                    ? Colors.amber
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Eco Leaves
                          Row(
                            children: List.generate(
                              widget.ecoRating,
                              (index) => const Icon(
                                Icons.eco,
                                size: 14,
                                color: Color(0xFF62ED7A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Heart Icon
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

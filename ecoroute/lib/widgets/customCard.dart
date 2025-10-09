import 'package:ecoroute/api_service.dart';
import 'package:ecoroute/widgets/destinationInfoPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TouristSpotCard extends StatefulWidget {
  final String imagePath;
  final String name;
  final String location;
  final double starRating;
  final int ecoRating;
  final IconData badgeIcon;
  final String category;
  final int establishmentId;
  final int userId;
  final String description;
  final String highlightDescription;
  final String phoneNumber;
  final String emailAdd;
  final bool isFavorite;

  const TouristSpotCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.location,
    required this.starRating,
    required this.ecoRating,
    required this.badgeIcon,
    required this.category,
    required this.establishmentId,
    required this.userId,
    required this.description,
    required this.highlightDescription,
    required this.phoneNumber,
    required this.emailAdd,
    required this.isFavorite,
  });

  @override
  State<TouristSpotCard> createState() => _TouristSpotCardState();
}

class _TouristSpotCardState extends State<TouristSpotCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(covariant TouristSpotCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      setState(() {
        isFavorite = widget.isFavorite;
      });
    }
  }

  Future<void> _handleFavoriteTap() async {
    setState(() {
      isFavorite = !isFavorite;
    });

    try {
      await addOrUpdateFavorite(
        userId: widget.userId,
        establishment_id: widget.establishmentId,
        favoriteStatus: isFavorite ? 1 : 0,
      );
    } catch (e) {
      // revert UI if failed
      setState(() {
        isFavorite = !isFavorite;
      });
      debugPrint("Failed to update favorite: $e");
    }
  }

  Color _getEcoColor(int ecoRating) {
    switch (ecoRating) {
      case 1:
        return const Color.fromARGB(255, 0, 123, 223);
      case 2:
        return Colors.purple;
      case 3:
        return Colors.orange;
      case 4:
        return const Color.fromARGB(255, 216, 195, 0);
      case 5:
        return const Color.fromARGB(255, 0, 215, 7);
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case "church":
        return Icons.church;
      case "cultural cite":
        return Icons.museum;
      case "restaurant":
        return Icons.restaurant;
      case "hotel":
        return Icons.hotel;
      case "amusement park":
        return Icons.local_activity;
      case "eco park":
        return Icons.park;
      case "local market":
        return Icons.storefront;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DestinationInfoPage(
              imagePath: widget.imagePath,
              name: widget.name,
              location: widget.location,
              description: widget.description,
              highlights: widget.highlightDescription,
              openingHoursWeekdays: "9:00 AM - 5:00 PM",
              openingHoursWeekends: "8:00 AM - 6:00 PM",
              contact: widget.phoneNumber,
              email: widget.emailAdd,
              ecoRating: widget.ecoRating,
              starRating: widget.starRating,
              category: widget.category,
              establishmentId: widget.establishmentId,
              userId: widget.userId,
              isFavorite: widget.isFavorite,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _getEcoColor(widget.ecoRating), width: 3),
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
                    aspectRatio: 20 / 9,
                    child: Image.network(
                      widget.imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  Container(
                    color: _getEcoColor(widget.ecoRating),
                    child: Container(
                      color: const Color.fromARGB(211, 255, 255, 255),
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // category indicator
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _getEcoColor(widget.ecoRating),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  _getCategoryIcon(widget.category),
                                  color: _getEcoColor(widget.ecoRating),
                                  size: 18,
                                ),
                              ),

                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.name,
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 4, 46, 4),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.location,
                                      style: const TextStyle(
                                        color: Color.fromARGB(150, 4, 46, 4),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  if (index < widget.starRating.floor()) {
                                    return const Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.amber,
                                    );
                                  } else if (index < widget.starRating &&
                                      widget.starRating % 1 != 0) {
                                    return const Icon(
                                      Icons.star_half,
                                      size: 14,
                                      color: Colors.amber,
                                    );
                                  } else {
                                    return const Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.grey,
                                    );
                                  }
                                }),
                              ),

                              const SizedBox(width: 10),
                              if (widget.ecoRating > 0)
                                Row(
                                  children: List.generate(
                                    5,
                                    (index) => Icon(
                                      Icons.eco,
                                      size: 14,
                                      color: index < widget.ecoRating
                                          ? const Color.fromARGB(
                                              255,
                                              0,
                                              154,
                                              26,
                                            )
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // badge icon
              if (widget.ecoRating > 0)
                Positioned(
                  top: 10,
                  left: 10,
                  child: CircleAvatar(
                    backgroundColor: _getEcoColor(
                      widget.ecoRating,
                    ).withOpacity(0.8),
                    radius: 20,
                    child: Icon(
                      widget.badgeIcon,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              // Heart Icon
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();

                    _handleFavoriteTap();
                  },
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: isFavorite ? 15 : 0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    builder: (context, glow, child) {
                      return CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color.fromARGB(
                          145,
                          230,
                          230,
                          230,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                          size: 20,
                          shadows: isFavorite
                              ? [
                                  Shadow(
                                    color: Colors.red.withOpacity(0.8),
                                    blurRadius: glow,
                                  ),
                                ]
                              : [],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

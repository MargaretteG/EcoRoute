import 'package:ecoroute/widgets/popup.dart';
import 'package:flutter/material.dart';
import 'package:ecoroute/api_service.dart'; // your API functions
import 'package:shared_preferences/shared_preferences.dart';

class WishlistSpotCard extends StatefulWidget {
  final String imagePath;
  final String name;
  final String location;
  final double starRating;
  final int ecoRating;
  final String? category;
  final String type;
  final String cardType;
  final int? rank;
  final double? distanceKm;
  final VoidCallback? onPin;
  final int? establishmentId;
  final Future<void> Function()? onRemoveFavorite;
  final bool showPinIcon;
  final double? distanceMeters;

  final String? description;
  final String? highlightDescription;
  final String? phoneNumber;
  final String? emailAdd;
  final int? userId;
  final bool isFavorite;

  const WishlistSpotCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.location,
    required this.starRating,
    required this.ecoRating,
    this.category,
    this.type = "main",
    this.cardType = "main",
    this.rank,
    this.distanceKm,
    this.distanceMeters,
    this.onPin,
    this.onRemoveFavorite,
    required this.establishmentId,
    this.showPinIcon = true,

    this.description,
    this.highlightDescription,
    this.phoneNumber,
    this.emailAdd,
    this.userId,
    this.isFavorite = true,
  });

  @override
  State<WishlistSpotCard> createState() => _WishlistSpotCardState();
}

class _WishlistSpotCardState extends State<WishlistSpotCard> {
  bool isFavorite = true;
  bool isPinned = false;

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

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return const Color.fromARGB(255, 119, 78, 63);
      default:
        return Colors.green;
    }
  }

  //For Pins
  Future<void> _addNearbyPin() async {
    if (widget.establishmentId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('accountId') ?? 0;

      if (userId == 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in")));
        return;
      }

      final success = await addNearbyPin(
        userId: userId,
        establishmentId: widget.establishmentId!,
      );

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Pinned successfully!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to pin. Try again.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: _getEcoColor(widget.ecoRating),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(99, 0, 0, 0),
                blurRadius: 6,
                offset: const Offset(2, 5),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _getEcoColor(widget.ecoRating),
                width: 2,
              ),
              color: const Color.fromARGB(229, 255, 255, 255),
            ),
            child: Row(
              children: [
                // Left Image
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(8),
                  ),
                  child: Image.network(
                    widget.imagePath,
                    width: screenWidth * 0.32,
                    height: screenWidth * 0.25,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        width: screenWidth * 0.32,
                        height: screenWidth * 0.25,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'images/image_load.png',
                        width: screenWidth * 0.32,
                        height: screenWidth * 0.25,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),

                // Right Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + Action Icon
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 4, 46, 4),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Favorite/Pin Icon
                            if (widget.showPinIcon)
                              GestureDetector(
                                onTap: () async {
                                  if (widget.type == "main" && isFavorite) {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => PopUp(
                                        title: "Remove from Wishlist",
                                        headerIcon: Icons.warning_amber_rounded,
                                        description:
                                            "Do you want to remove this tourist spot from your favorites?",
                                        confirmText: "Remove",
                                        hasTextField: false,
                                        onConfirm: () {
                                          Navigator.pop(context, true);
                                        },
                                      ),
                                    );

                                    if (confirm == true &&
                                        widget.onRemoveFavorite != null) {
                                      await widget.onRemoveFavorite!();
                                      if (mounted)
                                        setState(() => isFavorite = false);
                                    }
                                  } else if (widget.type == "main") {
                                    setState(() {
                                      isFavorite = !isFavorite;
                                    });
                                  } else {
                                    isPinned = !isPinned;
                                    if (isPinned) {
                                      if (widget.cardType == "addTravel") {
                                        await _addNearbyPin();
                                      }
                                      if (widget.onPin != null) {
                                        widget.onPin!();
                                      }
                                    }
                                  }
                                },
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    begin: 0,
                                    end:
                                        (widget.type == "main" && isFavorite) ||
                                            (widget.type == "addTravel" &&
                                                isPinned)
                                        ? 15
                                        : 0,
                                  ),
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOut,
                                  builder: (context, glow, child) {
                                    return CircleAvatar(
                                      radius: 14,
                                      backgroundColor: const Color.fromARGB(
                                        55,
                                        152,
                                        152,
                                        152,
                                      ),
                                      child: Icon(
                                        widget.type == "main"
                                            ? (isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border)
                                            : (isPinned
                                                  ? Icons.push_pin
                                                  : Icons.push_pin_outlined),
                                        color: widget.type == "main"
                                            ? (isFavorite
                                                  ? Colors.red
                                                  : Colors.white)
                                            : (isPinned
                                                  ? Colors.red
                                                  : Colors.white),
                                        size: 16,
                                        shadows:
                                            (widget.type == "main" &&
                                                    isFavorite) ||
                                                (widget.type == "addTravel" &&
                                                    isPinned)
                                            ? [
                                                Shadow(
                                                  color: Colors.red.withOpacity(
                                                    0.8,
                                                  ),
                                                  blurRadius: glow,
                                                ),
                                              ]
                                            : [],
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 3),

                        // Location
                        Text(
                          widget.location,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color.fromARGB(150, 4, 46, 4),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 5),

                        // Ratings Row
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
                            const SizedBox(width: 6),
                            if (widget.ecoRating > 0)
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    Icons.eco,
                                    size: 11,
                                    color: index < widget.ecoRating
                                        ? const Color.fromARGB(255, 0, 154, 26)
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
          ),
        ),

        // Badge for Popular
        if (widget.cardType == "popular" && widget.rank != null)
          Positioned(
            top: -5,
            left: 0,
            child: Container(
              width: 32,
              height: 42,
              decoration: BoxDecoration(
                color: _getRankColor(widget.rank!),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _getRankColor(widget.rank!).withOpacity(0.9),
                    blurRadius: 9,
                    spreadRadius: 1.5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.rank!.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        // Badge for nearby
        if (widget.cardType == "nearby" && widget.distanceMeters != null)
          Positioned(
            top: -5,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    widget.distanceMeters! < 1000
                        ? "${widget.distanceMeters!.toInt()} m"
                        : "${(widget.distanceMeters! / 1000).toStringAsFixed(1)} km",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

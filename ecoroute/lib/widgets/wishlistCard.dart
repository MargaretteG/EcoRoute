import 'package:ecoroute/widgets/popup.dart';
import 'package:flutter/material.dart';

class WishlistSpotCard extends StatefulWidget {
  final String imagePath;
  final String name;
  final String location;
  final double starRating;
  final int ecoRating;
  final String? category;
  final String type;
  final VoidCallback? onPin;

  // ✅ New callback
  final Future<void> Function()? onRemoveFavorite;

  const WishlistSpotCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.location,
    required this.starRating,
    required this.ecoRating,
    this.category,
    this.type = "main",
    this.onPin,
    this.onRemoveFavorite,
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
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
          border: Border.all(color: _getEcoColor(widget.ecoRating), width: 2),

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

                        GestureDetector(
                          onTap: () async {
                            if (widget.type == "main" && isFavorite) {
                              // ✅ Show remove favorite popup
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
                                if (mounted) {
                                  setState(() => isFavorite = false);
                                }
                              }
                            } else if (widget.type == "main") {
                              setState(() {
                                isFavorite = !isFavorite;
                              });
                            } else {
                              isPinned = !isPinned;
                              if (isPinned && widget.onPin != null) {
                                widget.onPin!();
                              }
                            }
                          },

                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0,
                              end:
                                  (widget.type == "main" && isFavorite) ||
                                      (widget.type == "addTravel" && isPinned)
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
                                      ? (isFavorite ? Colors.red : Colors.white)
                                      : (isPinned ? Colors.red : Colors.white),
                                  size: 16,
                                  shadows:
                                      (widget.type == "main" && isFavorite) ||
                                          (widget.type == "addTravel" &&
                                              isPinned)
                                      ? [
                                          Shadow(
                                            color: (widget.type == "main")
                                                ? Colors.red.withOpacity(0.8)
                                                : Colors.red.withOpacity(0.8),
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
    );
  }
}

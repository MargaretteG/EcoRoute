import 'package:ecoroute/api_service.dart';
import 'package:flutter/material.dart';

class TravelerReviews extends StatefulWidget {
  final int establishmentId; // <-- add this

  const TravelerReviews({
    super.key,
    required this.establishmentId, // <-- required parameter
  });

  @override
  State<TravelerReviews> createState() => _TravelerReviewsState();
}

class _TravelerReviewsState extends State<TravelerReviews> {
  List<Map<String, dynamic>> reviews = [];
  final Map<int, bool> expandedMap = {};
  bool isLoading = true;

  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    final estId = widget.establishmentId;
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      final establishments = await fetchAllEstablishments();
      final est = establishments.firstWhere(
        (e) => e['establishment_id'] == widget.establishmentId,
        orElse: () => {},
      );

      final userRatings = est['userRatings'] as List<dynamic>? ?? [];

      List<Map<String, dynamic>> tempReviews = [];

      for (var rating in userRatings) {
        final userIdRaw = rating['user_id'];
        final int userId = userIdRaw is int
            ? userIdRaw
            : int.tryParse(userIdRaw.toString()) ?? 0;

        // Fetch user info
        final user = await apiService.fetchUserById(userId: userId);

        tempReviews.add({
          'username':
              user['userName'] ?? '${user['firstName']} ${user['lastName']}',
          'profilePic':
              user['profilePic'] ??
              'https://ecoroute-taal.online/images/default_profile.png',
          'review': rating['ratingFeedback'] ?? '',
          'rating': rating['ratingStar'] ?? 0.0,
        });
      }

      setState(() {
        reviews = tempReviews;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(height: 50);
    }

    if (reviews.isEmpty) {
      return const SizedBox(height: 0);
    }

    return Column(
      children: [
        //Header
        Padding(
          padding: EdgeInsetsGeometry.only(left: 20),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vertical line
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Color(0xFF64F67A),
                    ),
                    margin: const EdgeInsets.only(right: 8),
                  ),

                  // Subtitle text
                  Text(
                    "Travel Reviews",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF011901),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        //Reviews
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
          child: SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: reviews.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, index) {
                final review = reviews[index];
                final isExpanded = expandedMap[index] ?? false;

                return Container(
                  width: 260,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black26, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile + username
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(review["profilePic"]),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            review["username"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Review text with see more/less
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review["review"],
                              maxLines: isExpanded ? null : 3,
                              overflow: isExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.3,
                                color: Colors.black87,
                              ),
                            ),
                            if (review["review"].length > 80)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    expandedMap[index] = !isExpanded;
                                  });
                                },
                                child: Text(
                                  isExpanded ? "See less" : "See more",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Rating stars
                      Row(
                        children: List.generate(5, (index) {
                          final rating = (review["rating"] is double)
                              ? review["rating"] as double
                              : double.tryParse(review["rating"].toString()) ??
                                    0.0;

                          if (index < rating.floor()) {
                            // Full star
                            return const Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.amber,
                            );
                          } else if (index < rating && rating % 1 != 0) {
                            // Half star
                            return const Icon(
                              Icons.star_half,
                              size: 18,
                              color: Colors.amber,
                            );
                          } else {
                            // Empty star
                            return const Icon(
                              Icons.star_border,
                              size: 18,
                              color: Colors.grey,
                            );
                          }
                        }),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class TravelerReviews extends StatefulWidget {
  const TravelerReviews({super.key});

  @override
  State<TravelerReviews> createState() => _TravelerReviewsState();
}

class _TravelerReviewsState extends State<TravelerReviews> {
  // static sample reviews (replace later with DB data)
  final List<Map<String, dynamic>> reviews = [
    {
      "username": "JohnD",
      "profilePic": "images/profile1.png",
      "review":
          "Amazing place! The view is breathtaking and the people are very friendly. Definitely worth visiting again!",
      "rating": 5,
    },
    {
      "username": "Maria_23",
      "profilePic": "images/profile2.png",
      "review":
          "The location is nice but can get crowded during weekends. Food options nearby are limited, but overall still enjoyable.",
      "rating": 4,
    },
    {
      "username": "Alex",
      "profilePic": "images/profile3.png",
      "review":
          "Not what I expected, but still had a decent experience. The weather was not great during my visit.",
      "rating": 3,
    },
  ];

  // Track which reviews are expanded
  final Map<int, bool> expandedMap = {};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
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
                        backgroundImage: AssetImage(review["profilePic"]),
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
                    children: List.generate(
                      5,
                      (starIndex) => Icon(
                        starIndex < review["rating"]
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

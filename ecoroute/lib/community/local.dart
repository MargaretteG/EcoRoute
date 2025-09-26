import 'package:ecoroute/widgets/usersPostContainer.dart';
import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/emptyPage.dart';

class LocalPage extends StatelessWidget {
  const LocalPage({super.key});

  static const List<Map<String, dynamic>> LocalPosts = const [
    {
      "profilePicUrl": "https://i.pravatar.cc/150?img=1",
      "username": "Traveler_One",
      "date": "Sept 13, 2025",
      "caption": "What a beautiful view of Taal 🌋✨",
      "images": [
        "https://picsum.photos/id/1018/600/400",
        "https://picsum.photos/id/1015/600/400",
        "https://picsum.photos/id/1019/600/400",
      ],
      "isFollowing": false,
    },
    {
      "profilePicUrl": "https://i.pravatar.cc/150?img=2",
      "username": "NatureLover",
      "date": "Sept 10, 2025",
      "caption": "Hiking adventures 🌿⛰️",
      "images": ["https://picsum.photos/id/1025/600/400"],
      "isFollowing": true,
    },
  ];

  static bool get hasPosts => LocalPosts.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (LocalPosts.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 30),
          EmptyState(
            imagePath: "images/22.png",
            title: "No Local Postsss",
            description: "Be the first to share something with your community!",
          ),
        ],
      );
    } else {
      return Column(
        children: [
          SizedBox(height: 5),
          ...LocalPosts.map(
            (post) => CommunityPost(
              profilePicUrl: post["profilePicUrl"],
              username: post["username"],
              date: post["date"],
              caption: post["caption"],
              images: List<String>.from(post["images"]),
              isFollowing: post["isFollowing"],
            ),
          ),
          // ListView.builder(
          //   padding: const EdgeInsets.only(top: 20, bottom: 80),
          //   itemCount: mockPosts.length,
          //   itemBuilder: (context, index) {
          //     final post = mockPosts[index];
          //     return CommunityPost(
          //       profilePicUrl: post["profilePicUrl"],
          //       username: post["username"],
          //       date: post["date"],
          //       caption: post["caption"],
          //       images: List<String>.from(post["images"]),
          //       isFollowing: post["isFollowing"],
          //     );
          //   }, 
          // ),
          SizedBox(height: 80),
        ],
      );
    }
  }
}

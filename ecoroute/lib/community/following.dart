import 'package:ecoroute/widgets/emptyPage.dart';
import 'package:flutter/material.dart';

class FollowingPage extends StatelessWidget {
  const FollowingPage({super.key});

  static const List<String> followingPosts = const [];
  static bool get hasPosts => followingPosts.isNotEmpty;
  @override
  Widget build(BuildContext context) {
    if (followingPosts.isEmpty) { 
      return Column(
        children: [
          SizedBox(height: 30),
          EmptyState(
            imagePath: "images/17.png",
            title: "No Following Activity",
            description: "Follow travelers to see their adventures here!",
            centerVertically: false,
          ),
        ],
      );
    } else {
      return ListView.builder(
        itemCount: followingPosts.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(followingPosts[index]));
        },
      );
    }
  }
}

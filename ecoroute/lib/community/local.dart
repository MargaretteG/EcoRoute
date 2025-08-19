import 'package:ecoroute/widgets/emptyPage.dart';
import 'package:flutter/material.dart';

class LocalPage extends StatelessWidget {
  const LocalPage({super.key});

  final List<String> localPosts = const []; // simulate empty

  @override
  Widget build(BuildContext context) {
    if (localPosts.isEmpty) {
      return Column(
        children: [
          SizedBox(height: 30),
          EmptyState(
            imagePath: "images/22.png",
            title: "No Local Posts",
            description: "Be the first to share something with your community!",
          ),
        ],
      );
    } else {
      return ListView.builder(
        itemCount: localPosts.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(localPosts[index]));
        },
      );
    }
  }
}

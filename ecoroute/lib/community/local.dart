import 'package:ecoroute/widgets/imageLoader.dart';
import 'package:ecoroute/widgets/usersPostContainer.dart';
import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/emptyPage.dart';
import 'package:ecoroute/api_service.dart';

class LocalPage extends StatefulWidget {
  const LocalPage({super.key});

  static bool hasPosts = false;

  @override
  State<LocalPage> createState() => _LocalPageState();
}

class _LocalPageState extends State<LocalPage> {
  List<Map<String, dynamic>> communityPosts = [];
  bool isLoading = true;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _loadOnce();
  }

  void _loadOnce() {
    if (!_hasLoadedOnce) {
      _hasLoadedOnce = true;
      loadCommunityPosts();
    }
  }

  Future<void> loadCommunityPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final posts = await getAllCommunityPosts();

      if (!mounted) return;

      // Ensure no duplicates
      final uniquePosts = {
        for (var post in posts) post['communityPost_id']: post,
      }.values.toList();

      setState(() {
        communityPosts = uniquePosts;
        isLoading = false;

        LocalPage.hasPosts = communityPosts.isNotEmpty;
      });
    } catch (e) {
      debugPrint("Error loading community posts: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
        LocalPage.hasPosts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 0),
        padding: const EdgeInsets.symmetric(vertical: 10),
        height: 800,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const FlickerImageLoader(imagePath: "images/22.png"),
            const SizedBox(height: 20),
            const Text(
              "Loading community posts...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    if (communityPosts.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 0),
        padding: const EdgeInsets.symmetric(vertical: 10),
        height: 800,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 30),
            EmptyState(
              imagePath: "images/22.png",
              title: "No Community Posts Yet",
              description:
                  "Be the first to share something with your community!",
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.all(0),
            child: Column(
              children: communityPosts.map((post) {
                return CommunityPost(
                  key: ValueKey(post['communityPost_id']),
                  communityPostId: int.parse(
                    post['communityPost_id'].toString(),
                  ),
                  userId: int.parse(post['user_id'].toString()),
                  profilePicUrl:
                      "https://ecoroute-taal.online/uploads/profile_pics/${post['ProfilePic']}",
                  username: post['userName'],
                  date: post['dateCreated'],
                  caption: post['postCaption'],
                  images: List<String>.from(post['postImages'] ?? []),
                  isFollowing: false,
                  likesCount: post['likesCount'],
                  commentsCount: post['commentCount'],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

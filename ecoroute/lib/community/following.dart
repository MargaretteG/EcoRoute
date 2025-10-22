import 'package:ecoroute/widgets/imageLoader.dart';
import 'package:ecoroute/widgets/usersPostContainer.dart';
import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/emptyPage.dart';
import 'package:ecoroute/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  static bool hasPosts = false;

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  List<Map<String, dynamic>> followingPosts = [];
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
      loadFollowingPosts();
    }
  }

  Future<void> loadFollowingPosts() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final accountId = prefs.getInt('accountId') ?? 0;

      // Fetch following users
      final followersData = await fetchFollowersFollowing(accountId);
      final followingList = followersData['following'] ?? [];

      // Correct: use 'user_id' from PHP response
      final followingIds = followingList
          .map<int>((user) => int.parse(user['user_id'].toString()))
          .toList();

      // Fetch all posts
      final allPosts = await getAllCommunityPosts();

      if (!mounted) return;

      // Filter posts only from followed users
      final filteredPosts = allPosts
          .where(
            (post) =>
                followingIds.contains(int.parse(post['user_id'].toString())),
          )
          .toList();

      // Remove duplicates
      final uniquePosts = {
        for (var post in filteredPosts) post['communityPost_id']: post,
      }.values.toList();

      if (!mounted) return;

      setState(() {
        followingPosts = uniquePosts;
        isLoading = false;
        FollowingPage.hasPosts = followingPosts.isNotEmpty;
      });
    } catch (e) {
      debugPrint("Error loading following posts: $e");
      if (!mounted) return;

      setState(() {
        isLoading = false;
        FollowingPage.hasPosts = false;
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
            const FlickerImageLoader(imagePath: "images/17.png"),
            const SizedBox(height: 20),
            const Text(
              "Loading following posts...",
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

    if (followingPosts.isEmpty) {
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
              imagePath: "images/17.png",
              title: "No Following Activity",
              description: "Follow travelers to see their adventures here!",
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
              children: followingPosts.map((post) {
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
                  isFollowing: true,
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

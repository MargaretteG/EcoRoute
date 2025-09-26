import 'package:ecoroute/widgets/usersPostContainer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecoroute/api_service.dart';
import 'package:ecoroute/widgets/emptyPage.dart';

class UserProfilePosts extends StatefulWidget {
  final String username;
  final String profilePicUrl;

  const UserProfilePosts({
    Key? key,
    required this.username,
    required this.profilePicUrl,
  }) : super(key: key);

  @override
  UserProfilePostsState createState() => UserProfilePostsState();
}

class UserProfilePostsState extends State<UserProfilePosts> {
  List<Map<String, dynamic>> userPosts = [];
  bool isLoading = true;
  bool _hasLoadedOnce = false; // Prevent infinite reload

  @override
  void initState() {
    super.initState();
    _loadOnce();
  }

  // Ensures we fetch posts only once per widget lifecycle
  void _loadOnce() {
    if (!_hasLoadedOnce) {
      _hasLoadedOnce = true;
      loadUserPosts();
    }
  }

  Future<void> loadUserPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final accountId = prefs.getInt('accountId') ?? 0;
      if (accountId == 0) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final posts = await ApiService().getUserPosts(accountId: accountId);

      // Only update if the widget is still mounted
      if (!mounted) return;

      // Ensure posts are unique by communityPost_id
      final uniquePosts = {
        for (var post in posts) post['communityPost_id']: post,
      }.values.toList();

      setState(() {
        userPosts = uniquePosts;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (isLoading) {
    //   return const Center(child: CircularProgressIndicator());
    // }
    if (isLoading) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 7),
        padding: const EdgeInsets.symmetric(vertical: 10),
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: userPosts.isEmpty
            ? Colors.white
            : const Color.fromARGB(220, 232, 255, 232),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: userPosts.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  EmptyState(
                    imagePath: "images/17.png",
                    title: "No Posts Yet",
                    description:
                        "Your posts will appear here once you share them!",
                    centerVertically: false,
                  ),
                  SizedBox(height: 50),
                ],
              ),
            )
          : Column(
              children: [
                Column(
                  children: userPosts.map((post) {
                    return CommunityPost(
                      key: ValueKey(
                        post['communityPost_id'],
                      ), // optional but safer
                      profilePicUrl: widget.profilePicUrl,
                      username: widget.username,
                      date: post['dateCreated'] ?? "",
                      caption: post['postCaption'] ?? "",
                      images: List<String>.from(post['postImages'] ?? []),
                      isFollowing: false,
                    );
                  }).toList(),
                ),
                SizedBox(height: 80),
              ],
            ),
    );
  }
}

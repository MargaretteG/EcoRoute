import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecoroute/api_service.dart';
import 'package:ecoroute/widgets/usersPostContainer.dart';
import 'package:ecoroute/widgets/imageLoader.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MiniProfilePopup extends StatefulWidget {
  final int userId; // The user whose profile we want to display

  const MiniProfilePopup({super.key, required this.userId});

  @override
  State<MiniProfilePopup> createState() => _MiniProfilePopupState();
}

class _MiniProfilePopupState extends State<MiniProfilePopup> {
  Map<String, dynamic>? _user;
  bool _loading = true;
  String? _error;
  int followersCount = 0;
  int followingCount = 0;
  bool isFollowing = false;
  List<Map<String, dynamic>> userPosts = [];

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadMiniProfile();
  }

  Future<void> _loadMiniProfile() async {
    try {
      final userData = await _apiService.fetchUserById(userId: widget.userId);

      final followData = await fetchFollowersFollowing(widget.userId);
      final followers = followData['followers'] ?? [];
      final following = followData['following'] ?? [];

      final prefs = await SharedPreferences.getInstance();
      final loggedInId = prefs.getInt('accountId') ?? 0;
      isFollowing = followers.any((f) => f['user_id'] == loggedInId);

      final allPosts = await getAllCommunityPosts();
      final posts = allPosts
          .where(
            (post) => int.parse(post['user_id'].toString()) == widget.userId,
          )
          .toList();

      setState(() {
        _user = userData;
        followersCount = followers.length;
        followingCount = following.length;
        userPosts = posts;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedInId = prefs.getInt('accountId') ?? 0;

    try {
      if (isFollowing) {
        await unfollowUser(followerId: loggedInId, followingId: widget.userId);
      } else {
        await followUser(followerId: loggedInId, followingId: widget.userId);
      }

      setState(() {
        isFollowing = !isFollowing;
        followersCount += isFollowing ? 1 : -1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating follow status: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(vertical: 75, horizontal: 15),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: _loading
          ? Container(
              height: 300,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(height: 30),
                  FlickerImageLoader(imagePath: "images/18.png"),
                  SizedBox(height: 20),
                  Text(
                    "Loading profile...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            )
          : _error != null
          ? SizedBox(height: 300, child: Center(child: Text("Error: $_error")))
          : Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,

                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                              _user?['profilePic'] ?? '',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _user?['userName'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    followersCount.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text('Followers'),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Column(
                                children: [
                                  Text(
                                    followingCount.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text('Following'),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _toggleFollow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFollowing
                                  ? Colors.grey
                                  : Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              isFollowing ? "Following" : "Follow",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 20),
                    userPosts.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 10),
                                Text("No posts yet"),
                              ],
                            ),
                          )
                        : Column(
                            children: userPosts.map((post) {
                              return CommunityPost(
                                key: ValueKey(post['communityPost_id']),
                                communityPostId: int.parse(
                                  post['communityPost_id'].toString(),
                                ),
                                userId: int.parse(post['user_id'].toString()),
                                profilePicUrl: _user?['profilePic'] ?? '',
                                username: post['userName'],
                                date: post['dateCreated'],
                                caption: post['postCaption'],
                                images: List<String>.from(
                                  post['postImages'] ?? [],
                                ),
                                isFollowing: false,
                                likesCount: post['likesCount'],
                                commentsCount: post['commentCount'],
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
    );
  }
}

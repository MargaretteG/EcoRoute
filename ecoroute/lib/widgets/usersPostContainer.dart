import 'package:ecoroute/api_service.dart';
import 'package:ecoroute/widgets/commentPopup.dart';
import 'package:ecoroute/widgets/imageLoader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecoroute/widgets/imageLoader.dart';
import 'package:intl/intl.dart';

class CommunityPost extends StatefulWidget {
  final int communityPostId;
  final int userId;
  final String profilePicUrl;
  final String username;
  final String date;
  final String caption;
  final List<String> images;
  final bool isFollowing;
  final int? likesCount;

  const CommunityPost({
    Key? key,
    required this.communityPostId,
    required this.userId,
    required this.profilePicUrl,
    required this.username,
    required this.date,
    required this.caption,
    required this.images,
    this.isFollowing = false,
    this.likesCount,
  }) : super(key: key);

  @override
  _CommunityPostState createState() => _CommunityPostState();
}

class _CommunityPostState extends State<CommunityPost> {
  bool isLiked = false;
  bool isFollowing = false;
  int currentPage = 0;
  late PageController _pageController;
  late int likesCount;
  @override
  void initState() {
    super.initState();
    isFollowing = widget.isFollowing;
    likesCount = widget.likesCount ?? 0;
    _pageController = PageController();
    _checkIfLiked();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return '${difference.inSeconds}s ago';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 10) {
        return '${difference.inHours}h ago';
      } else if (difference.inHours < 24) {
        return DateFormat('hh:mm a').format(dateTime);
      } else {
        return DateFormat('MMM d, yyyy hh:mm a').format(dateTime);
      }
    } catch (e) {
      return dateString;
    }
  }

  //liked posts fetching
  Future<void> _checkIfLiked() async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getInt('accountId') ?? 0;

    try {
      final likedPosts = await fetchUserLikedPosts(accountId);
      setState(() {
        isLiked = likedPosts.contains(widget.communityPostId);
      });
    } catch (e) {
      debugPrint("Failed to fetch liked posts: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 10,
                offset: const Offset(6, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP BAR
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(widget.profilePicUrl),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            _formatDate(widget.date),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        setState(() {
                          if (value == 'follow') {
                            isFollowing = true;
                          } else if (value == 'unfollow') {
                            isFollowing = false;
                          }
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                            value: isFollowing ? 'unfollow' : 'follow',
                            child: Text(isFollowing ? "Unfollow" : "Follow"),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
              ),

              // CAPTION
              if (widget.caption.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    widget.caption,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),

              const SizedBox(height: 8),

              // IMAGE CAROUSEL
              SizedBox(
                height: 240,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: widget.images.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                      itemBuilder: (_, index) {
                        return ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            widget.images[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const FlickerPlaceholder(); // ✅ works now
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const FlickerPlaceholder(); // ✅ works here too
                            },
                          ),
                        );
                      },
                    ),
                    if (currentPage > 0)
                      Positioned(
                        left: 10,
                        top: 100,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    if (currentPage < widget.images.length - 1)
                      Positioned(
                        right: 10,
                        top: 100,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    if (widget.images.length > 1)
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.images.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: currentPage == index ? 8 : 6,
                              height: currentPage == index ? 8 : 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentPage == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // LIKE + COMMENT
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        setState(() {
                          isLiked = !isLiked;
                          likesCount += isLiked ? 1 : -1;
                          if (likesCount < 0) likesCount = 0;
                        });

                        try {
                          final prefs = await SharedPreferences.getInstance();
                          final accountId = prefs.getInt('accountId') ?? 0;

                          final status = await togglePostLike(
                            userId: accountId,
                            communityPostId: widget.communityPostId,
                          );

                          if (status == 'liked' && !isLiked) {
                            setState(() => likesCount++);
                          } else if (status == 'unliked' && isLiked) {
                            setState(() => likesCount--);
                          }
                        } catch (e) {
                          setState(() {
                            // Revert on error
                            isLiked = !isLiked;
                            likesCount += isLiked ? 1 : -1;
                            if (likesCount < 0) likesCount = 0;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to like post: $e')),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              key: ValueKey<bool>(isLiked),
                              color: isLiked ? Colors.red : Colors.grey,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Like • $likesCount",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final accountId = prefs.getInt('accountId') ?? 0;
                        final profilePic =
                            prefs.getString('profilePicUrl') ?? '';

                        showDialog(
                          context: context,
                          builder: (_) => CommentPopup(
                            communityPostId: widget.communityPostId,
                            comments: [],
                            currentUserProfilePic: profilePic.isNotEmpty
                                ? "https://ecoroute-taal.online/uploads/profile_pics/$profilePic"
                                : null,
                            onSendComment: (commentText) async {
                              await addCommunityPostComment(
                                accountId: accountId,
                                communityPostId: widget.communityPostId,
                                commentContent: commentText,
                              );
                              setState(() {}); // reload to show new comment
                            },
                          ),
                        );
                      },
                      child: Row(
                        children: const [
                          Icon(
                            Icons.mode_comment_outlined,
                            size: 19,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 5),
                          Text("Comment", style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ],
    );
  }
}

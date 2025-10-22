import 'package:ecoroute/api_service.dart';
import 'package:ecoroute/widgets/imageLoader.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class CommentPopup extends StatefulWidget {
  final int communityPostId;
  final List<Map<String, dynamic>> comments;
  final Function(String commentText) onSendComment;
  final String? currentUserProfilePic;

  const CommentPopup({
    super.key,
    required this.communityPostId,
    required this.comments,
    required this.onSendComment,
    this.currentUserProfilePic,
  });

  @override
  State<CommentPopup> createState() => _CommentPopupState();
}

class _CommentPopupState extends State<CommentPopup> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSending = false;
  final _apiService = ApiService();

  late List<Map<String, dynamic>> _comments;

  @override
  void initState() {
    super.initState();
    _comments = [];
    _loadProfile();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() => _loading = true);

    try {
      final fetchedComments = await fetchCommunityPostComments(
        communityPostId: widget.communityPostId,
      );

      final now = DateTime.now();

      String formatTimeAgo(DateTime dateTime) {
        final difference = now.difference(dateTime);
        if (difference.inSeconds < 60) return '${difference.inSeconds}s ago';
        if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
        if (difference.inHours < 24) return '${difference.inHours}h ago';
        return DateFormat('MMM d, yyyy hh:mm a').format(dateTime);
      }

      final formattedComments = fetchedComments.map((comment) {
        final timestamp = comment['dateCommented'] != null
            ? formatTimeAgo(DateTime.parse(comment['dateCommented']))
            : '';
        return {
          'user': comment['userName'] ?? 'Anonymous',
          'comment': comment['commentContent'] ?? '',
          'profilePic': comment['profilePic'] != null
              ? "https://ecoroute-taal.online/uploads/profile_pics/${comment['profilePic']}"
              : null,
          'timestamp': timestamp,
        };
      }).toList();

      _safeSetState(() {
        _comments = formattedComments;
        _loading = false;
      });
    } catch (e) {
      _safeSetState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Map<String, dynamic>? _user;
  bool _loading = true;
  String? _error;
  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountId = prefs.getInt("accountId");
      if (accountId == null) {
        throw Exception("No accountId saved inn preferences");
      }
      final userData = await _apiService.fetchProfile(accountId: accountId);

      _safeSetState(() {
        _user = userData;
        _loading = false;
      });
    } catch (e) {
      _safeSetState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HEADER
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF011901),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.comment, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w100,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ],
            ),
          ),

          // COMMENTS LIST / LOADING
          Expanded(
            child: _loading
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FlickerImageLoader(imagePath: "images/21.png"),
                            const SizedBox(height: 10),
                            const Text(
                              "Loading comments...",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : _comments.isEmpty
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("images/21.png", height: 200),
                            const SizedBox(height: 10),
                            const Text(
                              "No comments yet",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF4B2F34),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey[300],
                              child: ClipOval(
                                child: comment['profilePic'] != null
                                    ? CachedNetworkImage(
                                        imageUrl: comment['profilePic'],
                                        placeholder: (context, url) =>
                                            Image.asset(
                                              'images/profile_picture.png',
                                              fit: BoxFit.cover,
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                              'images/profile_picture.png',
                                              fit: BoxFit.cover,
                                            ),
                                        width: 36,
                                        height: 36,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'images/profile_picture.png',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFF6F6F6,
                                  ).withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          comment['user'] ?? 'Anonymous',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        if (comment['timestamp'] != null)
                                          Text(
                                            comment['timestamp'],
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comment['comment'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF333333),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // INPUT SECTION
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage:
                        (_user != null &&
                            _user!['profilePic'] != null &&
                            _user!['profilePic'].toString().isNotEmpty)
                        ? NetworkImage(
                            "https://ecoroute-taal.online/uploads/profile_pics/${_user!['profilePic']}",
                          )
                        : const AssetImage('images/profile_picture.png')
                              as ImageProvider,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F6F6),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _commentController,
                        minLines: 1,
                        maxLines: 3,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendComment(),
                        decoration: const InputDecoration(
                          hintText: "Add a comment...",
                          hintStyle: TextStyle(
                            color: Color(0xFF777777),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _isSending ? null : _sendComment,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isSending
                            ? const Color(0xFFFF7C11).withOpacity(0.6)
                            : const Color(0xFFFF7C11),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    await widget.onSendComment(text);

    setState(() {
      final now = DateTime.now();

      String formatTimeAgo(DateTime dateTime) {
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
      }

      final timestamp = formatTimeAgo(now);

      _comments.add({
        'user': _user?['userName'] ?? 'Anonymous',
        'comment': text,
        'profilePic': (_user != null && _user!['profilePic'] != null)
            ? "https://ecoroute-taal.online/uploads/profile_pics/${_user!['profilePic']}"
            : null,
        'timestamp': timestamp,
      });

      _isSending = false;
      _commentController.clear();
    });
  }
}

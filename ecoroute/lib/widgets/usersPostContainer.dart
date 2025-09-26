import 'package:flutter/material.dart';

class CommunityPost extends StatefulWidget {
  final String profilePicUrl; // from DB
  final String username; // from DB
  final String date; // from DB
  final String caption; // from DB
  final List<String> images; // multiple image URLs from DB
  final bool isFollowing; // dynamic follow state

  const CommunityPost({
    Key? key,
    required this.profilePicUrl,
    required this.username,
    required this.date,
    required this.caption,
    required this.images,
    this.isFollowing = false,
  }) : super(key: key);

  @override
  _CommunityPostState createState() => _CommunityPostState();
}

class _CommunityPostState extends State<CommunityPost> {
  bool isLiked = false;
  bool isFollowing = false;
  int currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    isFollowing = widget.isFollowing;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
                    // Profile Picture
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(widget.profilePicUrl),
                    ),
                    const SizedBox(width: 10),

                    // Username + Date
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
                            widget.date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Menu (Follow/Unfollow)
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
                          // borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.images[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        );
                      },
                    ),

                    // LEFT ARROW
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

                    // RIGHT ARROW
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

                    // PAGE INDICATORS
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
                      onTap: () {
                        setState(() {
                          isLiked = !isLiked;
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.grey,
                            size: 19,
                          ),
                          const SizedBox(width: 5),
                          const Text("Like", style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Row(
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

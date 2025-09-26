import 'package:ecoroute/login.dart';
import 'package:ecoroute/main.dart';
import 'package:ecoroute/notificationPage.dart';
import 'package:ecoroute/widgets/popup.dart';
import 'package:flutter/material.dart';
import 'package:ecoroute/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHeader extends StatelessWidget {
  final String logoPath;
  final Color iconColor;
  final Color searchBgColor;
  final bool showSearch;
  final String? profilePicUrl;
  final bool showProfile;
  final bool logout;

  const SearchHeader({
    super.key,
    this.logoPath = 'images/logo-green.png',
    this.iconColor = const Color.fromARGB(207, 255, 255, 255),
    this.searchBgColor = const Color(0xFF143D15),
    this.showSearch = true,
    this.profilePicUrl,
    this.showProfile = true,
    this.logout = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 10.0,
          bottom: 0,
          top: 15,
        ),
        child: Row(
          children: [
            Image.asset(logoPath, height: 45),
            const SizedBox(width: 10),
            if (showSearch)
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: TextField(
                    style: TextStyle(
                      color:
                          ThemeData.estimateBrightnessForColor(searchBgColor) ==
                              Brightness.dark
                          ? Colors.white
                          : const Color(0xFF011901),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Find A Tourist Spot',
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 111, 143, 112),
                        fontSize: 13,
                        fontWeight: FontWeight.w100,
                      ),
                      filled: true,
                      fillColor: searchBgColor,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 13),
                        child: Icon(Icons.search, color: iconColor, size: 20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              )
            else
              Spacer(),

            IconButton(
              icon: Icon(
                Icons.notifications_none_outlined,
                color: iconColor,
                size: 25,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsPage(),
                  ),
                );
              },
            ),

            if (logout == true)
              // IconButton(
              //   icon: Icon(Icons.logout_rounded, color: iconColor, size: 25),
              //   onPressed: () {
              //     Navigator.pushAndRemoveUntil(
              //       context,
              //       MaterialPageRoute(builder: (context) => const MyApp()),
              //       (route) => false,
              //     );
              //   },
              // ),
              IconButton(
                icon: Icon(Icons.logout_rounded, color: iconColor, size: 25),
                onPressed: () {
                  showDialog(
                    context: context, // parent page context
                    builder: (dialogContext) => PopUp(
                      title: "Logout",
                      headerIcon: Icons.logout_rounded,
                      description: "Are you sure you want to log out?",
                      confirmText: "Logout",
                      onConfirm: () async {
                        Navigator.of(dialogContext).pop();

                        final prefs = await SharedPreferences.getInstance();
                        final accountId = prefs.getInt("accountId") ?? 0;

                        try {
                          await ApiService.logoutUser(accountId);
                        } catch (e) {
                          debugPrint("Logout API failed: $e");
                          // optional: show a snackbar
                        }

                        await prefs.clear();

                        if (context.mounted) {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  );
                },
              ),

            const SizedBox(width: 2),
            if (showProfile)
              GestureDetector(
                child: CircleAvatar(
                  radius: 18,

                  backgroundImage:
                      profilePicUrl != null && profilePicUrl!.isNotEmpty
                      ? NetworkImage(profilePicUrl!)
                      : const AssetImage("images/profile_picture.png")
                            as ImageProvider,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Scroll-to-Top
class ScrollToTopWrapper extends StatefulWidget {
  final Widget child;
  final ScrollController? controller;

  const ScrollToTopWrapper({super.key, required this.child, this.controller});

  @override
  State<ScrollToTopWrapper> createState() => _ScrollToTopWrapperState();
}

class _ScrollToTopWrapperState extends State<ScrollToTopWrapper> {
  late ScrollController _scrollController;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 && !_showButton) {
      setState(() => _showButton = true);
    } else if (_scrollController.offset <= 200 && _showButton) {
      setState(() => _showButton = false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ✅ Force the child to use this scrollController if it’s scrollable
        PrimaryScrollController(
          controller: _scrollController,
          child: widget.child,
        ),
        if (_showButton)
          Positioned(
            bottom: 180,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.blueAccent,
              onPressed: _scrollToTop,
              child: const Icon(
                Icons.arrow_upward,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

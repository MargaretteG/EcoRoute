import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/customHeaderHome.dart';
import 'package:ecoroute/widgets/customTopCategory.dart';
import 'package:ecoroute/community/local.dart';
import 'package:ecoroute/community/following.dart';
import 'package:ecoroute/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  Map<String, dynamic>? _user;
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getInt("accountId");
    if (accountId == null) return;

    final userData = await _api.fetchProfile(accountId: accountId);

    if (!mounted) return; // prevent setState after dispose

    setState(() {
      _user = userData;
    });
  }

  int selectedCategoryIndex = 0;

  final commCategories = [
    {'text': 'Local', 'icon': Icons.newspaper_rounded, 'isFilled': false},
    {
      'text': 'Following',
      'icon': Icons.follow_the_signs_rounded,
      'isFilled': false,
    },
  ];

  List<Map<String, dynamic>> get updatedCategories {
    return List.generate(commCategories.length, (index) {
      return {
        ...commCategories[index],
        'isFilled': selectedCategoryIndex == index,
      };
    });
  }

  Widget _buildCategoryContent() {
    switch (selectedCategoryIndex) {
      case 0:
        return const LocalPage();
      case 1:
        return const FollowingPage();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF011901),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SearchHeader(
                  profilePicUrl:
                      _user?['profilePic'] != null &&
                          _user!['profilePic'].isNotEmpty
                      ? "https://ecoroute-taal.online/uploads/profile_pics/${_user!['profilePic']}"
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CategoryRow(
                      categories: updatedCategories,
                      onCategorySelected: (index) {
                        setState(() {
                          selectedCategoryIndex = index;
                        });
                      },
                    ),
                  ),
                ),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Container(
                        height: selectedCategoryIndex == 0
                            ? (LocalPage.hasPosts ? null : 900)
                            : (FollowingPage.hasPosts ? null : 900),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: selectedCategoryIndex == 0
                              ? (LocalPage.hasPosts
                                    ? Color.fromARGB(220, 224, 255, 224)
                                    : Color.fromARGB(255, 255, 255, 255))
                              : (FollowingPage.hasPosts
                                    ? Color.fromARGB(220, 224, 255, 224)
                                    : Color.fromARGB(255, 255, 255, 255)),
                          // color: const Color.fromARGB(195, 225, 240, 226),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(25),
                          ),
                        ),
                        child: _buildCategoryContent(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

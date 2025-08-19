import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/customHeaderHome.dart';
import 'package:ecoroute/widgets/customTopCategory.dart';
import 'package:ecoroute/community/local.dart';
import 'package:ecoroute/community/following.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
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
        return const LocalPage(); // your local.dart file
      case 1:
        return const FollowingPage(); // your following.dart file
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
                const SearchHeader(),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 20,
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
                        height: MediaQuery.of(context).size.height,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(50),
                          ),
                        ),
                        child:
                            _buildCategoryContent(), // <<--- ONLY CONTENT CHANGES
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

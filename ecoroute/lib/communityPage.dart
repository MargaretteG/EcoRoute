import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/customHeaderHome.dart';
import 'package:flutter/services.dart';
import 'package:ecoroute/widgets/customTopCategory.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  // int _currentIndex = 1;

  final commCategories = [
    {'text': 'Local', 'icon': Icons.newspaper_rounded, 'isFilled': false},
    {
      'text': 'Following',
      'icon': Icons.follow_the_signs_rounded,
      'isFilled': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF011901),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SearchHeader(),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 20,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CategoryRow(categories: commCategories),
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
                        child: Column(children: const [SizedBox(height: 600)]),
                      ),
                    ),
                    Column(children: [
                    
                  ],
                ),
                  ],
                ),
              ],
            ),
          ),

          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: BottomNavBar(
          //     currentIndex: _currentIndex,
          //     onTap: (index) {
          //       setState(() {
          //         _currentIndex = index;
          //       });
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}

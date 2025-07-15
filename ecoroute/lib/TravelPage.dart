import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/customHeaderHome.dart';
import 'package:flutter/services.dart';
import 'package:ecoroute/widgets/customTopCategory.dart';
import 'package:ecoroute/widgets/bottomNavBar.dart';
import 'travelPage/TravelsPlans.dart';
import './travelPage/WishlistsPage.dart';
import './travelPage/GroupsPage.dart';

class TravelPage extends StatefulWidget {
  const TravelPage({super.key});

  @override
  State<TravelPage> createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> {
  int _currentIndex = 3;
  int selectedCategoryIndex = 0;

  final commCategories = [
    {
      'text': 'Travel Plans',
      'icon': Icons.wallet_travel_rounded,
      'isFilled': false,
    },
    {
      'text': 'Travel Wishlists',
      'icon': Icons.wallet_travel_rounded,
      'isFilled': false,
    },
    {
      'text': 'Travel Groups',
      'icon': Icons.wallet_travel_rounded,
      'isFilled': true,
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
        return const TravelPlans();
      case 1:
        return const WishlistsContent();
      case 2:
        return const TravelGroups();
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
          Column(
            children: [
              const SearchHeader(showSearch: false),
              Align(
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

              Expanded(child: _buildCategoryContent()),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

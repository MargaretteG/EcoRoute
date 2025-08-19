import 'package:ecoroute/forms/AddTravel.dart';
import 'package:ecoroute/widgets/travelContainer.dart';
import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/customTravelheader.dart';
import 'package:ecoroute/widgets/emptyPage.dart';

class TravelPlans extends StatelessWidget {
  const TravelPlans({super.key});

  @override
  Widget build(BuildContext context) {
   
    final List<Map<String, dynamic>> travelPlans = [
      // {
      //   'icon': Icons.wallet_travel_rounded,
      //   'title': 'Unwind Trip',
      //   'date': 'July 9, 2025',
      //   'iconBackgroundColor': Colors.green,
      // },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF011901),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TravelHeader(
              title: 'Your Travel Plans',
              subtitle: 'Create New Travel Plan',
              showBottomRow: true,
              onIconTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTravel()),
                );
              },
            ),
            const SizedBox(height: 10),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Container(
                    constraints: BoxConstraints(minHeight: 500),

                    // height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(50),
                      ),
                    ),
                    child: travelPlans.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                SizedBox(height: 10),
                                EmptyState(
                                  imagePath: 'images/19.png',
                                  title: "No Travel Plans",
                                  description:
                                      "It looks like you haven’t created any travel plans yet. Start planning now!",
                                  centerVertically: false,
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: travelPlans.map((plan) {
                              return Column(
                                children: [
                                  SizedBox(height: 20),
                                  TravelContainer(
                                    icon: plan['icon'],
                                    title: plan['title'],
                                    date: plan['date'],
                                    iconBackgroundColor:
                                        plan['iconBackgroundColor'],
                                    onTap: () {
                                      // Navigate or show details
                                    },
                                    onEdit: () {
                                      // Edit logic
                                    },
                                    onDelete: () {
                                      // Delete logic
                                    },
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

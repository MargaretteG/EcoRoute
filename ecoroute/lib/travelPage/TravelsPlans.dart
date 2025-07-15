import 'package:ecoroute/forms/AddTravel.dart';
import 'package:ecoroute/widgets/travelContainer.dart';
import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/customTravelheader.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TravelPlans extends StatelessWidget {
  const TravelPlans({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF011901),
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
            SizedBox(height: 20),
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
                Column(
                  children: [
                    SizedBox(height: 20),

                    TravelContainer(
                      icon: Icons.wallet_travel_rounded,
                      title: 'Unwind Trip',
                      date: 'July 9, 2025',
                      iconBackgroundColor: Colors.green,
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

                    TravelContainer(
                      icon: Icons.wallet_travel_rounded,
                      title: 'Trip ko lang',
                      date: 'July 9, 2025',
                      iconBackgroundColor: const Color.fromARGB(
                        255,
                        150,
                        76,
                        175,
                      ),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

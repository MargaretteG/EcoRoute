import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/customTravelheader.dart';

class TravelGroups extends StatelessWidget {
  const TravelGroups({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF011901),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TravelHeader(
              title: 'Your Travel Groups',
              subtitle: 'Create New Travel Group',
              showBottomRow: true,
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
                Column(children: [
                    
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

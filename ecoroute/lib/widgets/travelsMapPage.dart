import 'package:ecoroute/MapPage.dart';
import 'package:ecoroute/travelRouteMapsPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecoroute/widgets/travelContainer.dart';
import 'package:ecoroute/widgets/emptyPage.dart';
import 'package:ecoroute/widgets/imageLoader.dart';
import 'package:ecoroute/api_service.dart';
import 'package:ecoroute/widgets/popup.dart';
import 'package:ecoroute/travelPage/ViewTravelplan.dart';

class TravelPlansBottomPopup {
  static Future<void> show(
    BuildContext context,
    Function(Map<String, dynamic> selectedTravel) onSelect,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('accountId') ?? 0;

    if (userId == 0) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => _emptyPopup(),
      );
      return;
    }

    // Fetch travel plans of user
    final travelPlans = await fetchTravelPlan(accountId: userId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext _) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.only(top: 5),
              child: Column(
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Header
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.travel_explore,
                          color: Color(0xFFFF9616),
                          size: 20,
                        ),

                        Text(
                          "Your Travel Plans",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF011901),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Orange indicator
                  SizedBox(
                    height: 4,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        const Divider(color: Colors.black, thickness: 0.5),
                        Container(
                          height: 3,
                          width: 180,
                          color: const Color(0xFFFF9616),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Travel Plans List
                  Expanded(
                    child: travelPlans.isEmpty
                        ? _emptyPopup()
                        : ListView.builder(
                            controller: controller,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 0,
                            ),
                            itemCount: travelPlans.length,
                            itemBuilder: (context, index) {
                              final plan = travelPlans[index];
                              final customColor = _parseColor(
                                plan['customColor'],
                              );

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                ),
                                child: TravelContainer(
                                  travelId: plan['addTravel_id'],
                                  title: plan['travelTitle'] ?? 'Untitled Plan',
                                  date: plan['travelStartDate'] ?? '',
                                  iconBackgroundColor: customColor,
                                  onTap: () {
                                    Navigator.pop(context);
                                    onSelect(plan);
                                  },
                                  viewingMaps: true,
                                  onViewRoute: () async {
                                    // Fetch the route data for this travel plan
                                    final routeData = await fetchTravelRoute(
                                      travelId: plan['addTravel_id'],
                                    );

                                    if (routeData == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "No route data available.",
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                            
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TravelRouteMapPage(
                                          travelPlan: routeData,
                                        ),
                                      ),
                                    );
                                  },

                                  onDelete: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => PopUp(
                                        title: "Delete Travel Plan",
                                        headerIcon:
                                            Icons.delete_forever_rounded,
                                        description:
                                            "Are you sure you want to delete this travel plan?",
                                        confirmText: "Delete",
                                        hasTextField: false,
                                        onConfirm: () async {
                                          bool success = await deleteTravelPlan(
                                            plan['addTravel_id'],
                                          );
                                          Navigator.pop(context, success);
                                        },
                                      ),
                                    );

                                    if (confirm == true) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _emptyPopup() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: EmptyState(
        imagePath: 'images/19.png',
        title: "No Travel Plans",
        description:
            "Looks like you haven’t created any travel plans yet. Start planning now!",
        centerVertically: false,
      ),
    );
  }

  static Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return Colors.green;
    }
    String cleaned = hexColor.replaceFirst('#', '');
    if (cleaned.length == 6) {
      cleaned = 'FF$cleaned';
    }
    return Color(int.parse(cleaned, radix: 16));
  }
}

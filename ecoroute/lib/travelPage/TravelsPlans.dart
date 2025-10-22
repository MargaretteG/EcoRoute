import 'dart:convert';
import 'package:ecoroute/forms/AddTravel.dart';
import 'package:ecoroute/travelPage/ViewTravelplan.dart';
import 'package:ecoroute/widgets/imageLoader.dart';
import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/popup.dart';
import 'package:ecoroute/widgets/travelContainer.dart';
import 'package:ecoroute/widgets/customTravelheader.dart';
import 'package:ecoroute/widgets/emptyPage.dart';
import 'package:ecoroute/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TravelPlans extends StatefulWidget {
  final VoidCallback? onDataChanged;
  const TravelPlans({super.key, this.onDataChanged});

  @override
  State<TravelPlans> createState() => _TravelPlansState();
}

class _TravelPlansState extends State<TravelPlans> {
  List<Map<String, dynamic>> travelPlans = [];
  bool isLoading = true;

  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTravelPlans();
  }

  Future<void> _loadTravelPlans() async {
    _safeSetState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final accountId = prefs.getInt('accountId') ?? 0;

      if (accountId == 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in")));
        _safeSetState(() => isLoading = false);
        return;
      }

      final plans = await fetchTravelPlan(accountId: accountId);

      _safeSetState(() {
        travelPlans = plans.map<Map<String, dynamic>>((plan) {
          return {
            'addTravel_id': plan['addTravel_id'],
            'title': plan['travelTitle'],
            'date': plan['travelStartDate'],
            'customColor': plan['customColor'],
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching travel plans: $e");
    } finally {
      _safeSetState(() => isLoading = false);
    }
  }

  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return Colors.green;
    }
    String cleaned = hexColor.replaceFirst('#', '');
    if (cleaned.length == 6) {
      cleaned = 'FF$cleaned';
    }
    return Color(int.parse(cleaned, radix: 16));
  }

  void _openAddTravelPopup() async {
    final newPlan = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AddTravelPopup(
        onConfirm: (data) async {
          Navigator.pop(context);

          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => AddTravel(travelData: data)),
          );

          if (result == true && mounted) {
            await _loadTravelPlans();
            widget.onDataChanged?.call();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF011901),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TravelHeader(
              title: 'Travel Plans',
              subtitle: 'Create New Travel Plan',
              showBottomRow: true,
              onIconTap: _openAddTravelPopup,
            ),
            const SizedBox(height: 10),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 500),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(50),
                      ),
                    ),

                    child: isLoading
                        ? Column(
                            children: [
                              const SizedBox(height: 30),
                              const FlickerImageLoader(
                                imagePath: "images/19.png",
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Loading Travel PLans...",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          )
                        : travelPlans.isEmpty
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
                            children: [
                              Column(
                                children: travelPlans.map((plan) {
                                  return Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      TravelContainer(
                                        travelId: plan['addTravel_id'],
                                        title: plan['title'],
                                        date: plan['date'],
                                        iconBackgroundColor: _parseColor(
                                          plan['customColor'],
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ViewTravel(
                                                addTravelId:
                                                    plan['addTravel_id'],
                                              ),
                                            ),
                                          );
                                        },

                                        onEdit: () {},
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
                                                bool success =
                                                    await deleteTravelPlan(
                                                      plan['addTravel_id'],
                                                    );
                                                if (success) {
                                                  Navigator.pop(context, true);
                                                } else {
                                                  Navigator.pop(context, false);
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "Failed to delete plan",
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          );

                                          if (confirm == true) {
                                            _loadTravelPlans(); // refresh list after deletion
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                }).toList(), 
                              ),
                              SizedBox(height: 100),
                            ],
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

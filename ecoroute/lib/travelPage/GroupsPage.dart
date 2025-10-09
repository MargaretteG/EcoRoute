import 'dart:convert';
import 'package:ecoroute/travelPage/ViewGroupTravel.dart';
import 'package:ecoroute/widgets/emptyPage.dart';
import 'package:ecoroute/widgets/popup.dart';
import 'package:ecoroute/widgets/travelContainer.dart';
import 'package:flutter/material.dart';
import 'package:ecoroute/widgets/customTravelheader.dart';
import 'package:ecoroute/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TravelGroups extends StatefulWidget {
  const TravelGroups({super.key});

  @override
  State<TravelGroups> createState() => _TravelGroupsState();
}

class _TravelGroupsState extends State<TravelGroups> {
  List<Map<String, dynamic>> travelGroups = [];
  bool isLoading = true;

  void _safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _loadGroupTravels();
  }

  // Load Group Travel Plans
  Future<void> _loadGroupTravels() async {
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

      final plans = await fetchGroupTravelPlan(accountId: accountId);

      _safeSetState(() {
        travelGroups = plans.map<Map<String, dynamic>>((plan) {
          // Handle groupTravelMembers (list or string)
          dynamic membersData = plan['groupTravelMembers'];
          List<dynamic> members = [];

          if (membersData is String) {
            try {
              members = jsonDecode(membersData);
            } catch (_) {
              members = [];
            }
          } else if (membersData is List) {
            members = membersData;
          }

          List<String> memberAvatars = members
              .map<String>((m) => m['avatar']?.toString() ?? '')
              .where((url) => url.isNotEmpty)
              .toList();

          return {
            'groupTravel_id': plan['groupTravel_id'],
            'title': plan['groupTravelTitle'],
            'date': plan['groupTravelStartDate'],
            'avatars': memberAvatars,
            'customColor': plan['customColor'],
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching group travel plans: $e");
    } finally {
      _safeSetState(() => isLoading = false);
    }
  }

  // Parse Color
  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.green;
    String cleaned = hexColor.replaceFirst('#', '');
    if (cleaned.length == 6) cleaned = 'FF$cleaned';
    return Color(int.parse(cleaned, radix: 16));
  }

  // Open Add Group Dialog
  void _openAddGroupPopup() async {
    final newGroup = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AddTravelGroupPopup(onConfirm: (data) async {}),
    );

    if (newGroup != null) {
      _safeSetState(() {
        travelGroups.add(newGroup);
      });

      _loadGroupTravels();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF011901),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TravelHeader(
              title: 'Travel Groups',
              subtitle: 'Create New Travel Group',
              showBottomRow: true,
              onIconTap: _openAddGroupPopup,
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
                        ? const Center(child: CircularProgressIndicator())
                        : travelGroups.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                EmptyState(
                                  imagePath: 'images/18.png',
                                  title: "No Travel Groups",
                                  description:
                                      "You’re not part of any travel groups yet. Join one or create your own to start connecting!",
                                  centerVertically: false,
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              Column(
                                children: travelGroups.map((plan) {
                                  return Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      TravelContainer(
                                        travelId: plan['groupTravel_id'],
                                        title: plan['title'],
                                        date: plan['date'],
                                        type: "GroupTravel",
                                        iconBackgroundColor: _parseColor(
                                          plan['customColor'],
                                        ),
                                        memberImages: plan['avatars'],
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ViewGroupTravel(
                                                groupTravelId:
                                                    plan['groupTravel_id'],
                                              ),
                                            ),
                                          );
                                        },
                                        onEdit: () {},
                                        onDelete: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => PopUp(
                                              title: "Delete Travel Group",
                                              headerIcon:
                                                  Icons.delete_forever_rounded,
                                              description:
                                                  "Are you sure you want to delete this travel group?",
                                              confirmText: "Delete",
                                              hasTextField: false,
                                              onConfirm: () async {
                                                bool success =
                                                    await deleteGroupTravel(
                                                      plan['groupTravel_id'],
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
                                            _loadGroupTravels(); // refresh list after deletion
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 100),
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

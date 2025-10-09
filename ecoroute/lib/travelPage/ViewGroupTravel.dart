import 'dart:convert';
import 'package:ecoroute/travelPage/groupMessaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecoroute/notificationPage.dart';
import 'package:ecoroute/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ViewGroupTravel extends StatefulWidget {
  final int groupTravelId;

  const ViewGroupTravel({super.key, required this.groupTravelId});

  @override
  State<ViewGroupTravel> createState() => _ViewGroupTravelState();
}

class _ViewGroupTravelState extends State<ViewGroupTravel> {
  Map<String, dynamic>? travelPlan;
  bool isLoading = true;
  List<Map<String, dynamic>> members = [];

  @override
  void initState() {
    super.initState();
    _fetchTravelDetails();
  }

  Future<void> _fetchTravelDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountId = prefs.getInt('accountId') ?? 0;

      if (accountId == 0) throw Exception("No accountId found");

      final uri = Uri.parse(
        "${ApiService.baseUrl}fetchGroupTravel.php?accountId=$accountId",
      );
      final response = await http.get(uri).timeout(ApiService.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          final List<dynamic> plans = data['data'] ?? [];

          final foundPlan = plans.firstWhere(
            (plan) =>
                plan['groupTravel_id'].toString() ==
                widget.groupTravelId.toString(),
            orElse: () => null,
          );

          if (foundPlan != null) {
            // Parse members (list or JSON string)
            dynamic membersData = foundPlan['groupTravelMembers'];
            List<Map<String, dynamic>> parsedMembers = [];

            if (membersData is String) {
              try {
                parsedMembers = List<Map<String, dynamic>>.from(
                  jsonDecode(membersData),
                );
              } catch (_) {}
            } else if (membersData is List) {
              parsedMembers = membersData
                  .map((m) => Map<String, dynamic>.from(m))
                  .toList();
            }

            setState(() {
              travelPlan = foundPlan;
              members = parsedMembers;
              isLoading = false;
            });
          } else {
            setState(() => isLoading = false);
          }
        }
      }
    } catch (e) {
      print("Error fetching details: $e");
      setState(() => isLoading = false);
    }
  }

  // --- COLOR HELPERS ---
  Color getDarkerColor(Color color, [double amount = 0.2]) {
    final hsl = HSLColor.fromColor(color);
    final darker = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darker.toColor();
  }

  Color getLighterColor(Color color) => Color.lerp(color, Colors.white, 0.6)!;

  Color getLightestColor(Color color) => Color.lerp(color, Colors.white, 0.9)!;

  // --- ITINERARY MOCK ---
  int selectedDay = 1;
  final Map<int, List<Map<String, String>>> sampleItinerary = {
    1: [
      {"time": "08:00 AM", "destination": "Taal Basilica"},
      {"time": "11:00 AM", "destination": "Heritage Village Walk"},
      {"time": "02:00 PM", "destination": "Lunch at Don Juan"},
      {"time": "04:30 PM", "destination": "Check-in Hotel XYZ"},
    ],
    2: [
      {"time": "07:30 AM", "destination": "Breakfast at Hotel"},
      {"time": "09:00 AM", "destination": "Lake Taal Boat Tour"},
      {"time": "01:00 PM", "destination": "Picnic by Lake Shore"},
      {"time": "06:00 PM", "destination": "Dinner & Local Market"},
    ],
  };

  Widget _buildDaySelector(int days, Color bgColor) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(days, (index) {
          int dayNumber = index + 1;
          bool isSelected = selectedDay == dayNumber;
          return GestureDetector(
            onTap: () => setState(() => selectedDay = dayNumber),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? getDarkerColor(bgColor)
                    : getLightestColor(bgColor),
                boxShadow: [
                  if (isSelected)
                    const BoxShadow(
                      color: Color.fromARGB(90, 0, 0, 0),
                      blurRadius: 6,
                      offset: Offset(2, 4),
                    ),
                ],
              ),
              child: Center(
                child: Text(
                  "$dayNumber",
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildItineraryList(Color bgColor) {
    final dayData = sampleItinerary[selectedDay] ?? [];

    return Container(
      decoration: BoxDecoration(
        color: getLighterColor(bgColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(80, 0, 0, 0),
            blurRadius: 6,
            offset: Offset(2, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Day $selectedDay Itinerary",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ...dayData.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: getLightestColor(bgColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: getDarkerColor(bgColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry["time"]!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      entry["destination"]!,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMemberList(Color bgColor) {
    if (members.isEmpty) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: getLighterColor(bgColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(80, 0, 0, 0),
            blurRadius: 6,
            offset: Offset(2, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 25,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: getDarkerColor(bgColor),
                ),
              ),
              const Text(
                'Group Members',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF011901),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final avatar = member['avatar'] ?? '';
                final name = member['name'] ?? 'Unknown';

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: avatar.isNotEmpty
                            ? NetworkImage(avatar)
                            : const AssetImage('images/default_avatar.png')
                                  as ImageProvider,
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 65,
                        child: Text(
                          name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (travelPlan == null) {
      return const Scaffold(
        body: Center(child: Text("Failed to load travel plan")),
      );
    }

    final String title = travelPlan!['groupTravelTitle'] ?? 'Untitled Travel';
    final String description =
        travelPlan!['groupTravelDescription'] ?? 'No description';
    final String startDate = travelPlan!['groupTravelStartDate'] ?? '';
    final int days =
        int.tryParse(travelPlan!['groupTravelNumDays'].toString()) ?? 1;
    final String colorHex = travelPlan!['customColor'] ?? '#EBFFEB';

    final String cleaned = colorHex.replaceFirst('#', '');
    final Color bgColor = Color(
      int.parse(cleaned.length == 6 ? "FF$cleaned" : cleaned, radix: 16),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF011901),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER (unchanged)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 15),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Image.asset('images/logo-green.png', height: 45),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: getDarkerColor(bgColor).withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.chat_rounded,
                          color: Colors.white,
                          size: 23,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupChatPage(
                                groupName: title,
                                bgColor: bgColor,
                                members:
                                    members, 
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // MAIN CONTAINER
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DATE
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: getDarkerColor(bgColor).withOpacity(0.7),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            startDate.isNotEmpty
                                ? DateFormat(
                                    "MMMM d, yyyy",
                                  ).format(DateTime.parse(startDate))
                                : DateFormat(
                                    "MMMM d, yyyy",
                                  ).format(DateTime.now()),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                        child: Container(
                          width: 4,
                          height: 18,
                          margin: EdgeInsets.only(left: 5),
                          decoration: BoxDecoration(color: bgColor),
                        ),
                      ),

                      // TITLE + DESC
                      Container(
                        decoration: BoxDecoration(
                          color: getLighterColor(bgColor),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromARGB(80, 0, 0, 0),
                              blurRadius: 6,
                              offset: Offset(2, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: getDarkerColor(
                                      bgColor,
                                    ).withOpacity(0.7),
                                  ),
                                  child: const Icon(
                                    Icons.pin_drop_rounded,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    title.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 13,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: getLightestColor(bgColor),
                                    ),

                                    child: Text(
                                      description,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // MEMBERS SECTION (new)
                      _buildMemberList(bgColor),

                      // DURATION + ITINERARY
                      Container(
                        decoration: BoxDecoration(
                          color: getLighterColor(bgColor),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromARGB(80, 0, 0, 0),
                              blurRadius: 6,
                              offset: Offset(2, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 25,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: getDarkerColor(bgColor),
                                  ),
                                ),
                                const Text(
                                  'Travel Duration',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF011901),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: getLightestColor(bgColor),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    days > 1 ? "$days Days" : "$days Day",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_month_outlined,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        startDate.isNotEmpty
                                            ? startDate
                                            : DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(DateTime.now()),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildDaySelector(days, bgColor),
                      _buildItineraryList(bgColor),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

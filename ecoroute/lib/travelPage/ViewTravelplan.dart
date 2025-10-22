import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecoroute/notificationPage.dart';
import 'package:ecoroute/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ViewTravel extends StatefulWidget {
  final int addTravelId;

  const ViewTravel({super.key, required this.addTravelId});

  @override
  State<ViewTravel> createState() => _ViewTravelState();
}

class _ViewTravelState extends State<ViewTravel> {
  Map<String, dynamic>? travelPlan;
  bool isLoading = true;

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

      final establishments = await fetchAllEstablishments();
      final estMap = {for (var e in establishments) e['establishment_id']: e};

      final uri = Uri.parse(
        "${ApiService.baseUrl}fetchTravelPlan.php?accountId=$accountId",
      );
      final response = await http.get(uri).timeout(ApiService.requestTimeout);
      if (response.statusCode != 200)
        throw Exception("HTTP ${response.statusCode}");

      final data = jsonDecode(response.body);
      if (data['status'] != 'success')
        throw Exception(data['message'] ?? 'Failed');

      final List<dynamic> plans = data['data'] ?? [];
      final foundPlan = plans.firstWhere(
        (plan) =>
            plan['addTravel_id'].toString() == widget.addTravelId.toString(),
        orElse: () => null,
      );
 
      if (foundPlan == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final startDate =
          DateTime.tryParse(foundPlan['travelStartDate'] ?? '') ??
          DateTime.now();

      Map<int, List<Map<String, String>>> itinerary = {};

      for (var dest in foundPlan['destinations'] ?? []) {
        int dayNumber = dest['dayNumber'] ?? 1;

        final estId = int.tryParse(dest['establishment_id'].toString()) ?? 0;
        final estData = estMap[estId];

        final estName = estData?['establishmentName'] ?? 'Unknown';
        final recognitionRating =
            estData?['recognitionRating']?.toString() ?? '0';
        final ecoRating = estData?['userRating']?.toString() ?? '0';

        // Handle time formatting
        // Handle time formatting
        String timeStr = '';
        if (dest['destinationTime'] != null &&
            dest['destinationTime'].isNotEmpty) {
          try {
            // Assuming format is "HH:mm:ss"
            final timeParts = dest['destinationTime'].split(':');
            int hour = int.parse(timeParts[0]);
            int minute = int.parse(timeParts[1]);
            final dt = DateTime(
              startDate.year,
              startDate.month,
              startDate.day,
              hour,
              minute,
            );
            timeStr = DateFormat("hh:mm a").format(dt);
          } catch (e) {
            // fallback
            timeStr = DateFormat("hh:mm a").format(startDate);
          }
        } else {
          timeStr = DateFormat("hh:mm a").format(startDate);
        }

        if (!itinerary.containsKey(dayNumber)) itinerary[dayNumber] = [];

        itinerary[dayNumber]!.add({
          "time": timeStr,
          "destination": estName,
          "recognitionRating": recognitionRating,
          "ecoRating": ecoRating,
        });
      }

      // Sort each day's destinations by time
      for (var day in itinerary.keys) {
        itinerary[day]!.sort((a, b) {
          final t1 = DateFormat("hh:mm a").parse(a["time"]!);
          final t2 = DateFormat("hh:mm a").parse(b["time"]!);
          return t1.compareTo(t2);
        });
      }

      setState(() {
        travelPlan = foundPlan;
        sampleItinerary.clear();
        sampleItinerary.addAll(itinerary);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching details: $e");
      setState(() => isLoading = false);
    }
  }

  Color getDarkerColor(Color color, [double amount = 0.2]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final darker = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darker.toColor();
  }

  Color getLighterColor(Color color) {
    return Color.lerp(color, Colors.white, 0.6)!;
  }

  Color getLightestColor(Color color) {
    return Color.lerp(color, Colors.white, 0.9)!;
  }

  // Inside your _ViewTravelState

  int selectedDay = 1;

  // Temporary static sample data
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
            onTap: () {
              setState(() {
                selectedDay = dayNumber;
              });
            },
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

    final String title = travelPlan!['travelTitle'] ?? 'Untitled Travel';
    final String description =
        travelPlan!['travelDescription'] ?? 'No description';
    final String startDate = travelPlan!['travelStartDate'] ?? '';
    final int days = int.tryParse(travelPlan!['travelNumDays'].toString()) ?? 1;
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
            // HEADER
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
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none_outlined,
                        color: Colors.white,
                        size: 25,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsPage(),
                          ),
                        );
                      },
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Date
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: getDarkerColor(bgColor).withOpacity(0.7),
                              ),
                              child: Icon(
                                Icons.calendar_month_rounded,
                                size: 22,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              startDate.isNotEmpty
                                  ? DateFormat(
                                      "MMMM d, yyyy",
                                    ).format(DateTime.parse(startDate))
                                  : DateFormat(
                                      "MMMM d, yyyy",
                                    ).format(DateTime.now()),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
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
                      // TITLE + DESCRIPTION
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
                                  child: Icon(
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

                      // DURATION
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
                                Text(
                                  'Travel Duration',
                                  style: const TextStyle(
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

  // --- HELPERS ---
  BoxDecoration _whiteBox() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [
        BoxShadow(
          color: Color.fromARGB(80, 0, 0, 0),
          blurRadius: 6,
          offset: Offset(2, 5),
        ),
      ],
    );
  }
}

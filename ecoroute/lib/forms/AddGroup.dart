import 'package:ecoroute/forms/AddTravel.dart';
import 'package:ecoroute/notificationPage.dart';
import 'package:ecoroute/widgets/bottomPopup.dart';
import 'package:ecoroute/widgets/colorPicker.dart';
import 'package:ecoroute/widgets/custom_button.dart';
import 'package:ecoroute/widgets/popup.dart';
import 'package:flutter/material.dart';
import 'package:ecoroute/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddGroupTravel extends StatefulWidget {
  final Map<String, dynamic> groupData;

  const AddGroupTravel({super.key, required this.groupData});

  @override
  State<AddGroupTravel> createState() => _AddGroupTravelState();
}

class _AddGroupTravelState extends State<AddGroupTravel> {
  Color selectedColor = const Color.fromARGB(255, 235, 255, 235);

  String title = "";
  String description = "";
  DateTime startDate = DateTime.now();
  int days = 1;
  List<Map<String, dynamic>> travelDays = [];
  int selectedDayIndex = 0;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final ScrollController _dayScrollController = ScrollController();
  List<Map<String, String>> _following = [];

  List<Map<String, String>> members = [];

  bool isEditingTitle = false;
  bool isEditingDescription = false;

  Set<String> dismissedTips = {};

  @override
  void initState() {
    super.initState();
    title = widget.groupData["groupName"] ?? "";
    description = widget.groupData["description"] ?? "";

    final dateValue = widget.groupData["date"];
    if (dateValue is String && dateValue.isNotEmpty) {
      startDate = DateTime.tryParse(dateValue) ?? DateTime.now();
    } else if (dateValue is DateTime) {
      startDate = dateValue;
    } else {
      startDate = DateTime.now();
    }

    days = (widget.groupData["days"] ?? 1).clamp(1, 30);
    members = List<Map<String, String>>.from(widget.groupData["members"] ?? []);

    _titleController = TextEditingController(text: title);
    _descriptionController = TextEditingController(text: description);

    _generateDays(startDate, preserve: false);
    _fetchFollowing();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dayScrollController.dispose();
    super.dispose();
  }

  void _generateDays(DateTime newStart, {bool preserve = true}) {
    final newTravelDays = List.generate(days, (index) {
      final date = newStart.add(Duration(days: index));
      final prev = index < travelDays.length ? travelDays[index] : null;

      return {
        'day': index + 1,
        'date': date,
        'title': prev != null && preserve ? prev['title'] : 'Day ${index + 1}',
        'destinations': prev != null && preserve
            ? List.from(prev['destinations'])
            : [],
      };
    });

    setState(() {
      startDate = newStart;
      travelDays = newTravelDays;
      if (selectedDayIndex >= travelDays.length) {
        selectedDayIndex = travelDays.length - 1;
      }
    });
  }

  void _changeDaysCount(int newCount) {
    setState(() {
      days = newCount.clamp(1, 30);
    });
    _generateDays(startDate, preserve: true);
  }

  Future<void> _pickStartDateForAll() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _generateDays(picked, preserve: true);
    }
  }

  void _onSelectDay(int index) {
    setState(() {
      selectedDayIndex = index;
    });
    if (_dayScrollController.hasClients) {
      final itemWidth = 92.0;
      final targetOffset =
          (index * itemWidth) - (MediaQuery.of(context).size.width / 2) + 46;
      _dayScrollController.animateTo(
        targetOffset.clamp(
          _dayScrollController.position.minScrollExtent,
          _dayScrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  //Api Connection
  Future<bool> _saveToDatabase() async {
    bool hasShownValidationAlert = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final accountId = prefs.getInt('accountId') ?? 0;

      if (accountId == 0) {
        showCustomSnackBar(
          context: context,
          icon: Icons.person_off_rounded,
          message: "User not logged in",
          warning: true,
        );
        return false;
      }

      String customColorHex =
          '#${selectedColor.value.toRadixString(16).padLeft(8, '0')}';

      final List<Map<String, dynamic>> allDestinations = [];
      bool hasEmptyDay = false;

      for (var day in travelDays) {
        final destinations = day['destinations'] as List;
        if (destinations.isEmpty) {
          hasEmptyDay = true;
        } else {
          for (var dest in destinations) {
            allDestinations.add({
              "dayNumber": day['day'],
              "establishment_id": dest['establishment_id'],
              "destinationTime": dest['time'],
            });
          }
        }
      }

      if (hasEmptyDay) {
        showCustomSnackBar(
          context: context,
          icon: Icons.warning_amber_rounded,
          message: "Please add at least one destination for each day",
          alert: true,
        );
        hasShownValidationAlert = true;
        return false;
      }

      if (allDestinations.isEmpty) {
        showCustomSnackBar(
          context: context,
          icon: Icons.add_box_rounded,
          message: "Please add at least one destination",
          alert: true,
        );
        hasShownValidationAlert = true;
        return false;
      }

      final response = await addGroupTravel(
        accountId: accountId,
        groupTravelTitle: title.isNotEmpty ? title : "Untitled Travel",
        groupTravelDescription: description,
        groupTravelStartDate: DateFormat('yyyy-MM-dd').format(startDate),
        groupTravelNumDays: days.toString(),
        groupTravelMembers: members,
        customColor: customColorHex,
        destinations: allDestinations,
      );

      if (response['status'] == 'success') {
        showCustomSnackBar(
          context: context,
          icon: Icons.check_circle_rounded,
          message: "Travel plan and destinations saved!",
        );
        return true;
      } else {
        if (!hasShownValidationAlert) {
          showCustomSnackBar(
            context: context,
            icon: Icons.error_outline,
            message: "Failed: ${response['message']}",
            warning: true,
          );
        }
        return false;
      }
    } catch (e) {
      if (!hasShownValidationAlert) {
        showCustomSnackBar(
          context: context,
          icon: Icons.error_outline,
          message: "Error saving: $e",
          warning: true,
        );
      }
      return false;
    }
  }

  bool _loadingFollowing = true;
  Future<void> _fetchFollowing() async {
    setState(() => _loadingFollowing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final loggedInId = prefs.getInt('accountId') ?? 0;
      debugPrint("Logged in user ID: $loggedInId");

      if (loggedInId == 0) {
        throw Exception("User not logged in");
      }

      final followingData = await fetchFollowersFollowing(loggedInId);
      debugPrint("Following API raw data: ${followingData['following']}");

      final followingList = (followingData['following'] as List? ?? [])
          .map<Map<String, String>>(
            (u) => {
              'id': (u['user_id'] ?? '').toString(),
              'name': (u['username'] ?? 'Unknown').toString(),
              'avatar':
                  (u['profile_pic'] != null &&
                      u['profile_pic'].toString().isNotEmpty)
                  ? u['profile_pic'].toString()
                  : "https://ecoroute-taal.online/images/default_profile.png",
            },
          )
          .toList();

      if (!mounted) return;
      setState(() {
        _following = followingList;
        _loadingFollowing = false;
      });
    } catch (e) {
      setState(() => _loadingFollowing = false);
      debugPrint("Failed to fetch following: $e");
    }
  }

  // Member controls
  void _removeMember(Map<String, String> user) {
    setState(() {
      members.remove(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF011901),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 15,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 5,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        child: Column(
                          children: [
                            const Divider(color: Colors.white, thickness: 0.2),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Create Your\n Group Travel',
                                    style: TextStyle(
                                      height: 0.9,
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                ColorPickerWidget(
                                  selectedColor: selectedColor,
                                  onColorSelected: (color) {
                                    setState(() {
                                      selectedColor = color;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: selectedColor,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(25),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Editable Title
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,

                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color.fromARGB(
                                          99,
                                          0,
                                          0,
                                          0,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(2, 5),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsGeometry.symmetric(
                                      horizontal: 10,
                                      vertical: 25,
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.pin_drop_outlined,
                                              size: 20,
                                              color: Color(0xFF64F67A),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: isEditingTitle
                                                  ? TextFormField(
                                                      controller:
                                                          _titleController,
                                                      onFieldSubmitted: (val) {
                                                        setState(() {
                                                          title = val;
                                                          isEditingTitle =
                                                              false;
                                                        });
                                                      },
                                                    )
                                                  : Text(
                                                      title.isNotEmpty
                                                          ? title
                                                          : 'Untitled Travel',
                                                      style: const TextStyle(
                                                        fontSize: 25,
                                                        height: 1,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                    ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                size: 15,
                                                isEditingTitle
                                                    ? Icons.check
                                                    : Icons.edit,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  if (isEditingTitle) {
                                                    title =
                                                        _titleController.text;
                                                  }
                                                  isEditingTitle =
                                                      !isEditingTitle;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),

                                        // Editable Description
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.description_outlined,
                                              size: 20,
                                              color: Color(0xFF64F67A),
                                            ),
                                            const SizedBox(width: 10),

                                            Expanded(
                                              child: isEditingDescription
                                                  ? TextFormField(
                                                      style: TextStyle(
                                                        height: 1,
                                                        fontSize: 15,
                                                      ),
                                                      controller:
                                                          _descriptionController,
                                                      maxLines: 3,
                                                      onFieldSubmitted: (val) {
                                                        setState(() {
                                                          description = val;
                                                          isEditingDescription =
                                                              false;
                                                        });
                                                      },
                                                    )
                                                  : Text(
                                                      style: TextStyle(
                                                        height: 1,
                                                      ),
                                                      description.isNotEmpty
                                                          ? description
                                                          : 'Add a short description...',
                                                    ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                size: 15,
                                                isEditingDescription
                                                    ? Icons.check
                                                    : Icons.edit,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  if (isEditingDescription) {
                                                    description =
                                                        _descriptionController
                                                            .text;
                                                  }
                                                  isEditingDescription =
                                                      !isEditingDescription;
                                                });
                                              },
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 5),
                                        // Selected Members
                                        if (members.isNotEmpty)
                                          Container(
                                            constraints: const BoxConstraints(
                                              maxHeight: 70,
                                            ),
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: members.length + 1,
                                              itemBuilder: (context, index) {
                                                if (index < members.length) {
                                                  final user = members[index];
                                                  return Container(
                                                    width: 140,
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 8,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      color: const Color(
                                                        0xFFF4F4F4,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                0.08,
                                                              ),
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                            2,
                                                            2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 16,
                                                          backgroundImage:
                                                              NetworkImage(
                                                                user["avatar"]!,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            user["name"]!,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () =>
                                                              _removeMember(
                                                                user,
                                                              ),
                                                          child: const Icon(
                                                            Icons.close,
                                                            color: Colors.red,
                                                            size: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                } else {
                                                  // Add icon container
                                                  return Container(
                                                    width: 50,
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 8,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.green.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                0.15,
                                                              ),
                                                          blurRadius: 6,
                                                          offset: const Offset(
                                                            2,
                                                            2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons.add,
                                                          size: 20,
                                                          color: Colors.green,
                                                        ),
                                                        onPressed: () async {
                                                          await showDialog(
                                                            context: context,
                                                            builder: (_) => AddMemberPopup(
                                                              following:
                                                                  _following, // your following list
                                                              existingMembers:
                                                                  members, // currently added members in group
                                                              onConfirm: (selected) {
                                                                setState(() {
                                                                  members.addAll(
                                                                    selected.where(
                                                                      (
                                                                        newUser,
                                                                      ) => !members
                                                                          .contains(
                                                                            newUser,
                                                                          ),
                                                                    ),
                                                                  ); // avoid duplicates
                                                                });
                                                              },
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 25),

                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,

                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color.fromARGB(
                                          99,
                                          0,
                                          0,
                                          0,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(2, 5),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsGeometry.symmetric(
                                      horizontal: 0,
                                      vertical: 25,
                                    ),
                                    child: Column(
                                      children: [
                                        Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsetsGeometry.symmetric(
                                                    horizontal: 10,
                                                  ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 4,
                                                    height: 20,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            2,
                                                          ),
                                                      color: const Color(
                                                        0xFF64F67A,
                                                      ),
                                                    ),
                                                    margin:
                                                        const EdgeInsets.only(
                                                          right: 10,
                                                        ),
                                                  ),
                                                  const Text(
                                                    "Travel Duration",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Color(0xFF011901),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Padding(
                                              padding:
                                                  EdgeInsetsGeometry.symmetric(
                                                    horizontal: 10,
                                                  ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 5,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(
                                                    179,
                                                    255,
                                                    243,
                                                    230,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(width: 5),
                                                    IconButton(
                                                      iconSize: 20,
                                                      icon: const Icon(
                                                        Icons
                                                            .remove_circle_outline,
                                                      ),
                                                      onPressed: () =>
                                                          _changeDaysCount(
                                                            days - 1,
                                                          ),
                                                    ),
                                                    days > 1
                                                        ? Text('$days Days')
                                                        : Text('$days Day'),
                                                    IconButton(
                                                      iconSize: 20,
                                                      icon: const Icon(
                                                        Icons
                                                            .add_circle_outline,
                                                      ),
                                                      onPressed: () =>
                                                          _changeDaysCount(
                                                            days + 1,
                                                          ),
                                                    ),
                                                    const Spacer(),
                                                    IconButton(
                                                      iconSize: 20,
                                                      icon: const Icon(
                                                        Icons
                                                            .calendar_month_outlined,
                                                      ),
                                                      onPressed:
                                                          _pickStartDateForAll,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),

                                        // Horizontal Day Selector
                                        SizedBox(
                                          height: 84,
                                          child: Stack(
                                            children: [
                                              // Day buttons
                                              Positioned.fill(
                                                child: SingleChildScrollView(
                                                  controller:
                                                      _dayScrollController,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    children: List.generate(travelDays.length, (
                                                      index,
                                                    ) {
                                                      final day =
                                                          travelDays[index];
                                                      final isSelected =
                                                          index ==
                                                          selectedDayIndex;
                                                      return GestureDetector(
                                                        onTap: () =>
                                                            _onSelectDay(index),
                                                        child: Container(
                                                          width: 92,
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 10,
                                                              ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              CircleAvatar(
                                                                radius: 20,
                                                                backgroundColor:
                                                                    isSelected
                                                                    ? const Color(
                                                                        0xFFFF7C11,
                                                                      )
                                                                    : const Color(
                                                                        0xFFEDF1EA,
                                                                      ),
                                                                child: Text(
                                                                  '${day['day']}',
                                                                  style: TextStyle(
                                                                    color:
                                                                        isSelected
                                                                        ? Colors
                                                                              .white
                                                                        : const Color(
                                                                            0xFF011901,
                                                                          ),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 6,
                                                              ),
                                                              Text(
                                                                '${day['date'].month}/${day['date'].day}',
                                                                style:
                                                                    const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 5),
                                        Padding(
                                          padding: EdgeInsetsGeometry.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF3E6),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                TravelDayEditor(
                                                  key: ValueKey(
                                                    selectedDayIndex,
                                                  ),
                                                  dayData:
                                                      travelDays[selectedDayIndex],
                                                  onChanged: (updated) {
                                                    setState(() {
                                                      travelDays[selectedDayIndex] =
                                                          updated;
                                                    });
                                                  },
                                                  dismissedTips: dismissedTips,
                                                ),

                                                const SizedBox(height: 20),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: 20),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 80,
                                        ),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF64F67A,
                                            ),
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 7,
                                            shadowColor: Colors.black
                                                .withOpacity(1),
                                          ),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (_) => PopUp(
                                                title: "Save Travel Group",
                                                headerIcon: Icons
                                                    .check_circle_outline_rounded,
                                                description:
                                                    "Are you sure you want to save this travel group?",
                                                confirmText: "Save",
                                                hasTextField: false,
                                                onConfirm: () async {
                                                  Navigator.pop(
                                                    context,
                                                    true,
                                                  ); // close popup and confirm save
                                                },
                                              ),
                                            );

                                            if (confirm == true) {
                                              // Perform loading while saving
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (_) => const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.green,
                                                      ),
                                                ),
                                              );

                                              final response =
                                                  await _saveToDatabase();

                                              // Close loading
                                              Navigator.pop(context);

                                              if (response == true) {
                                                Navigator.pop(context, true);
                                              } else {
                                                showCustomSnackBar(
                                                  context: context,
                                                  icon: Icons
                                                      .warning_amber_rounded,
                                                  message:
                                                      "Failed to save Travel Group",
                                                  warning: true,
                                                );
                                              }
                                            }
                                          },

                                          child: const Text(
                                            'Save Travel',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 70),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required String text,
    required TextEditingController controller,
    required bool isEditing,
    required Function(String) onSubmit,
    required VoidCallback onEdit,
  }) {
    return isEditing
        ? TextFormField(
            controller: controller,
            onFieldSubmitted: onSubmit,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
          )
        : Row(
            children: [
              Expanded(
                child: Text(
                  text.isEmpty ? label : text,
                  style: TextStyle(
                    fontSize: label == "Group Name" ? 22 : 16,
                    fontWeight: label == "Group Name"
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            ],
          );
  }
}

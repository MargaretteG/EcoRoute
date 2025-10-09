import 'dart:io';
import 'package:ecoroute/api_service.dart';
import 'package:ecoroute/widgets/colorPicker.dart';
import 'package:ecoroute/widgets/popup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:ecoroute/notificationPage.dart';
import 'package:ecoroute/widgets/bottomPopup.dart';
import 'package:ecoroute/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class AddTravel extends StatefulWidget {
  final Map<String, dynamic> travelData;

  const AddTravel({super.key, required this.travelData});

  @override
  State<AddTravel> createState() => _AddTravelState();
}

class _AddTravelState extends State<AddTravel> with TickerProviderStateMixin {
  Color selectedColor = const Color.fromARGB(255, 235, 255, 235);
  late String title;
  late String description;
  late DateTime startDate;
  late int days;
  Color? _selectedColor;

  bool isEditingTitle = false;
  bool isEditingDescription = false;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  late List<Map<String, dynamic>> travelDays;
  int selectedDayIndex = 0;

  final ScrollController _dayScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    title = widget.travelData["title"] ?? "";
    description = widget.travelData["description"] ?? "";
    startDate = widget.travelData["date"] ?? DateTime.now();
    days = (widget.travelData["days"] ?? 1).clamp(1, 30);

    _titleController = TextEditingController(text: title);
    _descriptionController = TextEditingController(text: description);

    _generateDays(startDate, preserve: false);
  }

  void _addDestination({String? pinnedPlace}) {
    final now = TimeOfDay.now().format(context);

    setState(() {
      travelDays[selectedDayIndex]['destinations'].add({
        "place": pinnedPlace ?? "",
        "time": now,
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _generateDays(DateTime newStart, {bool preserve = true}) {
    final old = preserve ? travelDays : null;

    travelDays = List.generate(days, (index) {
      final date = newStart.add(Duration(days: index));
      Map<String, dynamic>? existing = (old != null && index < old.length)
          ? old[index]
          : null;

      return {
        "day": index + 1,
        "date": date,
        "title": existing != null
            ? existing['title'] ?? 'Day ${index + 1}'
            : 'Day ${index + 1}',
        "destinations": existing != null
            ? List<Map<String, dynamic>>.from(existing['destinations'] ?? [])
            : <Map<String, dynamic>>[],
      };
    });

    setState(() {
      startDate = newStart;
      if (selectedDayIndex >= travelDays.length) {
        selectedDayIndex = travelDays.length - 1;
      }
    });
  }

  void _changeDaysCount(int newCount) {
    setState(() {
      days = newCount.clamp(1, 30);
      _generateDays(startDate, preserve: true);
    });
  }

  void _pickStartDateForAll() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      _generateDays(pickedDate, preserve: true);
    }
  }

  void _onSelectDay(int index) {
    setState(() {
      selectedDayIndex = index;
    });

    final itemWidth = 92.0;
    final target =
        (index * itemWidth) -
        (MediaQuery.of(context).size.width / 2) +
        (itemWidth / 2);

    _dayScrollController.animateTo(
      target.clamp(0.0, _dayScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  //Api Connection
  Future<bool> _saveToDatabase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountId = prefs.getInt('accountId') ?? 0;

      if (accountId == 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in")));
        return false;
      }

      String customColorHex =
          '#${selectedColor.value.toRadixString(16).padLeft(8, '0')}';

      final response = await addTravelPlan(
        accountId: accountId,
        travelTitle: title.isNotEmpty ? title : "Untitled Travel",
        travelDescription: description,
        travelStartDate: DateFormat('yyyy-MM-dd').format(startDate),
        travelNumDays: days.toString(),
        customColor: customColorHex,
      );

      if (response['status'] == 'success') {
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response['message']}")),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving: $e")));
      return false;
    }
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
                                    'Create Your\nTravel Plan',
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
                                                title: "Save Travel Plan",
                                                headerIcon: Icons
                                                    .check_circle_outline_rounded,
                                                description:
                                                    "Are you sure you want to save this travel plan?",
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
                                                // ✅ When successfully saved, pop back to TravelPlans with true
                                                Navigator.pop(context, true);
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Failed to save travel plan",
                                                    ),
                                                  ),
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
      floatingActionButton:
          travelDays[selectedDayIndex]['destinations'].isNotEmpty
          ? FloatingBtn(
              icon: Icons.auto_awesome,
              iconColor: const Color(0xFF64F67A),
              auraColor: const Color(0xFFFF9616),
              onPressed: () {
                RecommendationBottomPopup.show(context, (pinnedTitle) {
                  _addDestination(pinnedPlace: pinnedTitle);
                });
              },
            )
          : null,
    );
  }
}

// TravelDayEditor Widget

class TravelDayEditor extends StatefulWidget {
  final Map<String, dynamic> dayData;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const TravelDayEditor({
    super.key,
    required this.dayData,
    required this.onChanged,
  });

  @override
  State<TravelDayEditor> createState() => _TravelDayEditorState();
}

class _TravelDayEditorState extends State<TravelDayEditor> {
  late TextEditingController _dayTitleController;
  late List<TextEditingController> _placeControllers = [];
  late List<TextEditingController> _timeControllers;

  @override
  void initState() {
    super.initState();
    _dayTitleController = TextEditingController(
      text: widget.dayData['title'] ?? '',
    );

    final dests = widget.dayData['destinations'] as List<dynamic>;
    _placeControllers = dests
        .map<TextEditingController>(
          (d) => TextEditingController(text: d['place'] ?? ''),
        )
        .toList();
    _timeControllers = dests
        .map<TextEditingController>(
          (d) => TextEditingController(text: d['time'] ?? ''),
        )
        .toList();
  }

  @override
  void dispose() {
    _dayTitleController.dispose();
    for (final c in _placeControllers) {
      c.dispose();
    }
    for (final c in _timeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _updateParent() {
    final updated = {
      'day': widget.dayData['day'],
      'date': widget.dayData['date'],
      'title': _dayTitleController.text,
      'destinations': List.generate(_placeControllers.length, (i) {
        return {
          "place": _placeControllers[i].text,
          "time": _timeControllers[i].text,
        };
      }),
    };
    widget.onChanged(updated);
  }

  void _addDestination({String? pinnedPlace}) {
    final now = TimeOfDay.now().format(context);
    setState(() {
      (widget.dayData['destinations'] as List).add({
        "place": pinnedPlace ?? "",
        "time": now,
      });
      _placeControllers.add(TextEditingController(text: pinnedPlace ?? ""));
      _timeControllers.add(TextEditingController(text: now));
    });
    _updateParent();
  }

  void _removeDestination(int idx) {
    setState(() {
      (widget.dayData['destinations'] as List).removeAt(idx);
      _placeControllers[idx].dispose();
      _timeControllers[idx].dispose();
      _placeControllers.removeAt(idx);
      _timeControllers.removeAt(idx);
    });
    _updateParent();
  }

  Future<void> _pickTime(int i) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final formatted = picked.format(context);
        _timeControllers[i].text = formatted;
        (widget.dayData['destinations'] as List)[i]['time'] = formatted;
      });
      _updateParent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dests = widget.dayData['destinations'] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _dayTitleController,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 60, 46, 29),
                ),
                decoration: const InputDecoration(
                  labelText: 'Day title (short)',
                ),
                onChanged: (_) => _updateParent(),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: List.generate(dests.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _placeControllers[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Destination',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        dests[i]['place'] = val;
                        _updateParent();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      style: TextStyle(fontSize: 13),
                      readOnly: true,
                      controller: _timeControllers[i],
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                      ),
                      onTap: () => _pickTime(i),
                    ),
                  ),

                  IconButton(
                    iconSize: 20,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _removeDestination(i),
                  ),
                ],
              ),
            );
          }),
        ),
        SizedBox(height: 15),
        Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add destination'),
              // onPressed: _addDestination,
              onPressed: () {
                WishlistsBottomPopup.show(context, (pinnedTitle) {
                  _addDestination(pinnedPlace: pinnedTitle);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEDF1EA),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  for (final c in _placeControllers) c.dispose();
                  for (final c in _timeControllers) c.dispose();
                  _placeControllers.clear();
                  _timeControllers.clear();
                  widget.dayData['destinations'].clear();
                });
                _updateParent();
              },
              child: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }
}

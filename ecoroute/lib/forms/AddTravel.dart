import 'package:flutter/material.dart';

class AddTravel extends StatefulWidget {
  const AddTravel({super.key});

  @override
  State<AddTravel> createState() => _AddTravelState();
}

class _AddTravelState extends State<AddTravel> {
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF011901),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                // const SearchHeader(showSearch: false),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: 0,
                      top: 15,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        Spacer(),
                        Image.asset('images/logo-green.png', height: 45),
                        const SizedBox(width: 10),

                        Spacer(),
                        const SizedBox(width: 10),

                        Icon(
                          Icons.notifications_none_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),

                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 5,
                        ),
                        child: Column(
                          children: [
                            Divider(color: Colors.white, thickness: 0.3),
                            // Align(
                            //   alignment: Alignment.topLeft,
                            //   child: IconButton(
                            //     icon: Icon(
                            //       Icons.arrow_back_ios_rounded,
                            //       color: Colors.white,
                            //     ),
                            //     onPressed: () {
                            //       Navigator.pop(context);
                            //     },
                            //   ),
                            // ),
                            SizedBox(height: 20),
                            Align(
                              alignment: Alignment.topLeft,
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
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // Divider(color: Colors.white, thickness: 0.3),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 10,
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,

                            // borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Travel Group Title',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 15),
                                TextFormField(
                                  maxLines: null,
                                  minLines: 5,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    labelText: 'Travel Description',
                                    hintText:
                                        'Enter your travel plans or notes...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Travel Duration',
                                      style: TextStyle(
                                        color: Color(0xFF011901),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _startDateController,
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              labelText: 'Start Date',
                                              border: OutlineInputBorder(),
                                              suffixIcon: Icon(
                                                Icons.calendar_today,
                                              ),
                                            ),
                                            onTap: () async {
                                              final pickedDate =
                                                  await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime(2100),
                                                  );
                                              if (pickedDate != null) {
                                                setState(() {
                                                  _startDate = pickedDate;
                                                  _startDateController.text =
                                                      "${pickedDate.month}-${pickedDate.day}-${pickedDate.year}";
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _startTimeController,
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              labelText: 'Start Time',
                                              border: OutlineInputBorder(),
                                              suffixIcon: Icon(
                                                Icons.access_time,
                                              ),
                                            ),
                                            onTap: () async {
                                              final pickedTime =
                                                  await showTimePicker(
                                                    context: context,
                                                    initialTime:
                                                        TimeOfDay.now(),
                                                  );
                                              if (pickedTime != null) {
                                                setState(() {
                                                  _startTime = pickedTime;
                                                  _startTimeController.text =
                                                      pickedTime.format(
                                                        context,
                                                      );
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'To:',
                                      style: TextStyle(
                                        color: Color(0xFF011901),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _endDateController,
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              labelText: 'End Date',
                                              border: OutlineInputBorder(),
                                              suffixIcon: Icon(
                                                Icons.calendar_today,
                                              ),
                                            ),
                                            onTap: () async {
                                              final pickedDate =
                                                  await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        _startDate != null
                                                        ? _startDate!.add(
                                                            Duration(days: 1),
                                                          )
                                                        : DateTime.now(),
                                                    firstDate:
                                                        _startDate != null
                                                        ? _startDate!.add(
                                                            Duration(days: 1),
                                                          )
                                                        : DateTime.now(),
                                                    lastDate: DateTime(2100),
                                                  );
                                              if (pickedDate != null) {
                                                setState(() {
                                                  _endDate = pickedDate;
                                                  _endDateController.text =
                                                      "${pickedDate.month}-${pickedDate.day}-${pickedDate.year}";
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _endTimeController,
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              labelText: 'End Time',
                                              border: OutlineInputBorder(),
                                              suffixIcon: Icon(
                                                Icons.access_time,
                                              ),
                                            ),
                                            onTap: () async {
                                              final pickedTime =
                                                  await showTimePicker(
                                                    context: context,
                                                    initialTime:
                                                        TimeOfDay.now(),
                                                  );
                                              if (pickedTime != null) {
                                                setState(() {
                                                  _endTime = pickedTime;
                                                  _endTimeController.text =
                                                      pickedTime.format(
                                                        context,
                                                      );
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 30),
                                      ],
                                    ),
                                  ],
                                ),
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
}

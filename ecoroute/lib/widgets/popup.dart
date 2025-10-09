import 'package:ecoroute/forms/AddGroup.dart';
import 'package:ecoroute/forms/AddTravel.dart';
import 'package:flutter/material.dart';

class PopUp extends StatelessWidget {
  final String title; 
  final IconData headerIcon;
  final String description;
  final bool hasTextField;
  final String confirmText;
  final VoidCallback onConfirm;
  final TextEditingController? textController;

  const PopUp({
    super.key,
    required this.title,
    required this.headerIcon,
    required this.description,
    required this.onConfirm,
    this.confirmText = 'OK',
    this.hasTextField = false,
    this.textController,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller =
        textController ?? TextEditingController();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HEADER
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF011901),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Icon(headerIcon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w100,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ],
            ),
          ),

          // BODY
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4B2F34),
                  ),
                ),
                if (hasTextField) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Type here...',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF777777),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCED4DA)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF367E3D)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // BUTTONS
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF4F4F4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Confirm
                ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7C11),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    confirmText,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SuccessPopup extends StatefulWidget {
  final String message;
  final IconData icon;
  final Duration duration;

  const SuccessPopup({
    super.key,
    required this.message,
    required this.icon,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<SuccessPopup> createState() => _SuccessPopupState();
}

class _SuccessPopupState extends State<SuccessPopup> {
  @override
  void initState() {
    super.initState();

    Future.delayed(widget.duration, () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(40),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 60, color: const Color(0xFF367E3D)),
            const SizedBox(height: 20),
            Text(
              widget.message,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B2F34),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// pop up for travel plans
class AddTravelPopup extends StatefulWidget {
  final Function(Map<String, dynamic>) onConfirm; // pass data back

  const AddTravelPopup({super.key, required this.onConfirm});

  @override
  State<AddTravelPopup> createState() => _AddTravelPopupState();
}

class _AddTravelPopupState extends State<AddTravelPopup> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();

  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.white,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF011901),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.wallet_travel_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Plan Your Travel",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),

              // BODY
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? "Travel title is required"
                          : null,
                      decoration: InputDecoration(
                        labelText: "Travel Title",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? "Travel description is required"
                          : null,
                      decoration: InputDecoration(
                        labelText: "Travel Description",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Date
                    // Date
                    FormField<DateTime>(
                      validator: (value) {
                        if (_selectedDate == null) {
                          return "Date is required";
                        }
                        return null;
                      },
                      builder: (field) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: field.hasError
                                      ? Colors.red
                                      : const Color(0xFFCED4DA),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                    color: Color(0xFF777777),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _selectedDate != null
                                        ? "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}"
                                        : "Pick a start date",
                                    style: TextStyle(
                                      color: _selectedDate != null
                                          ? Colors.black87
                                          : const Color(0xFF777777),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (field.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 4),
                              child: Text(
                                field.errorText!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // if (_selectedDate == null)
                    //   const Padding(
                    //     padding: EdgeInsets.only(top: 6, left: 4),
                    //     child: Text(
                    //       "Date is required",
                    //       style: TextStyle(color: Colors.red, fontSize: 12),
                    //     ),
                    //   ),
                    const SizedBox(height: 15),

                    // Number of Days
                    TextFormField(
                      controller: _daysController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Number of days is required";
                        }
                        final days = int.tryParse(value);
                        if (days == null || days <= 0) {
                          return "Enter a valid number greater than 0";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Number of Days",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // BUTTONS
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF4F4F4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Plan Now 
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate() &&
                            _selectedDate != null) {
                          final data = {
                            "title": _titleController.text,
                            "description": _descriptionController.text,
                            "date": _selectedDate,
                            "days": int.tryParse(_daysController.text) ?? 0, 
                          };
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddTravel(travelData: data),
                            ),
                          );
                        } else {
                          setState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7C11),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Plan Now",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//Pop Up for add travel group
class AddTravelGroupPopup extends StatefulWidget {
  final Function(Map<String, dynamic>) onConfirm;

  const AddTravelGroupPopup({super.key, required this.onConfirm});

  @override
  State<AddTravelGroupPopup> createState() => _AddTravelGroupPopupState();
}

class _AddTravelGroupPopupState extends State<AddTravelGroupPopup> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _userSearchController = TextEditingController();

  DateTime? _selectedDate;

  // Fake data: list of people the creator follows
  final List<Map<String, String>> _following = [
    {"name": "Alex Johnson", "avatar": "https://i.pravatar.cc/150?img=1"},
    {"name": "aMaria Gomez", "avatar": "https://i.pravatar.cc/150?img=2"},
    {"name": "aJohn Smith", "avatar": "https://i.pravatar.cc/150?img=3"},
    {"name": "aSophie Chen", "avatar": "https://i.pravatar.cc/150?img=4"},
  ];

  final List<Map<String, String>> _selectedUsers = [];

  void _addUser(Map<String, String> user) {
    if (!_selectedUsers.contains(user)) {
      setState(() => _selectedUsers.add(user));
    }
    _userSearchController.clear();
  }

  void _removeUser(Map<String, String> user) {
    setState(() => _selectedUsers.remove(user));
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.white,
      child: Form(
        key: _formKey,
        child: SizedBox(
          height:
              MediaQuery.of(context).size.height * 0.75, // set dialog height
          child: Column(
            children: [
              // HEADER (fixed top)
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF011901),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.group_add, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Create Travel Group",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),

              // BODY (scrollable)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Group Name
                      TextFormField(
                        controller: _groupNameController,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? "Group name is required"
                            : null,
                        decoration: InputDecoration(
                          labelText: "Group Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? "Description is required"
                            : null,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Date
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () => _pickDate(context),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? "Date is required"
                            : null,
                        decoration: InputDecoration(
                          labelText: "Start Date",
                          suffixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Days
                      TextFormField(
                        controller: _daysController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Number of days is required";
                          }
                          final days = int.tryParse(value);
                          if (days == null || days <= 0) {
                            return "Enter a valid number of days";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Number of Days",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Add People
                      TextField(
                        controller: _userSearchController,
                        decoration: InputDecoration(
                          labelText: "Add People",
                          suffixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),

                      // Dropdown
                      Builder(
                        builder: (context) {
                          if (_userSearchController.text.isEmpty) {
                            return const SizedBox();
                          }

                          final filtered = _following
                              .where(
                                (u) => u["name"]!.toLowerCase().contains(
                                  _userSearchController.text.toLowerCase(),
                                ),
                              )
                              .toList();

                          if (filtered.isEmpty) return const SizedBox();

                          return Container(
                            constraints: const BoxConstraints(maxHeight: 120),
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final user = filtered[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      user["avatar"]!,
                                    ),
                                  ),
                                  title: Text(user["name"]!),
                                  onTap: () {
                                    _addUser(user);
                                    _userSearchController.clear();
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 5),

                      // Selected Members
                      if (_selectedUsers.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 80),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedUsers.length,
                            itemBuilder: (context, index) {
                              final user = _selectedUsers[index];
                              return Container(
                                width: 140,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0xFFF4F4F4),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundImage: NetworkImage(
                                        user["avatar"]!,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        user["name"]!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _removeUser(user),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 16,
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
                ),
              ),

              // BUTTONS
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF4F4F4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final data = {
                            "groupName": _groupNameController.text,
                            "description": _descriptionController.text,
                            "date": _dateController.text,
                            "days": int.tryParse(_daysController.text),
                            "members": _selectedUsers,
                          };

                          Navigator.pop(context);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddGroupTravel(groupData: data),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7C11),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Create Group",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

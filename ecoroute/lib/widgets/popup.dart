import 'package:ecoroute/forms/AddGroup.dart';
import 'package:ecoroute/forms/AddTravel.dart';
import 'package:flutter/material.dart';
import 'package:ecoroute/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class AddTravelPopup extends StatefulWidget {
  final Function(Map<String, dynamic>) onConfirm;

  const AddTravelPopup({super.key, required this.onConfirm});

  @override
  State<AddTravelPopup> createState() => _AddTravelPopupState();
}

class _AddTravelPopupState extends State<AddTravelPopup> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

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
        _dateController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
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
          height: MediaQuery.of(context).size.height * 0.75, // fixed height
          child: Column(
            children: [
              // 🔹 HEADER stays fixed
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

              // 🔹 BODY (scrollable)
              Expanded(
                child: SingleChildScrollView(
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

                      // 🔹 Start Date (copied style from AddTravelGroupPopup)
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: _pickDate,
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
              ),

              // 🔹 FOOTER stays fixed
              Container(
                color: Colors.white,
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
                        if (_formKey.currentState!.validate()) {
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

  List<Map<String, String>> _following = [];
  bool _loadingFollowing = true;

  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _userSearchController = TextEditingController();

  DateTime? _selectedDate;

  final List<Map<String, String>> _selectedUsers = [];

  void _addUser(Map<String, String> user) {
    if (!_selectedUsers.any((u) => u['id'] == user['id'])) {
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
  void initState() {
    super.initState();
    _fetchFollowing();
  }

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.white,
      child: Form(
        key: _formKey,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextButton.icon(
                          icon: const Icon(Icons.person_add),
                          label: const Text("Add Members"),
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (_) => AddMemberPopup(
                                following: _following,
                                existingMembers:
                                    _selectedUsers, // already added users
                                onConfirm: (selected) {
                                  setState(() {
                                    // Add only new users
                                    for (var user in selected) {
                                      if (!_selectedUsers.any(
                                        (u) => u['id'] == user['id'],
                                      )) {
                                        _selectedUsers.add(user);
                                      }
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      // Dropdown
                      Builder(
                        builder: (context) {
                          if (_loadingFollowing) {
                            return const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "Loading your following...",
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          if (_userSearchController.text.isEmpty)
                            return const SizedBox();

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

// Add new Member Group Travel (Merged Design + Correct ID Selection)
class AddMemberPopup extends StatefulWidget {
  final List<Map<String, String>>
  following; // {"id":..., "name":..., "avatar":...}
  final List<Map<String, String>> existingMembers; // Already added members
  final Function(List<Map<String, String>> selectedMembers) onConfirm;

  const AddMemberPopup({
    super.key,
    required this.following,
    required this.existingMembers,
    required this.onConfirm,
  });

  @override
  State<AddMemberPopup> createState() => _AddMemberPopupState();
}

class _AddMemberPopupState extends State<AddMemberPopup> {
  List<Map<String, String>> _selectedMembers = [];

  void _toggleMember(Map<String, String> user) {
    if (widget.existingMembers.any((u) => u['id'] == user['id'])) return;

    setState(() {
      if (_selectedMembers.any((u) => u['id'] == user['id'])) {
        _selectedMembers.removeWhere((u) => u['id'] == user['id']);
      } else {
        _selectedMembers.add(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Add Members",
                    style: TextStyle(
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
            child: widget.following.isEmpty
                ? const Text(
                    "You are not following anyone yet.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4B2F34),
                    ),
                  )
                : SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: widget.following.length,
                      itemBuilder: (context, index) {
                        final user = widget.following[index];
                        final isAlreadyMember = widget.existingMembers.any(
                          (u) => u['id'] == user['id'],
                        );
                        final isSelected = _selectedMembers.any(
                          (u) => u['id'] == user['id'],
                        );

                        return GestureDetector(
                          onTap: () => _toggleMember(user),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isAlreadyMember
                                  ? Colors.grey.shade300
                                  : isSelected
                                  ? const Color(0xFFFFF3E6)
                                  : const Color(0xFFF4F4F4),
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: const Color(0xFFFF7C11),
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                    user["avatar"] ?? "",
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    user["name"] ?? "Unknown",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: isAlreadyMember
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                if (isAlreadyMember)
                                  const Text(
                                    "Added",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                else if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFFFF7C11),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
                  onPressed: () {
                    widget.onConfirm(_selectedMembers);
                    Navigator.pop(context);
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
                    'Add',
                    style: TextStyle(
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

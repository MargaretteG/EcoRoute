import 'package:ecoroute/login.dart';
import 'package:ecoroute/main.dart';
import 'package:ecoroute/notificationPage.dart';
import 'package:ecoroute/widgets/popup.dart';
import 'package:flutter/material.dart';
import 'package:ecoroute/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class SearchHeader extends StatelessWidget {
  final String logoPath;
  final Color iconColor;
  final Color searchBgColor;
  final bool showSearch;
  final String? profilePicUrl;
  final bool showProfile;
  final bool logout;

  const SearchHeader({
    super.key,
    this.logoPath = 'images/logo-green.png',
    this.iconColor = const Color.fromARGB(207, 255, 255, 255),
    this.searchBgColor = const Color(0xFF143D15),
    this.showSearch = true,
    this.profilePicUrl,
    this.showProfile = true,
    this.logout = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 10.0,
          bottom: 0,
          top: 15,
        ),
        child: Row(
          children: [
            Image.asset(logoPath, height: 40),
            const SizedBox(width: 10),
            if (showSearch)
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    style: TextStyle(
                      color:
                          ThemeData.estimateBrightnessForColor(searchBgColor) ==
                              Brightness.dark
                          ? Colors.white
                          : const Color(0xFF011901),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Find A Tourist Spot',
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 111, 143, 112),
                        fontSize: 13,
                        fontWeight: FontWeight.w100,
                      ),
                      filled: true,
                      fillColor: searchBgColor,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 13),
                        child: Icon(Icons.search, color: iconColor, size: 20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              )
            else
              Spacer(),

            IconButton(
              icon: Icon(
                Icons.notifications_none_outlined,
                color: iconColor,
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

            if (logout == true)
              // IconButton(
              //   icon: Icon(Icons.logout_rounded, color: iconColor, size: 25),
              //   onPressed: () {
              //     Navigator.pushAndRemoveUntil(
              //       context,
              //       MaterialPageRoute(builder: (context) => const MyApp()),
              //       (route) => false,
              //     );
              //   },
              // ),
              IconButton(
                icon: Icon(Icons.logout_rounded, color: iconColor, size: 25),
                onPressed: () {
                  showDialog(
                    context: context, // parent page context
                    builder: (dialogContext) => PopUp(
                      title: "Logout",
                      headerIcon: Icons.logout_rounded,
                      description: "Are you sure you want to log out?",
                      confirmText: "Logout",
                      onConfirm: () async {
                        Navigator.of(dialogContext).pop();

                        final prefs = await SharedPreferences.getInstance();
                        final accountId = prefs.getInt("accountId") ?? 0;

                        try {
                          await ApiService.logoutUser(accountId);
                        } catch (e) {
                          debugPrint("Logout API failed: $e");
                        }

                        await prefs.clear();

                        if (context.mounted) {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  );
                },
              ),

            const SizedBox(width: 2),
            if (showProfile)
              GestureDetector(
                child: CircleAvatar(
                  radius: 18,

                  backgroundImage:
                      profilePicUrl != null && profilePicUrl!.isNotEmpty
                      ? NetworkImage(profilePicUrl!)
                      : const AssetImage("images/profile_picture.png")
                            as ImageProvider,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Scroll-to-Top
// class ScrollToTopWrapper extends StatefulWidget {
//   final Widget child;
//   final ScrollController? controller;

//   const ScrollToTopWrapper({super.key, required this.child, this.controller});

//   @override
//   State<ScrollToTopWrapper> createState() => _ScrollToTopWrapperState();
// }

// class _ScrollToTopWrapperState extends State<ScrollToTopWrapper> {
//   late ScrollController _scrollController;
//   bool _showButton = false;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = widget.controller ?? ScrollController();
//     _scrollController.addListener(_scrollListener);
//   }

//   void _scrollListener() {
//     if (_scrollController.offset > 200 && !_showButton) {
//       setState(() => _showButton = true);
//     } else if (_scrollController.offset <= 200 && _showButton) {
//       setState(() => _showButton = false);
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_scrollListener);
//     if (widget.controller == null) {
//       _scrollController.dispose();
//     }
//     super.dispose();
//   }

//   void _scrollToTop() {
//     _scrollController.animateTo(
//       0,
//       duration: const Duration(milliseconds: 400),
//       curve: Curves.easeOut,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // ✅ Force the child to use this scrollController if it’s scrollable
//         PrimaryScrollController(
//           controller: _scrollController,
//           child: widget.child,
//         ),
//         if (_showButton)
//           Positioned(
//             bottom: 180,
//             right: 20,
//             child: FloatingActionButton(
//               mini: true,
//               backgroundColor: Colors.blueAccent,
//               onPressed: _scrollToTop,
//               child: const Icon(
//                 Icons.arrow_upward,
//                 size: 20,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

class DirectionsHeader extends StatefulWidget {
  final String logoPath;
  final Color iconColor;
  final Color bgColor;
  final gmaps.LatLng? currentLocation;
  final String? currentAddress;
  final void Function(Map<String, dynamic> selected)? onDestinationSelected;

  const DirectionsHeader({
    super.key,
    this.logoPath = 'images/logo-green.png',
    this.iconColor = Colors.black,
    this.bgColor = const Color(0xFFB2D8B2),
    this.currentLocation,
    this.currentAddress,
    this.onDestinationSelected,
  });

  @override
  State<DirectionsHeader> createState() => _DirectionsHeaderState();
}

class _DirectionsHeaderState extends State<DirectionsHeader> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allEstablishments = [];
  String? selectedDestinationName;
  Map<String, dynamic>? selectedDestinationData;
  String? _currentAddress;
  @override
  void initState() {
    super.initState();
    _fetchEstablishments();
    _loadSavedDestination();
  }

  Future<void> _fetchEstablishments() async {
    try {
      final data = await fetchAllEstablishments();
      setState(() {
        allEstablishments = data;
      });
    } catch (e) {
      debugPrint("Error fetching establishments: $e");
    }
  }

  Future<void> _loadSavedDestination() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('selectedDestination');
    if (savedName != null) {
      // Find the matching establishment
      final match = allEstablishments.firstWhere(
        (e) => e['establishmentName'] == savedName,
        orElse: () => {},
      );
      if (match.isNotEmpty) {
        setState(() {
          selectedDestinationName = match['establishmentName'];
          selectedDestinationData = match;
          if (widget.onDestinationSelected != null) {
            widget.onDestinationSelected!(match);
          }
        });
      }
    }
  }

  // get user's address
  Future<String> _getAddressFromLatLng(gmaps.LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.street}, ${place.locality}";
      }
    } catch (e) {
      debugPrint("Reverse geocoding error: $e");
    }
    return "Current Location";
  }

  Future<void> _setCurrentAddress() async {
    gmaps.LatLng currentLocation = gmaps.LatLng(12.8797, 121.7740);
    String address = await _getAddressFromLatLng(currentLocation);
    if (!mounted) return;
    setState(() {
      _currentAddress = address;
    });
  }

  Future<void> _saveSelectedDestination() async {
    final prefs = await SharedPreferences.getInstance();
    if (selectedDestinationData != null) {
      prefs.setString(
        'selectedDestination',
        selectedDestinationData!['establishmentName'],
      );
    } else {
      prefs.remove('selectedDestination');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image.asset(widget.logoPath, height: 40),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(202, 255, 255, 255),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "From → To",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Current location
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 200, 248, 209),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF003F0C).withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Icon(
                                Icons.my_location,
                                color: Color(0xFF003F0C),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                widget.currentAddress ?? "Current Location",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Destination field
                      Autocomplete<Map<String, dynamic>>(
                        displayStringForOption: (option) =>
                            option['establishmentName'],
                        optionsBuilder: (TextEditingValue value) {
                          if (value.text.isEmpty) {
                            return const Iterable<Map<String, dynamic>>.empty();
                          }

                          return allEstablishments.where(
                            (est) => est['establishmentName']
                                .toLowerCase()
                                .contains(value.text.toLowerCase()),
                          );
                        },
                        onSelected: (selection) {
                          if (selectedDestinationName !=
                              selection['establishmentName']) {
                            selectedDestinationName =
                                selection['establishmentName'];
                            selectedDestinationData = selection;

                            // Notify parent
                            if (widget.onDestinationSelected != null) {
                              widget.onDestinationSelected!(selection);
                            }

                            _saveSelectedDestination();
                          }
                        },

                        fieldViewBuilder:
                            (
                              context,
                              controller,
                              focusNode,
                              onEditingComplete,
                            ) {
                              controller.text = selectedDestinationName ?? '';
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFF9616,
                                      ).withOpacity(0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: 10.0),
                                      child: Icon(
                                        Icons.location_on_outlined,
                                        color: Color(0xFFFF9616),
                                        size: 20,
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        decoration: const InputDecoration(
                                          hintText: 'Select Destination',
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                        ),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

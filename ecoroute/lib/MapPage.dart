import 'package:ecoroute/widgets/custom_button.dart';
import 'package:ecoroute/widgets/travelsMapPage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:ecoroute/widgets/customHeaderHome.dart';
import 'package:ecoroute/widgets/customTopCategory.dart';
import 'package:ecoroute/widgets/bottomNavBar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as osm;
import 'dart:async';
import 'package:ecoroute/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'dart:math';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Map<String, dynamic>? _user, selectedDestination;
  final _api = ApiService();

  gmaps.GoogleMapController? mapController;
  gmaps.LatLng? _currentLocation;
  gmaps.BitmapDescriptor? _customMarkerIcon;
  Set<gmaps.Marker> _establishmentMarkers = {};
  String _selectedCategory = "All";
  Set<gmaps.Polyline> _polylines = {};
  String? _currentAddress;
  bool _isNavigating = false;
  StreamSubscription<Position>? _positionStream;
  bool _showingOnlyDestination = false;

  final commCategories = [
    {'text': 'All', 'icon': Icons.eco, 'isFilled': true},
    {'text': 'Eco Park', 'icon': Icons.park, 'isFilled': true},
    // {'text': 'Amusement Park', 'icon': Icons.local_activity, 'isFilled': true},
    {'text': 'Cultural Cite', 'icon': Icons.museum, 'isFilled': true},
    {'text': 'Church', 'icon': Icons.church, 'isFilled': true},
    {'text': 'Restaurant', 'icon': Icons.restaurant, 'isFilled': true},
    {'text': 'Hotel', 'icon': Icons.hotel, 'isFilled': true},
    {'text': 'Local Market', 'icon': Icons.storefront, 'isFilled': true},
    {'text': 'Filter', 'icon': Icons.filter_list, 'isFilled': true},
  ];

  final Map<int, String> categoryMap = {
    1: 'Eco Park',
    2: 'Amusement Park',
    3: 'Cultural Cite',
    4: 'Church',
    5: 'Restaurant',
    6: 'Hotel',
    7: 'Local Market',
  };

  final Map<String, gmaps.BitmapDescriptor> categoryIcons = {};

  @override
  void initState() {
    super.initState();
    _loadUser();
    _getCurrentLocation();
    _loadEstablishmentMarkers();
    _loadSelectedDestination();
  }

  Future<void> _loadCurrentLocationMarker() async {
    final imageUrl =
        _user?['profilePic'] != null && _user!['profilePic'].isNotEmpty
        ? "https://ecoroute-taal.online/uploads/profile_pics/${_user!['profilePic']}"
        : null;

    final marker = await _createProfileMarker(imageUrl);

    if (!mounted) return;
    setState(() {
      _customMarkerIcon = marker;
    });
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getInt("accountId");
    if (accountId == null) return;

    final userData = await _api.fetchProfile(accountId: accountId);
    if (!mounted) return;

    setState(() {
      _user = userData;
    });

    _loadCurrentLocationMarker();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location permission permanently denied."),
        ),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Set current location
    _currentLocation = gmaps.LatLng(position.latitude, position.longitude);

    // Get the address from coordinates
    _currentAddress = await _getAddressFromLatLng(_currentLocation!);

    if (!mounted) return;

    setState(() {
      // Update the map and UI
    });

    if (mapController != null) {
      mapController!.animateCamera(
        gmaps.CameraUpdate.newCameraPosition(
          gmaps.CameraPosition(target: _currentLocation!, zoom: 15),
        ),
      );
    }
  }

  Future<String> _getAddressFromLatLng(gmaps.LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      } else {
        return "Unknown location";
      }
    } catch (e) {
      debugPrint("Error getting address: $e");
      return "Error fetching address";
    }
  }

  void _onMapCreated(gmaps.GoogleMapController controller) {
    mapController = controller;

    controller.moveCamera(
      gmaps.CameraUpdate.newCameraPosition(
        const gmaps.CameraPosition(
          target: gmaps.LatLng(12.8797, 121.7740),
          zoom: 6.5,
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1300), () {
      if (_currentLocation != null) {
        controller.animateCamera(
          gmaps.CameraUpdate.newCameraPosition(
            gmaps.CameraPosition(target: _currentLocation!, zoom: 15.0),
          ),
        );
      }
    });
  }

  //  map recognitionRating to color
  Color _getEcoColor(int ecoRating) {
    switch (ecoRating) {
      case 1:
        return const Color.fromARGB(255, 0, 123, 223);
      case 2:
        return Colors.purple;
      case 3:
        return Colors.orange;
      case 4:
        return const Color.fromARGB(255, 216, 195, 0);
      case 5:
        return const Color.fromARGB(255, 0, 215, 7);
      default:
        return Color(0xFF003F0C);
    }
  }

  //profile Picture Pin
  Future<gmaps.BitmapDescriptor> _createProfileMarker(String? imageUrl) async {
    try {
      const double size = 90;
      const double borderWidth = 6;
      const double innerSize = size - 2 * borderWidth;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final Paint paint = Paint();

      // Draw red outer circle
      paint.color = const Color.fromARGB(255, 162, 44, 35);
      canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

      // Draw white background circle inside border
      paint.color = Colors.white;
      canvas.drawCircle(Offset(size / 2, size / 2), innerSize / 2, paint);

      // Draw profile picture as circle inside
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final NetworkImage networkImage = NetworkImage(imageUrl);
        final Completer<ImageInfo> completer = Completer();
        networkImage
            .resolve(const ImageConfiguration())
            .addListener(
              ImageStreamListener(
                (ImageInfo info, bool _) => completer.complete(info),
              ),
            );
        final ImageInfo imageInfo = await completer.future;

        final Rect rect = Rect.fromLTWH(
          borderWidth,
          borderWidth,
          innerSize,
          innerSize,
        );
        final Path clipPath = Path()..addOval(rect);
        canvas.save();
        canvas.clipPath(clipPath);
        paintImage(
          canvas: canvas,
          rect: rect,
          image: imageInfo.image,
          fit: BoxFit.cover,
        );
        canvas.restore();
      }

      // Convert to BitmapDescriptor
      final ui.Image finalImage = await recorder.endRecording().toImage(
        size.toInt(),
        size.toInt(),
      );
      final ByteData? byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return gmaps.BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    } catch (e) {
      debugPrint("Error creating profile marker: $e");
      return gmaps.BitmapDescriptor.defaultMarkerWithHue(
        gmaps.BitmapDescriptor.hueRed,
      );
    }
  }

  //  marker creation function
  Future<gmaps.BitmapDescriptor> _createCategoryMarker({
    required int recognitionRating,
    required IconData categoryIcon,
  }) async {
    try {
      final double size = 90; // smaller size
      final double lineHeight = 40;
      final double lineWidth = 6;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final Paint paint = Paint();

      // Draw main circle
      paint.color = _getEcoColor(recognitionRating);
      canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

      // Draw horizontal line at the bottom (rounded corners)
      final Rect lineRect = Rect.fromCenter(
        center: Offset(size / 2, size - lineHeight / 2),
        width: lineWidth,
        height: lineHeight,
      );
      final RRect roundedLine = RRect.fromRectAndRadius(
        lineRect,
        const Radius.circular(3),
      );
      paint.color = _getEcoColor(recognitionRating);
      canvas.drawRRect(roundedLine, paint);

      // Draw category icon
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(categoryIcon.codePoint),
          style: TextStyle(
            fontSize: 36,
            fontFamily: categoryIcon.fontFamily,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
      );

      final ui.Image image = await recorder.endRecording().toImage(
        size.toInt(),
        size.toInt(),
      );
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return gmaps.BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    } catch (e) {
      debugPrint("Error creating category marker: $e");
      return gmaps.BitmapDescriptor.defaultMarker;
    }
  }

  //  load establishments
  Future<void> _loadEstablishmentMarkers({String? categoryFilter}) async {
    try {
      final establishments = await fetchAllEstablishments();
      Set<gmaps.Marker> markers = {};

      for (var est in establishments) {
        final lat = est['latitude'] as double;
        final lng = est['longitude'] as double;
        final category = est['establishmentCategory'] as String;
        final rating = est['recognitionRating'] as int? ?? 0;

        // Skip if category doesn't match the filter (unless 'All')
        if (categoryFilter != null &&
            categoryFilter != 'All' &&
            category != categoryFilter) {
          continue;
        }

        if (lat != 0.0 && lng != 0.0) {
          final IconData iconData =
              commCategories.firstWhere(
                    (c) => c['text'] == category,
                    orElse: () => commCategories[0],
                  )['icon']
                  as IconData;

          gmaps.BitmapDescriptor markerIcon;
          final cacheKey = "$category-$rating";
          if (categoryIcons.containsKey(cacheKey)) {
            markerIcon = categoryIcons[cacheKey]!;
          } else {
            markerIcon = await _createCategoryMarker(
              recognitionRating: rating,
              categoryIcon: iconData,
            );
            categoryIcons[cacheKey] = markerIcon;
          }

          markers.add(
            gmaps.Marker(
              markerId: gmaps.MarkerId('est_${est['establishment_id']}'),
              position: gmaps.LatLng(lat, lng),
              infoWindow: gmaps.InfoWindow(
                title: est['establishmentName'],
                snippet: category,
                onTap: () {
                  // Draw route from current location to this destination
                  _drawRouteWithGoogleApi(gmaps.LatLng(lat, lng));
                },
              ),
              icon: markerIcon,
            ),
          );
        }
      }

      setState(() {
        _establishmentMarkers = markers;
      });
    } catch (e) {
      debugPrint("Error loading establishment markers: $e");
    }
  }

  //pin profile
  Future<gmaps.BitmapDescriptor> _createCustomMarker(String? imageUrl) async {
    try {
      final ByteData pinBytes = await rootBundle.load('images/red_pin.png');
      final Uint8List pinData = pinBytes.buffer.asUint8List();

      final ui.Codec pinCodec = await ui.instantiateImageCodec(pinData);
      final ui.FrameInfo pinFrame = await pinCodec.getNextFrame();

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final Paint paint = Paint();

      final double width = pinFrame.image.width.toDouble();
      final double height = pinFrame.image.height.toDouble();

      canvas.drawImage(pinFrame.image, Offset.zero, paint);

      if (imageUrl != null && imageUrl.isNotEmpty) {
        final http.Response response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final Uint8List avatarData = response.bodyBytes;
          final ui.Codec avatarCodec = await ui.instantiateImageCodec(
            avatarData,
            targetWidth: 100,
            targetHeight: 100,
          );
          final ui.FrameInfo avatarFrame = await avatarCodec.getNextFrame();

          const double avatarSize = 70;
          final double avatarX = (width - avatarSize) / 2;
          const double avatarY = 15;

          final Path clipPath = Path()
            ..addOval(Rect.fromLTWH(avatarX, avatarY, avatarSize, avatarSize));
          canvas.save();
          canvas.clipPath(clipPath);
          canvas.drawImageRect(
            avatarFrame.image,
            Rect.fromLTWH(
              0,
              0,
              avatarFrame.image.width.toDouble(),
              avatarFrame.image.height.toDouble(),
            ),
            Rect.fromLTWH(avatarX, avatarY, avatarSize, avatarSize),
            paint,
          );
          canvas.restore();
        }
      }

      final ui.Image finalImage = await recorder.endRecording().toImage(
        width.toInt(),
        height.toInt(),
      );
      final ByteData? byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return gmaps.BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    } catch (e) {
      debugPrint("Error creating custom marker: $e");
      return gmaps.BitmapDescriptor.defaultMarkerWithHue(
        gmaps.BitmapDescriptor.hueRed,
      );
    }
  }

  Future<gmaps.BitmapDescriptor> _getMarkerIcon() async {
    final imageUrl =
        _user?['profilePic'] != null && _user!['profilePic'].isNotEmpty
        ? "https://ecoroute-taal.online/uploads/profile_pics/${_user!['profilePic']}"
        : null;

    return await _createCustomMarker(imageUrl);
  }

  // for route direction
  Future<void> _drawRouteWithGoogleApi(gmaps.LatLng destination) async {
    if (_currentLocation == null) return;

    // Clear previous route
    _polylines.clear();

    const String apiKey = 'AIzaSyDDkOZ87G-Zi9aT5PMOoujlfuOY58YErCU';

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_currentLocation!.latitude},${_currentLocation!.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] != 'OK') {
        debugPrint(
          "Google Directions error: ${data['status']} - ${data['error_message']}",
        );
        return;
      }

      final route = data['routes'][0];
      final polyline = route['overview_polyline']['points'];
      final List<gmaps.LatLng> polylineCoordinates = _decodePolyline(polyline);

      setState(() {
        _polylines.add(
          gmaps.Polyline(
            polylineId: const gmaps.PolylineId("route"),
            color: Color(0xFFFF9616),
            width: 5,
            points: polylineCoordinates,
          ),
        );
      });
      mapController?.animateCamera(
        gmaps.CameraUpdate.newLatLngBounds(
          _boundsFromLatLngList([_currentLocation!, destination]),
          50, // padding
        ),
      );
    } else {
      debugPrint("HTTP error fetching directions: ${response.statusCode}");
    }
  }

  gmaps.LatLngBounds _boundsFromLatLngList(List<gmaps.LatLng> list) {
    double? x0, x1, y0, y1;
    for (var latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return gmaps.LatLngBounds(
      southwest: gmaps.LatLng(x0!, y0!),
      northeast: gmaps.LatLng(x1!, y1!),
    );
  }

  List<gmaps.LatLng> _decodePolyline(String encoded) {
    List<gmaps.LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(gmaps.LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  //For navigation
  void _startNavigation() async {
    if (selectedDestination == null) return;

    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    // Begin navigation
    setState(() {
      _isNavigating = true;
    });

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 5,
          ),
        ).listen((Position position) async {
          final newLocation = gmaps.LatLng(
            position.latitude,
            position.longitude,
          );
          setState(() {
            _currentLocation = newLocation;
          });

          // Update route dynamically (shortened line)
          if (selectedDestination != null) {
            final fullRoute = await _fetchRoute(
              _currentLocation!,
              gmaps.LatLng(
                selectedDestination!['latitude'],
                selectedDestination!['longitude'],
              ),
            );
            _updateRoutePolyline(fullRoute);
          }

          // Move camera
          mapController?.animateCamera(
            gmaps.CameraUpdate.newLatLng(newLocation),
          );
        });
  }

  void _stopNavigation() {
    _positionStream?.cancel();
    setState(() {
      _isNavigating = false;
      _positionStream = null;
    });
  }

  Future<List<gmaps.LatLng>> _fetchRoute(
    gmaps.LatLng origin,
    gmaps.LatLng destination,
  ) async {
    const String apiKey = 'AIzaSyDDkOZ87G-Zi9aT5PMOoujlfuOY58YErCU';
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    if (data['status'] != 'OK') return [];

    final polyline = data['routes'][0]['overview_polyline']['points'];
    return _decodePolyline(polyline);
  }

  void _updateRoutePolyline(List<gmaps.LatLng> fullRoute) {
    if (_currentLocation == null) return;

    // Find the closest point on the polyline to current location
    int startIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < fullRoute.length; i++) {
      final point = fullRoute[i];
      final distance = _distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        point.latitude,
        point.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        startIndex = i;
      }
    }

    // Slice the polyline from closest point to the end
    final newPolylinePoints = fullRoute.sublist(startIndex);

    setState(() {
      _polylines = {
        gmaps.Polyline(
          polylineId: const gmaps.PolylineId("route"),
          color: Color(0xFFFF9616),
          width: 5,
          points: newPolylinePoints,
        ),
      };
    });
  }

  double _distanceBetween(double lat1, double lng1, double lat2, double lng2) {
    const double r = 6371000; // radius of Earth in meters
    double dLat = _degToRad(lat2 - lat1);
    double dLng = _degToRad(lng2 - lng1);
    double a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            (sin(dLng / 2) * sin(dLng / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);

  Future<void> _saveSelectedDestination() async {
    final prefs = await SharedPreferences.getInstance();
    if (selectedDestination != null) {
      prefs.setString('selectedDestination', jsonEncode(selectedDestination));
    } else {
      prefs.remove('selectedDestination');
    }
  }

  Future<void> _loadSelectedDestination() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('selectedDestination');
    if (data != null) {
      setState(() {
        selectedDestination = jsonDecode(data);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          kIsWeb
              ? FlutterMap(
                  options: MapOptions(
                    center: osm.LatLng(12.8797, 121.7740),
                    zoom: 7.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    if (_currentLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: osm.LatLng(
                              _currentLocation!.latitude,
                              _currentLocation!.longitude,
                            ),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                )
              : gmaps.GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: const gmaps.CameraPosition(
                    target: gmaps.LatLng(12.8797, 121.7740),
                    zoom: 7.5,
                  ),
                  // myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  polylines: _polylines,
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: true,
                  padding: const EdgeInsets.only(
                    bottom: 50,
                    right: 10,
                    top: 250,
                  ),
                  markers: {
                    if (_currentLocation != null)
                      gmaps.Marker(
                        markerId: const gmaps.MarkerId("currentLocation"),
                        position: _currentLocation!,
                        infoWindow: const gmaps.InfoWindow(
                          title: "You are here",
                        ),
                        icon:
                            _customMarkerIcon ??
                            gmaps.BitmapDescriptor.defaultMarker,
                      ),
                    ..._establishmentMarkers,
                  },
                ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CategoryRow(
                      categories: commCategories,
                      onCategorySelected: (index) {
                        final selected =
                            commCategories[index]['text'] as String;

                        setState(() {
                          _selectedCategory = selected;
                        });

                        _loadEstablishmentMarkers(categoryFilter: selected);
                      },
                    ),
                  ),
                  DirectionsHeader(
                    bgColor: const Color(0xFFB2D8B2),
                    currentLocation: _currentLocation,
                    currentAddress: _currentAddress,
                    onDestinationSelected: (destination) {
                      setState(() {
                        selectedDestination = destination;

                        if (destination == null) {
                          // Restore all markers
                          _showingOnlyDestination = false;
                          _loadEstablishmentMarkers(
                            categoryFilter: _selectedCategory,
                          );
                        }
                      });

                      _saveSelectedDestination();
                    },
                  ),

                  if (selectedDestination != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // View Route
                            ElevatedButton.icon(
                              onPressed: () {
                                if (selectedDestination == null) return;

                                final lat = selectedDestination!['latitude'];
                                final lng = selectedDestination!['longitude'];

                                // Only show selected marker
                                setState(() {
                                  _showingOnlyDestination = true;
                                  _establishmentMarkers = _establishmentMarkers
                                      .where((marker) {
                                        return marker.markerId.value ==
                                            'est_${selectedDestination!['establishment_id']}';
                                      })
                                      .toSet();
                                });

                                // Draw route
                                _drawRouteWithGoogleApi(gmaps.LatLng(lat, lng));
                              },
                              icon: const Icon(
                                Icons.remove_red_eye,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "View Route",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  187,
                                  89,
                                  197,
                                  62,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 5,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),
                            // Start Navigation
                            ElevatedButton.icon(
                              onPressed: _isNavigating
                                  ? _stopNavigation
                                  : _startNavigation,
                              icon: Icon(
                                _isNavigating ? Icons.stop : Icons.navigation,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: Text(
                                _isNavigating ? "Stop" : "Start",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                  188,
                                  213,
                                  68,
                                  68,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingBtn(
              icon: Icons.auto_awesome,
              iconColor: const Color(0xFF64F67A),
              auraColor: const Color(0xFFFF9616),
              onPressed: () async {
                await TravelPlansBottomPopup.show(context, (selectedPlan) {
                  print("Selected Travel Plan: ${selectedPlan['travelTitle']}");
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

//Travel route

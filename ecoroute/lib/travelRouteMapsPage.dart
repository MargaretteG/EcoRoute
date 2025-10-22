import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:ecoroute/api_service.dart';
import 'package:ecoroute/notificationPage.dart';
import 'package:ecoroute/widgets/customTopCategory.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class TravelRouteMapPage extends StatefulWidget {
  final Map<String, dynamic> travelPlan;
  const TravelRouteMapPage({super.key, required this.travelPlan});

  @override
  State<TravelRouteMapPage> createState() => _TravelRouteMapPageState();
}

class _TravelRouteMapPageState extends State<TravelRouteMapPage> {
  int selectedDay = 0;
  gmaps.GoogleMapController? mapController;
  Set<gmaps.Marker> _markers = {};
  Set<gmaps.Polyline> _polylines = {};
  final ApiService _api = ApiService();

  final Map<String, gmaps.BitmapDescriptor> _markerCache = {};

  Map<String, dynamic>? _user;
  gmaps.LatLng? _currentLocation;
  gmaps.BitmapDescriptor? _customMarkerIcon;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final days = widget.travelPlan['days'] as List<dynamic>;
      if (days.isNotEmpty) {
        await _loadDayRoute(days[selectedDay]['destinations']);
      }
    });
  }

  Future<void> _startNavigation(double lat, double lng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch Google Maps");
    }
  }

  Color _getEcoColor(int ecoRating) {
    switch (ecoRating.clamp(1, 5)) {
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
        return const Color(0xFF003F0C);
    }
  }

  /// 👤 Creates circular profile marker
  Future<gmaps.BitmapDescriptor> _createProfileMarker(String? imageUrl) async {
    try {
      const double size = 90;
      const double borderWidth = 6;
      const double innerSize = size - 2 * borderWidth;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final Paint paint = Paint();

      // Red outer circle
      paint.color = const Color.fromARGB(255, 162, 44, 35);
      canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

      // White inner circle
      paint.color = Colors.white;
      canvas.drawCircle(Offset(size / 2, size / 2), innerSize / 2, paint);

      // Profile image
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final NetworkImage networkImage = NetworkImage(imageUrl);
        final Completer<ImageInfo> completer = Completer();
        networkImage
            .resolve(const ImageConfiguration())
            .addListener(
              ImageStreamListener((ImageInfo info, bool _) {
                completer.complete(info);
              }),
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

  /// 📍 Load user info and current location
  Future<void> _loadUserAndCurrentLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getInt("accountId");
    if (accountId == null) return;

    final userData = await _api.fetchProfile(accountId: accountId);
    _user = userData;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentLocation = gmaps.LatLng(position.latitude, position.longitude);

    final imageUrl =
        _user?['profilePic'] != null &&
            _user!['profilePic'].toString().isNotEmpty
        ? "https://ecoroute-taal.online/uploads/profile_pics/${_user!['profilePic']}"
        : null;

    _customMarkerIcon = await _createProfileMarker(imageUrl);
  }

  /// 🏞️ Create marker icon for category
  Future<gmaps.BitmapDescriptor> _createCategoryMarker({
    required int recognitionRating,
    required IconData categoryIcon,
  }) async {
    try {
      const double size = 90;
      const double lineHeight = 40;
      const double lineWidth = 6;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final Paint paint = Paint();

      paint.color = _getEcoColor(recognitionRating);
      canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

      // Small pin tail
      final Rect lineRect = Rect.fromCenter(
        center: Offset(size / 2, size - lineHeight / 2),
        width: lineWidth,
        height: lineHeight,
      );
      final RRect roundedLine = RRect.fromRectAndRadius(
        lineRect,
        const Radius.circular(3),
      );
      canvas.drawRRect(roundedLine, paint);

      // Icon in center
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'eco park':
        return Icons.park;
      case 'cultural site':
        return Icons.museum;
      case 'church':
        return Icons.church;
      case 'restaurant':
        return Icons.restaurant;
      case 'hotel':
        return Icons.hotel;
      case 'local market':
        return Icons.storefront;
      default:
        return Icons.location_on;
    }
  }

  Future<gmaps.BitmapDescriptor> _getMarkerIcon(
    String category,
    int rating,
  ) async {
    final key = '$category-$rating';
    if (_markerCache.containsKey(key)) return _markerCache[key]!;

    final icon = await _createCategoryMarker(
      recognitionRating: rating,
      categoryIcon: _getCategoryIcon(category),
    );

    _markerCache[key] = icon;
    return icon;
  }

  Future<void> _loadDayRoute(List<dynamic> dayData) async {
    Set<gmaps.Marker> markers = {};
    List<gmaps.LatLng> points = [];

    await _loadUserAndCurrentLocation();

    if (_currentLocation != null && _customMarkerIcon != null) {
      markers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId("userStartPoint"),
          position: _currentLocation!,
          infoWindow: const gmaps.InfoWindow(title: "You (Starting Point)"),
          icon: _customMarkerIcon!,
        ),
      );
      points.add(_currentLocation!);
    }

    for (var dest in dayData) {
      try {
        final lat = double.tryParse(dest['latitude'].toString()) ?? 0.0;
        final lng = double.tryParse(dest['longitude'].toString()) ?? 0.0;
        if (lat == 0.0 || lng == 0.0) continue;

        final rating = int.tryParse(dest['recognitionRating'].toString()) ?? 0;
        final category = dest['establishmentCategory']?.toString() ?? 'All';
        final markerIcon = await _getMarkerIcon(category, rating);

        markers.add(
          gmaps.Marker(
            markerId: gmaps.MarkerId(dest['destination_id'].toString()),
            position: gmaps.LatLng(lat, lng),
            infoWindow: gmaps.InfoWindow(
              title: dest['establishmentName']?.toString() ?? '',
              snippet: "Tap to navigate",
              onTap: () => _startNavigation(lat, lng),
            ),
            icon: markerIcon,
          ),
        );

        points.add(gmaps.LatLng(lat, lng));
      } catch (e) {
        debugPrint("Error creating marker for destination: $e");
      }
    }
    if (points.length >= 2) {
      final origin = points.first;
      final destination = points.last;
      final waypoints = points.sublist(1, points.length - 1);

      // Get Google directions route
      final routePoints = await _getDirectionsRoute(
        origin,
        destination,
        waypoints,
      );

      final polyline = gmaps.Polyline(
        polylineId: const gmaps.PolylineId("travel_route"),
        color: Colors.green,
        width: 5,
        points: routePoints.isNotEmpty ? routePoints : points, // fallback
      );

      setState(() {
        _markers = markers;
        _polylines = {polyline};
      });
    } else {
      // fallback: only user marker
      setState(() {
        _markers = markers;
      });
    }

    // Animate camera to user marker
    if (_currentLocation != null && mapController != null) {
      // Step 1: Zoomed out first
      await mapController!.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(_currentLocation!, 8), // zoomed out
      );

      // Small delay to make the zoom noticeable
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 2: Zoom in smoothly to actual location
      await mapController!.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(_currentLocation!, 14),
      );
    } else if (_markers.isNotEmpty) {
      // fallback: fit all markers
      await Future.delayed(const Duration(milliseconds: 200));
      await mapController!.animateCamera(
        gmaps.CameraUpdate.newLatLngBounds(_boundsFromMarkers(_markers), 100),
      );
    }
  }

  //navigation
  Future<void> _navigateWholeRoute() async {
    if (_markers.length < 2) return;

    final origin = _markers.first.position;
    final destination = _markers.last.position;
    final waypoints = _markers
        .skip(1)
        .take(_markers.length - 2)
        .map((m) => '${m.position.latitude},${m.position.longitude}')
        .join('|');

    String url =
        'https://www.google.com/maps/dir/?api=1&origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&travelmode=driving';

    if (waypoints.isNotEmpty) {
      url += '&waypoints=${Uri.encodeComponent(waypoints)}';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch Google Maps");
    }
  }

  //Google directions
  Future<List<gmaps.LatLng>> _getDirectionsRoute(
    gmaps.LatLng origin,
    gmaps.LatLng destination,
    List<gmaps.LatLng> waypoints,
  ) async {
    const String apiKey = 'AIzaSyDDkOZ87G-Zi9aT5PMOoujlfuOY58YErCU';

    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=driving';

    if (waypoints.isNotEmpty) {
      final wp = waypoints.map((p) => '${p.latitude},${p.longitude}').join('|');
      url += '&waypoints=${Uri.encodeComponent("optimize:true|$wp")}';
    }

    url += '&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] != 'OK') {
        debugPrint(
          "Google Directions error: ${data['status']} - ${data['error_message']}",
        );
        return [];
      }

      final route = data['routes'][0];
      final polyline = route['overview_polyline']['points'];
      return _decodePolyline(polyline);
    } else {
      debugPrint("HTTP error fetching directions: ${response.statusCode}");
      return [];
    }
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

  @override
  Widget build(BuildContext context) {
    final days = widget.travelPlan['days'] as List<dynamic>;
    return Scaffold(
      backgroundColor: const Color(0xFF003F0C),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 10,
                bottom: 10,
              ),
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
                  const SizedBox(width: 8),
                  // Column to hold title and date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.travelPlan['travelTitle']
                              .toString()
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            height: 1.2,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                        if (widget.travelPlan['travelStartDate'] != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                color: Colors.white70,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.travelPlan['travelStartDate'],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // BODY CONTENT
            Expanded(
              child: Stack(
                children: [
                  // Inside the Stack in Expanded (map area)
                  if (_markers.length > 1)
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.navigation, color: Colors.white),
                        label: const Text(
                          "Navigate",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          _navigateWholeRoute();
                        },
                      ),
                    ),

                  // MAP AS BACKGROUND
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                    child: gmaps.GoogleMap(
                      initialCameraPosition: gmaps.CameraPosition(
                        target:
                            _currentLocation ??
                            const gmaps.LatLng(13.7933, 120.9960),
                        zoom: 10, // default zoom
                      ),
                      markers: _markers,
                      polylines: _polylines,
                      onMapCreated: (controller) async {
                        mapController = controller;

                        if (_currentLocation != null) {
                          await controller.animateCamera(
                            gmaps.CameraUpdate.newLatLngZoom(
                              _currentLocation!,
                              14,
                            ),
                          );
                        } else if (_markers.isNotEmpty) {
                          // fallback: fit all markers
                          await Future.delayed(
                            const Duration(milliseconds: 200),
                          );
                          controller.animateCamera(
                            gmaps.CameraUpdate.newLatLngBounds(
                              _boundsFromMarkers(_markers),
                              100,
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  // FLOATING TRANSPARENT DAY BUTTONS OVER MAP
                  if (days.length > 1)
                    SafeArea(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 0, left: 40),
                          child: CategoryRow(
                            useSheerBackground: true,
                            categories: List.generate(days.length, (index) {
                              return {
                                'text': "Day ${days[index]['dayNumber']}",
                                'icon': Icons.calendar_today,
                                'isFilled': false,
                              };
                            }),
                            onCategorySelected: (index) {
                              setState(() {
                                selectedDay = index;
                                _loadDayRoute(
                                  days[selectedDay]['destinations'],
                                );
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  gmaps.LatLngBounds _boundsFromMarkers(Set<gmaps.Marker> markers) {
    double? minLat, maxLat, minLng, maxLng;
    for (var m in markers) {
      final lat = m.position.latitude;
      final lng = m.position.longitude;
      minLat = (minLat == null || lat < minLat) ? lat : minLat;
      maxLat = (maxLat == null || lat > maxLat) ? lat : maxLat;
      minLng = (minLng == null || lng < minLng) ? lng : minLng;
      maxLng = (maxLng == null || lng > maxLng) ? lng : maxLng;
    }
    return gmaps.LatLngBounds(
      southwest: gmaps.LatLng(minLat!, minLng!),
      northeast: gmaps.LatLng(maxLat!, maxLng!),
    );
  }
}

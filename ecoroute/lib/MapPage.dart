import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:ecoroute/widgets/customHeaderHome.dart';
import 'package:ecoroute/widgets/customTopCategory.dart';
import 'package:ecoroute/widgets/bottomNavBar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as osm;
import 'dart:async';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  int _currentIndex = 2;
  gmaps.GoogleMapController? mapController;

  final gmaps.LatLng _center = const gmaps.LatLng(13.8893, 120.9360);

  final commCategories = [
    {'text': 'Local', 'icon': Icons.newspaper_rounded, 'isFilled': true},
    {
      'text': 'Following',
      'icon': Icons.follow_the_signs_rounded,
      'isFilled': true,
    },
  ];

  void _onMapCreated(gmaps.GoogleMapController controller) {
    mapController = controller;

    // Start from a zoomed-out PH view
    controller.moveCamera(
      gmaps.CameraUpdate.newCameraPosition(
        const gmaps.CameraPosition(
          target: gmaps.LatLng(12.8797, 121.7740), // Philippines center
          zoom: 6.5, // not too far
        ),
      ),
    );

    // Smooth zoom-in animation to location
    Future.delayed(const Duration(milliseconds: 1300), () {
      controller.animateCamera(
        gmaps.CameraUpdate.newCameraPosition(
          gmaps.CameraPosition(
            target: _center,
            zoom: 14.0, // final zoom level
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Conditional map widget
          kIsWeb
              ? FlutterMap(
                  options: MapOptions(
                    center: osm.LatLng(12.8797, 121.7740), // PH center
                    zoom: 7.5, // Medium zoom to start
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: osm.LatLng(13.8893, 120.9360),
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
                    target: gmaps.LatLng(12.8797, 121.7740), // PH center
                    zoom: 7.5, // Medium zoom to start
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: {
                    gmaps.Marker(
                      markerId: const gmaps.MarkerId("mainPin"),
                      position: _center,
                      infoWindow: const gmaps.InfoWindow(title: "My Location"),
                      icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
                        gmaps.BitmapDescriptor.hueRed,
                      ),
                    ),
                  },
                ),

          // Overlayed UI
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                children: [
                  SearchHeader(
                    iconColor: Colors.black,
                    logoPath: 'images/logo-dark-green.png',
                    searchBgColor: const Color(0xFFB2D8B2),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CategoryRow(categories: commCategories),
                  ),
                ],
              ),
            ),
          ),

          // Bottom nav
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:ecoroute/widgets/customHeaderHome.dart';
import 'package:ecoroute/widgets/customTopCategory.dart';
import 'package:ecoroute/widgets/bottomNavBar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as osm;
// import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  int _currentIndex = 2;
  late gmaps.GoogleMapController mapController;

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
                    center: osm.LatLng(13.8893, 120.9360),
                    zoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                  ],
                )
              : gmaps.GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: gmaps.CameraPosition(
                    target: _center,
                    zoom: 14.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),

          // Overlayed UI
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
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

      // bottomNavigationBar: BottomNavBar(
      //   currentIndex: _currentIndex,
      //   onTap: (index) {
      //     setState(() {
      //       _currentIndex = index;
      //     });
      //   },
      // ),
    );
  }
}

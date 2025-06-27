import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'dart:io';
import '../services/notifi_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:parkeasy2/models/parking_space_model.dart';
import 'package:parkeasy2/screens/auth_screen.dart';
import 'history_user_screen.dart';
import 'parking_details_screen.dart';
import 'user_profile_screen.dart';
import 'package:parkeasy2/services/profile_image_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher.dart';


class MapScreen extends StatefulWidget {
  final String email;
  const MapScreen({Key? key, required this.email}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  LatLng _center = LatLng(
    28.6139,
    77.2090,
  ); // Default fallback location (Delhi)
  Set<Marker> _markers = {};
  List<ParkingSpace> _customParkingLots = [];
  double _maxDistance = 100000; // max distance filter (meters)
  double _maxPrice = 100; // max price filter (₹ per hour)
  LatLng? _searchCenter;
  int _selectedIndex = 0;
  File? _profileImage;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Showcase Keys
  final GlobalKey _profileAvatarKey = GlobalKey();
  final GlobalKey _searchBoxKey = GlobalKey();
  final GlobalKey _filterKey = GlobalKey();
  final GlobalKey _historyKey = GlobalKey();
  double _mapHeight = 275;
  final double _minMapHeight = 135;
  final double _maxMapHeight = 275;
  final ScrollController _scrollController = ScrollController();

  Offset _lastOffset = Offset.zero;



  @override
  void initState() {
    super.initState();
    _locateUser();
    _loadProfileImage();
    _checkAndShowShowcase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  void _handleScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final dy = notification.scrollDelta ?? 0;

      setState(() {
        _mapHeight -= dy;
        _mapHeight = _mapHeight.clamp(_minMapHeight, _maxMapHeight);
      });
    }
  }
  void _loadProfileImage() async {
    final imageFile = await ProfileImageService.getProfileImage();
    if (imageFile != null && mounted) {
      setState(() {
        _profileImage = imageFile;
      });
    }
  }
  void openGoogleMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Optional: handle error
      print('Could not open Google Maps');
    }
  }


  Future _checkAndShowShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasSeenShowcase = prefs.getBool('hasSeenShowcase') ?? false;
    if (!hasSeenShowcase) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final showcase = ShowCaseWidget.of(context);
        if (showcase != null) {
          showcase.startShowCase([
            _profileAvatarKey,
            _searchBoxKey,
            _filterKey,
            _historyKey,
          ]);
        }
      });
      await prefs.setBool('hasSeenShowcase', true);
    }
  }

  Future<void> _locateUser() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location services are disabled. Please enable them.'),
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Location permission denied')));
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location permission denied forever. Enable in settings.',
          ),
        ),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _center = LatLng(position.latitude, position.longitude);
    _searchCenter = _center;

    if (mounted) {
      setState(() {});
    }

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_center, 14));
    _fetchParkingLots(_center.latitude, _center.longitude);
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;

    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google Maps API key not set')));
      return;
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=$apiKey',
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final lat = data['results'][0]['geometry']['location']['lat'];
        final lng = data['results'][0]['geometry']['location']['lng'];
        final location = LatLng(lat, lng);

        _searchCenter = location;

        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 15));

        // Remove old search marker, add new one
        _markers.removeWhere((m) => m.markerId.value == 'search-location');
        _markers.add(
          Marker(
            markerId: MarkerId('search-location'),
            position: location,
            infoWindow: InfoWindow(title: 'Searched Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
        );

        if (mounted) setState(() {});

        _fetchParkingLots(lat, lng);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Location not found')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to search location: $e')));
    }
  }

  Future<void> _fetchParkingLots(double lat, double lng) async {
    try {
      final databaseRef = FirebaseDatabase.instance.ref('parking_spaces');
      final snapshot = await databaseRef.get();

      if (!snapshot.exists) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No parking data found')));
        return;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      List<ParkingSpace> nearby = [];
      Set<Marker> newMarkers =
      _markers
          .where((m) => m.markerId.value == 'search-location')
          .toSet(); // Keep the search marker

      for (var entry in data.entries) {
        final space = ParkingSpace.fromMap(
          Map<String, dynamic>.from(entry.value),
        );

        final distance = Geolocator.distanceBetween(
          lat,
          lng,
          space.latitude,
          space.longitude,
        );

        // Filter by price and distance
        if (space.pricePerHour <= _maxPrice && distance <= _maxDistance) {
          nearby.add(space);

          // Marker color: grey if fully booked, else orange
          final isBooked = space.availableSpots == 0;

          newMarkers.add(
            Marker(
              markerId: MarkerId('custom-${entry.key}'),
              position: LatLng(space.latitude, space.longitude),
              infoWindow: InfoWindow(
                title: space.address,
                snippet:
                '₹${space.pricePerHour}/hr • ${space.availableSpots} spots',
              ),
              icon:
              isBooked
                  ? BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              )
                  : BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange,
              ),
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _customParkingLots = nearby;
          _markers = newMarkers;
        });
      }

      if (nearby.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No parking lots found near this location')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch parking lots: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Showcase(
              key: _searchBoxKey,
              description: 'Search for a location here.',
              child: Row(
                children: [
                  // SEARCH BOX
                  Expanded(
                    flex: 5,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(16),
                      shadowColor: Colors.black12,
                      // Add this decoration to give a colored border
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.deepPurple, width: 1.5),
                          // Optional: add subtle shadow inside container if you want
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Colors.deepPurple.withOpacity(0.1),
                          //     blurRadius: 6,
                          //     offset: Offset(0, 3),
                          //   ),
                          // ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(fontSize: 16),
                          onSubmitted: (val) => _searchLocation(val),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            hintText: "Search location...",
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            prefixIcon: InkWell(
                              borderRadius: BorderRadius.circular(40),
                              onTap: () => _searchLocation(_searchController.text),
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(Icons.search, color: Colors.deepPurple),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none, // no border here, we handle in container
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none, // same here
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),


                  const SizedBox(width: 12),

                  // NOTIFICATION ICON
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.blue, size: 26),
                       onPressed: () {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => const NotifiHandler()),
                      //   );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),



          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Showcase(
              key: _filterKey,
              description: 'Adjust filters to find suitable parking.',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // FILTER ICON (Left)
                  InkWell(
                    onTap: () {
                      double tempMaxPrice = _maxPrice;
                      double tempMaxDistance = _maxDistance;

                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: SingleChildScrollView(
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 350),
                                padding: const EdgeInsets.all(16),
                                child: StatefulBuilder(
                                  builder: (context, setStateDialog) => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Text(
                                          "Filter Options",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.deepPurple.shade700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Max Price for Parking: ₹${tempMaxPrice.toInt()}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade800,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.currency_rupee),
                                        ],
                                      ),
                                      Slider(
                                        value: tempMaxPrice,
                                        min: 0,
                                        max: 200,
                                        divisions: 20,
                                        label: tempMaxPrice.round().toString(),
                                        onChanged: (val) {
                                          setStateDialog(() => tempMaxPrice = val);
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Max distance to Park: ${(tempMaxDistance / 1000).toStringAsFixed(1)} km',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade800,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.pin_drop_outlined),
                                        ],
                                      ),
                                      Slider(
                                        value: tempMaxDistance,
                                        min: 500,
                                        max: 100000,
                                        divisions: 19,
                                        label:
                                        '${(tempMaxDistance / 1000).toStringAsFixed(1)} km',
                                        onChanged: (val) {
                                          setStateDialog(() => tempMaxDistance = val);
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      Center(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _maxPrice = tempMaxPrice;
                                              _maxDistance = tempMaxDistance;
                                            });

                                            if (_searchCenter != null) {
                                              _fetchParkingLots(
                                                _searchCenter!.latitude,
                                                _searchCenter!.longitude,
                                              );
                                            }

                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 12),
                                          ),
                                          child: const Text(
                                            "Apply Filters",
                                            style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.filter_list,
                          color: Colors.deepPurple, size: 28),
                    ),
                  ),

                  // PRICE ICON (Center)
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "Price sorting pressed",
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: Colors.white,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.currency_rupee,
                          color: Colors.green, size: 24),
                    ),
                  ),

                  // RATING ICON (Right)
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "Rating sorting pressed",
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: Colors.white,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star_rate_rounded,
                          color: Colors.yellow, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),






          SizedBox(height: 10),

          SizedBox(
            height: _mapHeight,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey, width: 2),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: _center, zoom: 14),
                markers: _markers,
                onMapCreated: (controller) {
                  _mapController = controller;
                  if (_searchCenter != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newLatLngZoom(_searchCenter!, 14),
                    );
                    _fetchParkingLots(
                      _searchCenter!.latitude,
                      _searchCenter!.longitude,
                    );
                  }
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
            ),
          ),

          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollUpdateNotification) {
                final scrollDelta = notification.scrollDelta ?? 0;
                setState(() {
                  _mapHeight -= scrollDelta;
                  _mapHeight = _mapHeight.clamp(135, 275);
                });
              }
              return false;
            },
            child: Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: _customParkingLots.length,
                itemBuilder: (context, index) {
                  final lot = _customParkingLots[index];
                  final isBooked = lot.availableSpots == 0;

                  return TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.9, end: 1),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Builder(
                      builder: (context) {
                        final double userLat = _searchCenter?.latitude ?? _center.latitude;
                        final double userLng = _searchCenter?.longitude ?? _center.longitude;

                        final double distanceInKm = calculateDistanceKm(
                          userLat,
                          userLng,
                          lot.latitude,
                          lot.longitude,
                        );

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadowColor: Colors.blue.withOpacity(0.2),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ... your existing icon and SizedBox
                                const Icon(Icons.local_parking, size: 36, color: Colors.blueAccent),
                                const SizedBox(width: 16),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Your existing address row with green dot + "Empty"
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              lot.address,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'Empty',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Price row with green dollar icon
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.attach_money,
                                            color: Colors.green,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${lot.pricePerHour}/hr',
                                            style: TextStyle(
                                              color: Colors.green[700],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Spots row with icon
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.event_seat,
                                            color: Colors.grey,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${lot.availableSpots} spots',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // ADD this new row for distance BELOW spots
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            color: Colors.blue,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${distanceInKm.toStringAsFixed(2)} km',
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Your existing Book and Navigate buttons go here unchanged
                                Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: isBooked
                                          ? null
                                          : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ParkingDetailsScreen(
                                              parkingSpace: lot,
                                              userLat: userLat,
                                              userLng: userLng,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isBooked ? Colors.grey : Colors.blueAccent,
                                        padding:
                                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        elevation: isBooked ? 0 : 3,
                                      ),
                                      child: const Text(
                                        "Book",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        openGoogleMaps(lot.latitude, lot.longitude);
                                      },
                                      icon: const Icon(Icons.navigation, size: 18),
                                      label: const Text(
                                        "Navigate",
                                        style: TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20), // more curved
                                        ),
                                        side: BorderSide(color: Colors.blueAccent),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),



                  );
                },
              ),
            ),
          )


        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      endDrawer: _buildProfileDrawer(widget.email),
      endDrawerEnableOpenDragGesture: false,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 5,
      title: Flexible(
        child: Row(
          children: [
            Icon(Icons.location_on, color: Colors.blue),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                "Nearby Slots",
                style: TextStyle(color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Builder(
          builder:
              (context) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
              child: showcaseWrapper(
                key: _profileAvatarKey,
                description: 'Tap here to open your profile and settings.',
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[200],
                  child: ClipOval(
                    child:
                    _profileImage != null
                        ? Image.file(
                      _profileImage!,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      'assets/images/profile_default.jpg',
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget showcaseWrapper({
    required GlobalKey key,
    required Widget child,
    required String description,
  }) {
    return Showcase(
      key: key,
      description: description,
      descTextStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      tooltipBackgroundColor: Colors.blueAccent,
      child: child,
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HistoryUserScreen()),
          ).then((_) {
            setState(() => _selectedIndex = 0);
          });
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen(email: widget.email)),
          ).then((_) {
            setState(() {
              _selectedIndex = 0;
            });
          });
        }
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
          icon: showcaseWrapper(
            key: _historyKey,
            description: 'Check your past bookings here.',
            child: Icon(Icons.history),
          ),
          label: "History",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }

  Widget _buildProfileDrawer(String email) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[200],
              backgroundImage:
              _profileImage != null
                  ? FileImage(_profileImage!)
                  : AssetImage('assets/images/profile_default.jpg')
              as ImageProvider,
            ),
            SizedBox(height: 10),
            Text(
              "User Name",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(email, style: TextStyle(color: Colors.grey[800])),
              ],
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  ProfileScreen(email: widget.email),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                AppSettings.openAppSettings();
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => AuthScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}



double calculateDistanceKm(double lat1, double lng1, double lat2, double lng2) {
  const earthRadiusKm = 6371;

  double dLat = _degreesToRadians(lat2 - lat1);
  double dLng = _degreesToRadians(lng2 - lng1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(lat1)) *
          cos(_degreesToRadians(lat2)) *
          sin(dLng / 2) *
          sin(dLng / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusKm * c;
}

double _degreesToRadians(double degrees) {
  return degrees * pi / 180;
}

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../../core/widgets/map_widget.dart';
import '../../core/services/maps_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

export 'home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<BusLine> busLinesList = [];
  Position? userLocation;
  bool isLoading = true;
  String? errorMessage;
  Set<Marker> busMarkers = {};
  Set<Polyline> busPolylines = {};
  GoogleMapController? _mapController;
  bool _isDisposed = false;

  static final Set<String> favoritesList = <String>{};

  int? expandedIndex;
  Map<int, String> selectedDirection = {};

  @override
  void initState() {
    super.initState();
    _initializeLocationAndData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeLocationAndData() async {
    // Clear error message and start loading
    if (!mounted || _isDisposed) return;
    setState(() {
      errorMessage = null;
      isLoading = true;
    });
    
    try {
      // Get user location first
      Position? position = await MapsService.getCurrentLocation();
      
      if (position == null) {
        if (!mounted || _isDisposed) return;
        setState(() {
          isLoading = false;
          errorMessage = "عذرًا، فشل تحديد موقعك الحالي.";
        });
        return;
      }

      if (!mounted || _isDisposed) return;
      setState(() {
        userLocation = position;
      });

      // Test Firebase connection
      bool firebaseConnected = await FirestoreService.testConnection();
      List<BusLine> nearbyBusLines = [];

      if (firebaseConnected) {
        // Try to get data from Firestore
        nearbyBusLines = await FirestoreService.getNearbyBusLines(position);
       
        // If no bus lines found, add sample data and try again
        
      } else {
        if (!mounted || _isDisposed) return;
        setState(() {
          isLoading = false;
          errorMessage = "فشل الاتصال بـ Firebase. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.";
        });
        return;
      }
      // if (nearbyBusLines.isEmpty) {
      //     setState(() {
      //     isLoading = false;
      //     errorMessage = "فشل الاتصال بـ Firebase. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.";
      //   });
      //   return;
      //   }
      if (nearbyBusLines.isEmpty) {
        if (!mounted || _isDisposed) return;
        setState(() {
          isLoading = false;
          errorMessage = "للأسف لا توجد باصات بالقرب منك.";
        });
        return;
      }

      // Create markers and polylines for bus lines
      _createBusLineMarkersAndPolylines(nearbyBusLines);

      if (!mounted || _isDisposed) return;
      setState(() {
        busLinesList = nearbyBusLines;
        isLoading = false;
      });

    } catch (e) {
      // Log error to Crashlytics instead of print
      try {
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Error in _initializeLocationAndData');
      } catch (_) {
        // Fallback to debug print if Crashlytics is not available
        debugPrint('Error in _initializeLocationAndData: $e');
      }
      if (!mounted || _isDisposed) return;
      setState(() {
        isLoading = false;
        errorMessage = "حدث خطأ أثناء تحميل البيانات";
      });
    }
  }

  void _createBusLineMarkersAndPolylines(List<BusLine> busLines) {
    busMarkers.clear();
    busPolylines.clear();

    for (int i = 0; i < busLines.length; i++) {
      BusLine busLine = busLines[i];
      
      // Add polyline for bus route
      if (busLine.polyline.isNotEmpty) {
        busPolylines.add(
          Polyline(
            polylineId: PolylineId('bus_line_${busLine.lineId}'),
            points: busLine.polyline,
            color: _getBusLineColor(i),
            width: 4,
          ),
        );
      }

      // Add markers for landmarks
      _addLandmarkMarkers(busLine.landmarksGo, 'go_${busLine.lineId}', i);
      _addLandmarkMarkers(busLine.landmarksBack, 'back_${busLine.lineId}', i);
    }
  }

  void _addLandmarkMarkers(List<Landmark> landmarks, String prefix, int busLineIndex) {
    for (int i = 0; i < landmarks.length; i++) {
      Landmark landmark = landmarks[i];
      busMarkers.add(
        Marker(
          markerId: MarkerId('${prefix}_$i'),
          position: landmark.location,
          infoWindow: InfoWindow(
            title: landmark.name,
            snippet: 'محطة حافلة',
          ),
          icon: _getBusLineMarkerColor(busLineIndex),
        ),
      );
    }
  }

  Color _getBusLineColor(int index) {
    List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.orange, Colors.purple];
    return colors[index % colors.length];
  }

  BitmapDescriptor _getBusLineMarkerColor(int index) {
    List<double> hues = [
      BitmapDescriptor.hueRed,
      BitmapDescriptor.hueGreen,
      BitmapDescriptor.hueBlue,
      BitmapDescriptor.hueOrange,
      BitmapDescriptor.hueViolet,
    ];
    return BitmapDescriptor.defaultMarkerWithHue(hues[index % hues.length]);
  }

  void toggleFavorite(int index) {
    if (!mounted || _isDisposed) return;
    final lineId = busLinesList[index].lineId;
    setState(() {
      if (favoritesList.contains(lineId)) {
        favoritesList.remove(lineId);
      } else {
        favoritesList.add(lineId);
      }
    });
  }

  void _showSingleBusLineOnMap(BusLine busLine, int index) {
    setState(() {
      busMarkers.clear();
      busPolylines.clear();

      // Add polyline for this bus route (always blue)
      if (busLine.polyline.isNotEmpty) {
        busPolylines.add(
          Polyline(
            polylineId: PolylineId('bus_line_${busLine.lineId}'),
            points: busLine.polyline,
            color: Colors.blue, // Always blue
            width: 4,
          ),
        );
      }

      // Add markers for landmarks
      _addLandmarkMarkers(busLine.landmarksGo, 'go_${busLine.lineId}', index);
      _addLandmarkMarkers(busLine.landmarksBack, 'back_${busLine.lineId}', index);
    });
    // Move camera to fit the route
    if (_mapController != null && busLine.polyline.isNotEmpty) {
      final bounds = _boundsFromLatLngList(busLine.polyline);
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double x0 = list.first.latitude, x1 = list.first.latitude;
    double y0 = list.first.longitude, y1 = list.first.longitude;
    for (LatLng latLng in list) {
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(x0, y0),
      northeast: LatLng(x1, y1),
    );
  }

  Future<List<LatLng>> _getDirectionsPolyline(LatLng origin, LatLng destination) async {
    final apiKey = AppConstants.googleMapsApiKey;
    String mode = 'driving';
    var url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=$mode&key=$apiKey';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          return _decodePolyline(points);
        } else {
          // Try walking mode as fallback
          mode = 'walking';
          url =
              'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=$mode&key=$apiKey';
          response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['routes'] != null && data['routes'].isNotEmpty) {
              final points = data['routes'][0]['overview_polyline']['points'];
              return _decodePolyline(points);
            } else {
              throw Exception('No routes found (driving or walking)');
            }
          } else {
            throw Exception('Failed to fetch directions (walking)');
          }
        }
      } else {
        throw Exception('Failed to fetch directions (driving)');
      }
    } catch (e) {
      // Log error to Crashlytics
      try {
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Directions API request failed');
      } catch (_) {
        debugPrint('Directions API request failed: $e');
      }
      throw Exception('HTTP request to Directions API failed: $e');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }

  LatLng _findNearestPointOnPolyline(LatLng userLocation, List<LatLng> polyline) {
    double minDistance = double.infinity;
    LatLng nearestPoint = polyline.first;
    for (final point in polyline) {
      final distance = Geolocator.distanceBetween(
        userLocation.latitude, userLocation.longitude,
        point.latitude, point.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestPoint = point;
      }
    }
    return nearestPoint;
  }

  Future<LatLng> _snapToRoad(LatLng point) async {
    final apiKey = AppConstants.googleMapsApiKey;
    final url =
        'https://roads.googleapis.com/v1/snapToRoads?path=${point.latitude},${point.longitude}&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['snappedPoints'] != null && data['snappedPoints'].isNotEmpty) {
          final snapped = data['snappedPoints'][0]['location'];
          return LatLng(snapped['latitude'], snapped['longitude']);
        }
      }
    } catch (e) {
      // Log error to Crashlytics
      try {
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Roads API request failed');
      } catch (_) {
        debugPrint('HTTP request to Roads API failed: $e');
      }
    }
    // If snapping fails, return the original point
    return point;
  }

  Future<void> _showDirectionsOnMap(BusLine busLine) async {
    if (userLocation == null || busLine.polyline.isEmpty) return;
    final userLatLng = LatLng(userLocation!.latitude, userLocation!.longitude);
    LatLng nearest = _findNearestPointOnPolyline(userLatLng, busLine.polyline);
    final destination = await _snapToRoad(nearest);

    try {
      final directionsPolyline = await _getDirectionsPolyline(userLatLng, destination);
      setState(() {
        busPolylines = {
          Polyline(
            polylineId: PolylineId('directions'),
            points: directionsPolyline,
            color: Colors.blue, // Flutter's built-in blue
            width: 10, // Increased width for visibility
          ),
        };
        busMarkers = {
          Marker(
            markerId: MarkerId('origin'),
            position: userLatLng,
            infoWindow: InfoWindow(title: 'موقعك'),
          ),
          Marker(
            markerId: MarkerId('destination'),
            position: destination,
            infoWindow: InfoWindow(title: 'أقرب نقطة على خط الباص'),
          ),
        };
        if (directionsPolyline.isEmpty) {
          if (mounted && !_isDisposed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('لم يتم العثور على مسار بين موقعك وخط الباص')),
            );
          }
        }
      });
      // Move camera to fit the route
      if (_mapController != null && directionsPolyline.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 300));
        try {
          final bounds = _boundsFromLatLngList(directionsPolyline);
          await _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
        } catch (e) {
          debugPrint('Camera bounds animation failed: $e. Moving to first point.');
          await _mapController!.animateCamera(CameraUpdate.newLatLng(directionsPolyline.first));
        }
      }
    } catch (e) {
      // Log error to Crashlytics
      try {
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Directions API error');
      } catch (_) {
        debugPrint('Directions API error: $e');
      }
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر جلب الاتجاهات')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // Google Maps
            BusMapWidget(
              markers: busMarkers,
              polylines: busPolylines,
              userLocation: userLocation,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
            // Loading overlay
            if (isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
                  ),
                ),
              ),
            // Error message overlay
            if (errorMessage != null && !isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.error_outline, size: 50, color: Colors.red),
                            IconButton(
                              onPressed: () {
                                if (!mounted || _isDisposed) return;
                                setState(() {
                                  errorMessage = null;
                                });
                              },
                              icon: const Icon(Icons.close, color: Colors.grey),
                              tooltip: 'إغلاق',
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87, // Improved contrast
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Semantics(
                                label: 'إعادة المحاولة',
                                hint: 'إعادة تحميل البيانات والمحاولة مرة أخرى',
                                child: ElevatedButton(
                                  onPressed: _initializeLocationAndData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFC107),
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text('إعادة المحاولة'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Semantics(
                                label: 'إغلاق',
                                hint: 'إغلاق رسالة الخطأ',
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (!mounted || _isDisposed) return;
                                    setState(() {
                                      errorMessage = null;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text('إغلاق'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Bus lines sheet
            if (!isLoading && errorMessage == null)
            DraggableScrollableSheet(
              initialChildSize: 0.25,
              minChildSize: 0.18,
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Text('الباصات القريبة', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: busLinesList.length,
                          itemBuilder: (context, index) {
                              final busLine = busLinesList[index];
                            final isExpanded = expandedIndex == index;
                            final isFavorite = favoritesList.contains(busLine.lineId);
                            final direction = selectedDirection[index] ?? 'go';
                              final color = _getBusLineColor(index);
                              
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Column(
                                children: [
                                  Material(
                                    elevation: 2,
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                          border: Border.all(color: color.withValues(alpha: 0.2)),
                                      ),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                            child: Row(
                                              children: [
                                                Semantics(
                                                  label: isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
                                                  hint: 'إضافة أو إزالة خط الباص من قائمة المفضلة',
                                                  child: IconButton(
                                                    icon: Icon(
                                                      isFavorite ? Icons.favorite : Icons.favorite_border,
                                                        color: color,
                                                      size: 30,
                                                    ),
                                                    onPressed: () => toggleFavorite(index),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                      busLine.name,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                  decoration: BoxDecoration(
                                                      color: color,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Text(
                                                      busLine.lineId,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 24,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // --- Show in Map button ---
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: Semantics(
                                                label: 'عرض في الخريطة',
                                                hint: 'عرض مسار الوصول إلى خط الباص على الخريطة',
                                                child: ElevatedButton.icon(
                                                  icon: const Icon(Icons.map),
                                                  label: const Text('عرض في الخريطة', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: color,
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                  onPressed: () => _showDirectionsOnMap(busLine),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // --- End Show in Map button ---
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Semantics(
                                                    label: 'اتجاه الذهاب',
                                                    hint: 'عرض محطات خط الباص في اتجاه الذهاب',
                                                    child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                          backgroundColor: direction == 'go' ? color : Colors.white,
                                                          foregroundColor: direction == 'go' ? Colors.white : color,
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                            side: BorderSide(color: color),
                                                          ),
                                                      ),
                                                      onPressed: () {
                                                        if (!mounted || _isDisposed) return;
                                                        setState(() {
                                                          expandedIndex = index;
                                                          selectedDirection[index] = 'go';
                                                        });
                                                      },
                                                      child: const Text('ذهاب', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Semantics(
                                                    label: 'اتجاه العودة',
                                                    hint: 'عرض محطات خط الباص في اتجاه العودة',
                                                    child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                          backgroundColor: direction == 'back' ? color : Colors.white,
                                                        foregroundColor: direction == 'back' ? Colors.white : color,
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                            side: BorderSide(color: color),
                                                          ),
                                                      ),
                                                      onPressed: () {
                                                        if (!mounted || _isDisposed) return;
                                                        setState(() {
                                                          expandedIndex = index;
                                                          selectedDirection[index] = 'back';
                                                        });
                                                      },
                                                      child: const Text('عودة', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                    if (isExpanded && userLocation != null)
                                    _TripDetails(
                                        landmarks: FirestoreService.getLandmarksWithDistances(
                                          busLine,
                                          direction,
                                          userLocation!,
                                        ),
                                        color: color,
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TripDetails extends StatelessWidget {
  final List<Map<String, dynamic>> landmarks;
  final Color color;
  const _TripDetails({required this.landmarks, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('اماكن المحطات', style: TextStyle(color: Colors.grey)),
              Text(' المسافة ', style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          ...List.generate(landmarks.length, (i) {
            final landmark = landmarks[i];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.circle, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(landmark['name'], style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                  Row(
                    children: [
                      Text(landmark['formattedDistance'], style: const TextStyle(fontSize: 15)),
                      const SizedBox(width: 4),
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

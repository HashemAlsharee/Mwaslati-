import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/route_service.dart';
import '../../core/services/maps_service.dart';
import '../../core/services/firestore_service.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  double _sheetExtent = 0.5; // Start in the middle
  bool _loadingLocation = true;
  bool _loadingRoute = false;
  bool _isSelectingLocation = false; // New state for location selection mode
  Position? _currentPosition;
  LatLng? _startLocation;
  LatLng? _endLocation;
  RouteResult? _routeResult;
  String _errorMessage = '';
  Set<Polyline> _routePolylines = {};
  Set<Marker> _routeMarkers = {};
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _detectCurrentLocation();
  }

  Future<void> _detectCurrentLocation() async {
    setState(() {
      _loadingLocation = true;
      _errorMessage = '';
    });
    
    try {
      // Get current location using the MapsService
      Position? position = await RouteService.getUserLocation();
      
      if (position != null && mounted) {
        // Get the nearest landmark or address for this location
        _currentPosition = position;
        _startLocation = LatLng(position.latitude, position.longitude);
        
        // Find nearby bus lines to determine a recognizable location name
        List<BusLine> nearbyLines = await RouteService.findNearbyBusLines(_startLocation!);
        String locationName = 'موقعي الحالي';
        
        if (nearbyLines.isNotEmpty) {
          // Find the closest point on the nearest bus line
          LatLng closestPoint = RouteService.findClosestPointOnPolyline(
            _startLocation!,
            nearbyLines.first.polyline,
          );
          
          // Find the nearest landmark to this point
          Landmark nearestLandmark = RouteService.findNearestLandmark(
            closestPoint,
            nearbyLines.first.landmarksGo,
          );
          
          locationName = 'موقعي الحالي (${nearestLandmark.name})';
        }
        
        setState(() {
          fromController.text = locationName;
          _loadingLocation = false;
          
          // Move map camera to current location
          if (_mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: _startLocation!,
                  zoom: 15,
                ),
              ),
            );
          }
        });
      } else {
        setState(() {
          _loadingLocation = false;
          _errorMessage = 'لم يتم العثور على الموقع الحالي';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
          _errorMessage = 'حدث خطأ أثناء تحديد الموقع';
        });
      }
    }
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  void swapFields() {
    setState(() {
      final temp = fromController.text;
      fromController.text = toController.text;
      toController.text = temp;
    });
  }

  void useMyLocation() {
    setState(() {
      fromController.text = 'موقعي الحالي';
    });
  }

  void openMapOverlay() async {
    setState(() {
      _isSelectingLocation = true;
      _sheetExtent = 0.1; // Minimize the sheet to show more map
    });
    
    // Show a temporary overlay to guide the user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('انقر على الخريطة لاختيار الموقع'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _onMapTap(LatLng location) {
    if (_isSelectingLocation) {
      // Get the location name from the map
      _selectLocationFromMap(location);
    }
  }

  void _selectLocationFromMap(LatLng location) async {
    try {
      // Try to get a meaningful name for the location
      String locationName = 'موقع مختار من الخريطة';
      
      // You can add reverse geocoding here if needed
      // For now, we'll use a simple approach
      
      setState(() {
        _endLocation = location;
        toController.text = locationName;
        _isSelectingLocation = false;
        _sheetExtent = 0.5; // Return to middle size
        
        // Clear previous route results when destination changes
        _routeResult = null;
        _routePolylines = {};
        _routeMarkers = {};
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم اختيار الموقع بنجاح'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isSelectingLocation = false;
        _sheetExtent = 0.5;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء اختيار الموقع'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _cancelLocationSelection() {
    setState(() {
      _isSelectingLocation = false;
      _sheetExtent = 0.5;
    });
  }
  
  /// Plan a route from start to destination
  Future<void> _planRoute() async {
    // Validate that we have both start and end locations
    if (_startLocation == null) {
      setState(() {
        _errorMessage = 'الرجاء تحديد موقع البداية';
      });
      return;
    }
    
    if (_endLocation == null) {
      setState(() {
        _errorMessage = 'الرجاء تحديد الوجهة';
      });
      return;
    }
    
    setState(() {
      _loadingRoute = true;
      _errorMessage = '';
      _routeResult = null;
      _routePolylines = {};
      _routeMarkers = {};
    });
    
    try {
      // Call the route planning service
      RouteResult result = await RouteService.planRoute(_startLocation!, _endLocation!);
      
      if (result.status == 'success' || result.status == 'walking') {
        // Create polylines and markers for the route
        Set<Polyline> polylines = {};
        Set<Marker> markers = {};
        
        // Add start marker
        markers.add(Marker(
          markerId: const MarkerId('start'),
          position: _startLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: fromController.text),
        ));
        
        // Add end marker
        markers.add(Marker(
          markerId: const MarkerId('end'),
          position: _endLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: toController.text),
        ));
        
        // For walking routes, add a direct polyline
        if (result.status == 'walking') {
          polylines.add(Polyline(
            polylineId: const PolylineId('walking'),
            points: [_startLocation!, _endLocation!],
            color: Colors.orange,
            width: 5,
            patterns: [PatternItem.dash(20), PatternItem.gap(10)], // Dashed line for walking
          ));
        } else {
          // Process each route segment for bus routes
          for (int i = 0; i < result.segments.length; i++) {
            RouteSegment segment = result.segments[i];
            
            // Add polyline for this segment
            polylines.add(Polyline(
              polylineId: PolylineId('segment_$i'),
              points: segment.segmentPolyline,
              color: i == 0 ? Colors.blue : Colors.green,
              width: 5,
            ));
            
            // Add transfer point marker if this isn't the last segment
            if (i < result.segments.length - 1) {
              markers.add(Marker(
                markerId: MarkerId('transfer_$i'),
                position: segment.endPoint,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
                infoWindow: InfoWindow(
                  title: 'نقطة تحويل',
                  snippet: 'من ${segment.busLineName} إلى ${result.segments[i + 1].busLineName}',
                ),
              ));
            }
          }
        }
        
        setState(() {
          _routeResult = result;
          _routePolylines = polylines;
          _routeMarkers = markers;
          _loadingRoute = false;
          
          // Adjust map to show the route
          if (_mapController != null) {
            // Calculate bounds to include all points
            double minLat = double.infinity;
            double maxLat = -double.infinity;
            double minLng = double.infinity;
            double maxLng = -double.infinity;
            
            // Include start and end points
            minLat = min(minLat, _startLocation!.latitude);
            maxLat = max(maxLat, _startLocation!.latitude);
            minLng = min(minLng, _startLocation!.longitude);
            maxLng = max(maxLng, _startLocation!.longitude);
            
            minLat = min(minLat, _endLocation!.latitude);
            maxLat = max(maxLat, _endLocation!.latitude);
            minLng = min(minLng, _endLocation!.longitude);
            maxLng = max(maxLng, _endLocation!.longitude);
            
            // Include all polyline points
            for (var polyline in polylines) {
              for (var point in polyline.points) {
                minLat = min(minLat, point.latitude);
                maxLat = max(maxLat, point.latitude);
                minLng = min(minLng, point.longitude);
                maxLng = max(maxLng, point.longitude);
              }
            }
            
            // Add padding
            LatLngBounds bounds = LatLngBounds(
              southwest: LatLng(minLat, minLng),
              northeast: LatLng(maxLat, maxLng),
            );
            
            _mapController!.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 50),
            );
          }
        });
      } else {
        setState(() {
          _loadingRoute = false;
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _loadingRoute = false;
        _errorMessage = 'حدث خطأ أثناء تخطيط المسار';
      });
    }
  }

  /// Build a card widget for displaying route segment information
  Widget _buildRouteSegmentCard({
    required RouteSegment segment,
    required bool isFirstSegment,
    required bool isLastSegment,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isFirstSegment ? Colors.green : Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.directions_bus,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        segment.busLineName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${segment.startLandmarkName} → ${segment.endLandmarkName}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  MapsService.formatDistance(segment.distanceMeters),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    segment.startLandmarkName,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    segment.endLandmarkName,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // Google Map with route display
            GoogleMap(
              initialCameraPosition: _startLocation != null
                  ? CameraPosition(target: _startLocation!, zoom: 15)
                  : MapsService.getInitialCameraPosition(),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              compassEnabled: true,
              markers: _routeMarkers,
              polylines: _routePolylines,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              onTap: _onMapTap, // Add tap handler for location selection
            ),
            
            // Location selection overlay
            if (_isSelectingLocation)
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'انقر على الخريطة لاختيار الموقع',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: _cancelLocationSelection,
                        child: const Text('إلغاء', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Location button (for map, not for input)
            Positioned(
              bottom: 120,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  if (_currentPosition != null && _mapController != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          zoom: 15,
                        ),
                      ),
                    );
                  } else {
                    _detectCurrentLocation();
                  }
                },
                child: const Icon(Icons.my_location),
              ),
            ),
            
            // Search button (to trigger route planning)
            // Positioned(
            //   bottom: 120,
            //   left: 16,
            //   child: FloatingActionButton(
            //     backgroundColor: Colors.green,
            //     onPressed: _loadingRoute ? null : () => _planRoute(),
            //     child: _loadingRoute 
            //         ? const CircularProgressIndicator(color: Colors.white)
            //         : const Icon(Icons.search),
            //   ),
            // ),
            
            // Error message display
            if (_errorMessage.isNotEmpty)
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            // DraggableScrollableSheet for input fields and how it works
            NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                setState(() {
                  _sheetExtent = notification.extent;
                });
                return true;
              },
              child: DraggableScrollableSheet(
                initialChildSize: _sheetExtent,
                minChildSize: 0.1,
                maxChildSize: 0.7,
                builder: (context, scrollController) {
                  final bool showHowItWorks = _sheetExtent > 0.45;
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      children: [
                        Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        if (!_isSelectingLocation) // Only show input fields when not selecting location
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            child: Column(
                              children: [
                                // FROM FIELD and SWAP BUTTON in a Row
                                Row(
                                  children: [
                                    // FROM FIELD (narrower)
                                    Expanded(
                                      flex: 4,
                                      child: TextField(
                                        controller: fromController,
                                        readOnly: false,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                          hintText: _loadingLocation ? 'جاري تحديد الموقع...' : 'من:',
                                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // SWAP BUTTON
                                    IconButton(
                                      icon: const Icon(Icons.swap_vert, color: Colors.blue),
                                      onPressed: swapFields,
                                      tooltip: 'تبديل',
                                    ),
                                  ],
                                ),
                                if (fromController.text != 'موقعي الحالي')
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: useMyLocation,
                                      icon: const Icon(Icons.my_location, color: Colors.blue, size: 18),
                                      label: const Text('استخدم موقعي الحالي', style: TextStyle(color: Colors.blue)),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                // TO FIELD and SEARCH BUTTON in a Row
                                Row(
                                  children: [
                                    // TO FIELD (narrower)
                                    Expanded(
                                      flex: 4,
                                      child: TextField(
                                        controller: toController,
                                        readOnly: false,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                          hintText: 'إلى:',
                                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                          suffixIcon: IconButton(
                                            icon: const Icon(Icons.location_on, color: Colors.red),
                                            onPressed: openMapOverlay,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // SEARCH BUTTON
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: _loadingRoute ? null : () => _planRoute(),
                                      child: _loadingRoute
                                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                          : const Icon(Icons.search, color: Colors.white),
                                    ),
                                  ],
                                ),
                                // 'اختيار من الخريطة' button
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: openMapOverlay,
                                    icon: const Icon(Icons.location_on, color: Colors.red, size: 18),
                                    label: const Text('اختيار من الخريطة', style: TextStyle(color: Colors.red)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Route results display
                        if (_routeResult != null && (_routeResult!.status == 'success' || _routeResult!.status == 'walking') && !_isSelectingLocation)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('تفاصيل الرحلة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    Text(
                                      'المسافة: ${MapsService.formatDistance(_routeResult!.totalDistanceMeters)}',
                                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                // Walking route display
                                if (_routeResult!.status == 'walking')
                                  Card(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.orange,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: const Icon(
                                                  Icons.directions_walk,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'مشي',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${fromController.text} → ${toController.text}',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                MapsService.formatDistance(_routeResult!.totalDistanceMeters),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'المسافة قصيرة، يمكنك المشي مباشرة إلى وجهتك.',
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else ...[  // Bus route display
                                  if (_routeResult!.transferCount > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        'عدد التحويلات: ${_routeResult!.transferCount}',
                                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  
                                  // Display each segment
                                  for (int i = 0; i < _routeResult!.segments.length; i++) ...[                                  
                                    _buildRouteSegmentCard(
                                      segment: _routeResult!.segments[i],
                                      isFirstSegment: i == 0,
                                      isLastSegment: i == _routeResult!.segments.length - 1,
                                    ),
                                    if (i < _routeResult!.segments.length - 1)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8),
                                        child: Row(
                                          children: [
                                            Icon(Icons.arrow_downward, color: Colors.grey),
                                            SizedBox(width: 8),
                                            Text('تغيير الباص', style: TextStyle(color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ],
                              ],
                            ),
                          )
                        // How it works section
                        else if (showHowItWorks && !_isSelectingLocation)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('كيف تعمل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Icon(Icons.search, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text('ابحث من أين تريد أن تبدأ ومن أين تنتهي رحلتك عبر شوارع العاصمة صنعاء.'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Icon(Icons.alt_route, color: Colors.green),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text('اعثر على أفضل مسار: اختر من بين خيارات الطرق.'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Icon(Icons.emoji_emotions, color: Colors.orange),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text('استمتع بوجهتك: استرخ وتنقل براحة!'),
                                    ),
                                  ],
                                ),
                              ],
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
    );
  }
}

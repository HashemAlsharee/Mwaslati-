import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'firestore_service.dart';
import 'maps_service.dart';

class RouteResult {
  final String routeId;
  final List<RouteSegment> segments;
  final double totalDistanceMeters;
  final int transferCount;
  final String status;
  final String message;

  RouteResult({
    required this.routeId,
    required this.segments,
    required this.totalDistanceMeters,
    required this.transferCount,
    required this.status,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      'segments': segments.map((segment) => segment.toJson()).toList(),
      'totalDistanceMeters': totalDistanceMeters,
      'transferCount': transferCount,
      'status': status,
      'message': message,
    };
  }
}

class RouteSegment {
  final String busLineId;
  final String busLineName;
  final LatLng startPoint;
  final LatLng endPoint;
  final String startLandmarkName;
  final String endLandmarkName;
  final double distanceMeters;
  final List<LatLng> segmentPolyline;

  RouteSegment({
    required this.busLineId,
    required this.busLineName,
    required this.startPoint,
    required this.endPoint,
    required this.startLandmarkName,
    required this.endLandmarkName,
    required this.distanceMeters,
    required this.segmentPolyline,
  });

  Map<String, dynamic> toJson() {
    return {
      'busLineId': busLineId,
      'busLineName': busLineName,
      'startPoint': {
        'latitude': startPoint.latitude,
        'longitude': startPoint.longitude,
      },
      'endPoint': {
        'latitude': endPoint.latitude,
        'longitude': endPoint.longitude,
      },
      'startLandmarkName': startLandmarkName,
      'endLandmarkName': endLandmarkName,
      'distanceMeters': distanceMeters,
      'segmentPolyline': segmentPolyline
          .map((point) => {
                'latitude': point.latitude,
                'longitude': point.longitude,
              })
          .toList(),
    };
  }
}

class RouteService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _busLinesCollection = 'bus_lines';
  static const double _nearbyThresholdMeters = 300.0; // 300 meters
  static const double _transferThresholdMeters = 150.0; // 150 meters for transfer points

  /// Get user's current location
  static Future<Position?> getUserLocation() async {
    return await MapsService.getCurrentLocation();
  }

  /// Find nearby bus lines based on user's location
  static Future<List<BusLine>> findNearbyBusLines(LatLng location) async {
    try {
      // Convert LatLng to Position for distance calculation
      Position userPosition = Position(
        latitude: location.latitude,
        longitude: location.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      // Get all bus lines from Firestore
      QuerySnapshot snapshot = await _firestore
          .collection(_busLinesCollection)
          .where('active', isEqualTo: true)
          .get();

      List<BusLine> nearbyBusLines = [];

      // Check each bus line to see if it's near the user
      for (var doc in snapshot.docs) {
        BusLine busLine = BusLine.fromFirestore(doc);
        
        // Calculate distance from user to bus line
        double distance = MapsService.calculateDistanceToPolyline(
          userPosition,
          busLine.polyline,
        );

        // If the bus line is within threshold, add it to the list
        if (distance <= _nearbyThresholdMeters) {
          nearbyBusLines.add(busLine);
        }
      }

      return nearbyBusLines;
    } catch (e) {
      print('Error finding nearby bus lines: $e');
      return [];
    }
  }

  /// Find the closest point on a polyline to a given location
  static LatLng findClosestPointOnPolyline(LatLng location, List<LatLng> polyline) {
    if (polyline.isEmpty) return location;

    double minDistance = double.infinity;
    LatLng closestPoint = polyline.first;

    for (int i = 0; i < polyline.length - 1; i++) {
      LatLng p1 = polyline[i];
      LatLng p2 = polyline[i + 1];

      // Calculate the closest point on this line segment
      LatLng point = _closestPointOnLineSegment(location, p1, p2);
      
      // Calculate distance to this point
      double distance = Geolocator.distanceBetween(
        location.latitude,
        location.longitude,
        point.latitude,
        point.longitude,
      );

      // Update if this is the closest point so far
      if (distance < minDistance) {
        minDistance = distance;
        closestPoint = point;
      }
    }

    return closestPoint;
  }

  /// Find the closest point on a line segment to a given point
  static LatLng _closestPointOnLineSegment(LatLng p, LatLng v, LatLng w) {
    // Line segment: v to w
    // Point: p
    // Return the closest point on the line segment to p

    double lengthSquared = _distanceSquared(v, w);
    
    // If v == w, return v
    if (lengthSquared == 0) return v;

    // Calculate projection of p onto the line segment
    double t = ((p.latitude - v.latitude) * (w.latitude - v.latitude) +
            (p.longitude - v.longitude) * (w.longitude - v.longitude)) /
        lengthSquared;

    // Clamp t to [0, 1] to ensure the point is on the segment
    t = t.clamp(0.0, 1.0);

    // Calculate the closest point
    return LatLng(
      v.latitude + t * (w.latitude - v.latitude),
      v.longitude + t * (w.longitude - v.longitude),
    );
  }

  /// Calculate squared distance between two points
  static double _distanceSquared(LatLng p1, LatLng p2) {
    return (p1.latitude - p2.latitude) * (p1.latitude - p2.latitude) +
        (p1.longitude - p2.longitude) * (p1.longitude - p2.longitude);
  }

  /// Find the nearest landmark to a point on a bus line
  static Landmark findNearestLandmark(LatLng point, List<Landmark> landmarks) {
    if (landmarks.isEmpty) {
      // Return a default landmark if the list is empty
      return Landmark(
        name: 'Unknown Location',
        location: point,
      );
    }

    Landmark nearest = landmarks.first;
    double minDistance = Geolocator.distanceBetween(
      point.latitude,
      point.longitude,
      nearest.location.latitude,
      nearest.location.longitude,
    );

    for (var landmark in landmarks) {
      double distance = Geolocator.distanceBetween(
        point.latitude,
        point.longitude,
        landmark.location.latitude,
        landmark.location.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearest = landmark;
      }
    }

    return nearest;
  }

  /// Check if a point is on a bus line (within threshold)
  static bool isPointOnBusLine(LatLng point, List<LatLng> polyline, {double threshold = 100.0}) {
    // Convert LatLng to Position for distance calculation
    Position position = Position(
      latitude: point.latitude,
      longitude: point.longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );

    double distance = MapsService.calculateDistanceToPolyline(position, polyline);
    return distance <= threshold;
  }

  /// Extract a segment of a polyline between two points
  static List<LatLng> extractPolylineSegment(List<LatLng> polyline, LatLng startPoint, LatLng endPoint) {
    if (polyline.isEmpty) return [];

    // Find the indices of the closest points to start and end
    int startIndex = 0;
    int endIndex = polyline.length - 1;
    double minStartDistance = double.infinity;
    double minEndDistance = double.infinity;

    for (int i = 0; i < polyline.length; i++) {
      double startDistance = Geolocator.distanceBetween(
        startPoint.latitude,
        startPoint.longitude,
        polyline[i].latitude,
        polyline[i].longitude,
      );

      double endDistance = Geolocator.distanceBetween(
        endPoint.latitude,
        endPoint.longitude,
        polyline[i].latitude,
        polyline[i].longitude,
      );

      if (startDistance < minStartDistance) {
        minStartDistance = startDistance;
        startIndex = i;
      }

      if (endDistance < minEndDistance) {
        minEndDistance = endDistance;
        endIndex = i;
      }
    }

    // Ensure start comes before end in the polyline
    if (startIndex > endIndex) {
      int temp = startIndex;
      startIndex = endIndex;
      endIndex = temp;
    }

    // Extract the segment
    return polyline.sublist(startIndex, endIndex + 1);
  }

  /// Plan a route from start to destination
  static Future<RouteResult> planRoute(LatLng startLocation, LatLng endLocation) async {
    try {
      // Check if start and end points are very close to each other
      double directDistance = Geolocator.distanceBetween(
        startLocation.latitude,
        startLocation.longitude,
        endLocation.latitude,
        endLocation.longitude,
      );
      
      // If points are very close (less than 500m), suggest walking
      if (directDistance < 500) {
        return RouteResult(
          routeId: 'walking_route',
          segments: [],
          totalDistanceMeters: directDistance,
          transferCount: 0,
          status: 'walking',
          message: 'المسافة قصيرة (${MapsService.formatDistance(directDistance)}). يمكنك المشي مباشرة.',
        );
      }

      // Step 1: Find nearby bus lines for both start and end locations
      List<BusLine> startNearbyLines = await findNearbyBusLines(startLocation);
      List<BusLine> endNearbyLines = await findNearbyBusLines(endLocation);

      // Step 2: Check if there's a direct route (same bus line for both points)
      for (var startLine in startNearbyLines) {
        for (var endLine in endNearbyLines) {
          if (startLine.lineId == endLine.lineId) {
            // Direct route found
            return _createDirectRoute(startLine, startLocation, endLocation);
          }
        }
      }

      // Step 3: If no direct route, try to find a route with transfers
      if (startNearbyLines.isNotEmpty && endNearbyLines.isNotEmpty) {
        return await _findTransferRoute(startNearbyLines, endNearbyLines, startLocation, endLocation);
      }

      // Step 4: No route found
      if (startNearbyLines.isEmpty) {
        return RouteResult(
          routeId: 'no_route',
          segments: [],
          totalDistanceMeters: 0,
          transferCount: 0,
          status: 'error',
          message: 'لا توجد خطوط باص قريبة من نقطة البداية',
        );
      } else if (endNearbyLines.isEmpty) {
        return RouteResult(
          routeId: 'no_route',
          segments: [],
          totalDistanceMeters: 0,
          transferCount: 0,
          status: 'error',
          message: 'لا توجد خطوط باص قريبة من نقطة النهاية',
        );
      } else {
        return RouteResult(
          routeId: 'no_route',
          segments: [],
          totalDistanceMeters: 0,
          transferCount: 0,
          status: 'error',
          message: 'لا يمكن إيجاد مسار بين النقطتين',
        );
      }
    } catch (e) {
      print('Error planning route: $e');
      return RouteResult(
        routeId: 'error',
        segments: [],
        totalDistanceMeters: 0,
        transferCount: 0,
        status: 'error',
        message: 'حدث خطأ أثناء تخطيط المسار',
      );
    }
  }

  /// Create a direct route (single bus line)
  static RouteResult _createDirectRoute(BusLine busLine, LatLng startLocation, LatLng endLocation) {
    // Find closest points on the polyline
    LatLng startPoint = findClosestPointOnPolyline(startLocation, busLine.polyline);
    LatLng endPoint = findClosestPointOnPolyline(endLocation, busLine.polyline);

    // Find nearest landmarks
    Landmark startLandmark = findNearestLandmark(startPoint, busLine.landmarksGo);
    Landmark endLandmark = findNearestLandmark(endPoint, busLine.landmarksGo);

    // Extract the polyline segment for this route
    List<LatLng> segmentPolyline = extractPolylineSegment(busLine.polyline, startPoint, endPoint);

    // Calculate distance
    double distanceMeters = _calculatePolylineDistance(segmentPolyline);

    // Create route segment
    RouteSegment segment = RouteSegment(
      busLineId: busLine.lineId,
      busLineName: busLine.name,
      startPoint: startPoint,
      endPoint: endPoint,
      startLandmarkName: startLandmark.name,
      endLandmarkName: endLandmark.name,
      distanceMeters: distanceMeters,
      segmentPolyline: segmentPolyline,
    );

    // Create and return the route result
    return RouteResult(
      routeId: 'direct_${busLine.lineId}',
      segments: [segment],
      totalDistanceMeters: distanceMeters,
      transferCount: 0,
      status: 'success',
      message: 'تم العثور على مسار مباشر',
    );
  }

  /// Find a route with transfers using a simplified approach
  static Future<RouteResult> _findTransferRoute(
      List<BusLine> startLines, List<BusLine> endLines, LatLng startLocation, LatLng endLocation) async {
    
    print('🔍 Starting transfer route search...');
    print('📍 Start lines found: ${startLines.length}');
    print('🎯 End lines found: ${endLines.length}');
    
    // Get all bus lines to find potential transfer points
    QuerySnapshot snapshot = await _firestore
        .collection(_busLinesCollection)
        .where('active', isEqualTo: true)
        .get();

    List<BusLine> allBusLines = snapshot.docs.map((doc) => BusLine.fromFirestore(doc)).toList();
    print('🚌 Total active bus lines: ${allBusLines.length}');
    
    // Find all possible routes with up to 2 transfers (3 segments max)
    List<RouteCandidate> possibleRoutes = [];
    
    // Try to find routes for each combination of start and end lines
    for (var startLine in startLines) {
      for (var endLine in endLines) {
        if (startLine.lineId == endLine.lineId) continue; // Skip if same line
        
        print('🔄 Checking transfer from ${startLine.name} to ${endLine.name}');
        
        // Find direct transfers between start and end lines
        List<TransferPoint> directTransfers = _findTransferPoints(startLine, endLine);
        print('📍 Direct transfer points found: ${directTransfers.length}');
        
        for (var transfer in directTransfers) {
          RouteCandidate? route = _createTransferRoute(
            startLine, endLine, startLocation, endLocation, transfer);
          if (route != null) {
            possibleRoutes.add(route);
            print('✅ Direct transfer route created');
          }
        }
        
        // If no direct transfer, try to find routes with one intermediate line
        if (directTransfers.isEmpty) {
          print('🔍 No direct transfer, searching for intermediate routes...');
          int intermediateRoutesFound = 0;
          
          for (var intermediateLine in allBusLines) {
            if (intermediateLine.lineId == startLine.lineId || 
                intermediateLine.lineId == endLine.lineId) {
              continue;
            }
            
            // Find transfers from start to intermediate
            List<TransferPoint> transfers1 = _findTransferPoints(startLine, intermediateLine);
            // Find transfers from intermediate to end
            List<TransferPoint> transfers2 = _findTransferPoints(intermediateLine, endLine);
            
            // If both transfers exist, create a two-transfer route
            if (transfers1.isNotEmpty && transfers2.isNotEmpty) {
              print('🔄 Found intermediate route via ${intermediateLine.name}');
              // Use the first transfer point from each set
              RouteCandidate? route = _createTwoTransferRoute(
                startLine, intermediateLine, endLine, 
                startLocation, endLocation, 
                transfers1.first, transfers2.first);
              if (route != null) {
                possibleRoutes.add(route);
                intermediateRoutesFound++;
              }
            }
          }
          print('✅ Intermediate routes found: $intermediateRoutesFound');
        }
      }
    }
    
    print('📊 Total possible routes found: ${possibleRoutes.length}');
    
    // Sort routes by total distance and number of transfers
    possibleRoutes.sort((a, b) {
      // First sort by number of transfers (fewer is better)
      if (a.segments.length != b.segments.length) {
        return a.segments.length.compareTo(b.segments.length);
      }
      
      // Then sort by total distance (shorter is better)
      return a.totalDistance.compareTo(b.totalDistance);
    });
    
    // Return the best route if found
    if (possibleRoutes.isNotEmpty) {
      RouteCandidate bestRoute = possibleRoutes.first;
      print('🏆 Best route selected with ${bestRoute.segments.length} segments');
      
      // Calculate total walking distance at transfer points
      double totalWalkingDistance = 0.0;
      for (int i = 0; i < bestRoute.segments.length - 1; i++) {
        RouteSegment current = bestRoute.segments[i];
        RouteSegment next = bestRoute.segments[i + 1];
        
        // Calculate walking distance between end of current segment and start of next segment
        totalWalkingDistance += Geolocator.distanceBetween(
          current.endPoint.latitude,
          current.endPoint.longitude,
          next.startPoint.latitude,
          next.startPoint.longitude,
        );
      }
      
      String routeId = 'route_${bestRoute.segments.map((s) => s.busLineId).join('_')}';
      String message = bestRoute.segments.length > 1 
          ? 'تم العثور على مسار مع ${bestRoute.segments.length - 1} تحويلة. مسافة المشي الإجمالية: ${MapsService.formatDistance(totalWalkingDistance)}'
          : 'تم العثور على مسار مباشر';
      
      print('🎉 Transfer route successfully created!');
      return RouteResult(
        routeId: routeId,
        segments: bestRoute.segments,
        totalDistanceMeters: bestRoute.totalDistance,
        transferCount: bestRoute.segments.length - 1,
        status: 'success',
        message: message,
      );
    } else {
      print('❌ No transfer routes found');
      return RouteResult(
        routeId: 'no_transfer_route',
        segments: [],
        totalDistanceMeters: 0,
        transferCount: 0,
        status: 'error',
        message: 'لا يمكن إيجاد مسار بين النقطتين. قد تكون المسافة بين خطوط الحافلات كبيرة جدًا أو غير متصلة',
      );
    }
  }
  
  /// Find transfer points between two bus lines
  static List<TransferPoint> _findTransferPoints(BusLine line1, BusLine line2) {
    List<TransferPoint> transferPoints = [];
    
    // Check each point on line1 against each point on line2
    // Use a sampling approach to improve performance
    int skipRate = max(1, line1.polyline.length ~/ 20); // Check every 20th point or every point if polyline is short
    
    print('🔍 Checking ${line1.polyline.length} points on ${line1.name} against ${line2.polyline.length} points on ${line2.name}');
    print('📏 Using skip rate: $skipRate, threshold: ${_transferThresholdMeters}m');
    
    for (int i = 0; i < line1.polyline.length; i += skipRate) {
      LatLng point1 = line1.polyline[i];
      
      for (int j = 0; j < line2.polyline.length; j += skipRate) {
        LatLng point2 = line2.polyline[j];
        
        // Calculate distance between points
        double distance = Geolocator.distanceBetween(
          point1.latitude,
          point1.longitude,
          point2.latitude,
          point2.longitude,
        );
        
        // If distance is within threshold, add as potential transfer point
        if (distance <= _transferThresholdMeters) {
          // Check if we already have a transfer point very close to this one
          bool isDuplicate = false;
          for (var existingPoint in transferPoints) {
            double distToExisting1 = Geolocator.distanceBetween(
              point1.latitude,
              point1.longitude,
              existingPoint.pointOnLine1.latitude,
              existingPoint.pointOnLine1.longitude,
            );
            
            double distToExisting2 = Geolocator.distanceBetween(
              point2.latitude,
              point2.longitude,
              existingPoint.pointOnLine2.latitude,
              existingPoint.pointOnLine2.longitude,
            );
            
            // If both points are very close to an existing transfer point, consider it a duplicate
            if (distToExisting1 < 30 && distToExisting2 < 30) {
              isDuplicate = true;
              
              // If this point is closer than the existing one, replace it
              if (distance < existingPoint.transferDistanceMeters) {
                existingPoint.pointOnLine1 = point1;
                existingPoint.pointOnLine2 = point2;
                existingPoint.transferDistanceMeters = distance;
              }
              break;
            }
          }
          
          // Add new transfer point if not a duplicate
          if (!isDuplicate) {
            transferPoints.add(TransferPoint(
              pointOnLine1: point1,
              pointOnLine2: point2,
              transferDistanceMeters: distance,
            ));
          }
        }
      }
    }
    
    // Sort transfer points by distance (shortest first)
    transferPoints.sort((a, b) => a.transferDistanceMeters.compareTo(b.transferDistanceMeters));
    
    // Limit the number of transfer points to avoid performance issues
    if (transferPoints.length > 3) {
      transferPoints = transferPoints.sublist(0, 3);
    }
    
    print('📍 Found ${transferPoints.length} transfer points between ${line1.name} and ${line2.name}');
    if (transferPoints.isNotEmpty) {
      print('   Closest transfer: ${transferPoints.first.transferDistanceMeters.toStringAsFixed(1)}m');
    }
    
    return transferPoints;
  }
  
  /// Create a route with one transfer
  static RouteCandidate? _createTransferRoute(
      BusLine startLine, BusLine endLine, 
      LatLng startLocation, LatLng endLocation, 
      TransferPoint transfer) {
    
    try {
      // Create first segment: from start location to transfer point on start line
      LatLng startPoint = findClosestPointOnPolyline(startLocation, startLine.polyline);
      List<LatLng> segment1Polyline = extractPolylineSegment(
        startLine.polyline, startPoint, transfer.pointOnLine1);
      
      double distance1 = _calculatePolylineDistance(segment1Polyline);
      
      // Find landmarks for first segment
      Landmark startLandmark1 = findNearestLandmark(startPoint, startLine.landmarksGo);
      Landmark endLandmark1 = findNearestLandmark(transfer.pointOnLine1, startLine.landmarksGo);
      
      RouteSegment segment1 = RouteSegment(
        busLineId: startLine.lineId,
        busLineName: startLine.name,
        startPoint: startPoint,
        endPoint: transfer.pointOnLine1,
        startLandmarkName: startLandmark1.name,
        endLandmarkName: endLandmark1.name,
        distanceMeters: distance1,
        segmentPolyline: segment1Polyline,
      );
      
      // Create second segment: from transfer point on end line to destination
      LatLng endPoint = findClosestPointOnPolyline(endLocation, endLine.polyline);
      List<LatLng> segment2Polyline = extractPolylineSegment(
        endLine.polyline, transfer.pointOnLine2, endPoint);
      
      double distance2 = _calculatePolylineDistance(segment2Polyline);
      
      // Find landmarks for second segment
      Landmark startLandmark2 = findNearestLandmark(transfer.pointOnLine2, endLine.landmarksGo);
      Landmark endLandmark2 = findNearestLandmark(endPoint, endLine.landmarksGo);
      
      RouteSegment segment2 = RouteSegment(
        busLineId: endLine.lineId,
        busLineName: endLine.name,
        startPoint: transfer.pointOnLine2,
        endPoint: endPoint,
        startLandmarkName: startLandmark2.name,
        endLandmarkName: endLandmark2.name,
        distanceMeters: distance2,
        segmentPolyline: segment2Polyline,
      );
      
      double totalDistance = distance1 + distance2;
      
      return RouteCandidate(
        segments: [segment1, segment2],
        totalDistance: totalDistance,
      );
    } catch (e) {
      print('Error creating transfer route: $e');
      return null;
    }
  }
  
  /// Create a route with two transfers
  static RouteCandidate? _createTwoTransferRoute(
      BusLine startLine, BusLine intermediateLine, BusLine endLine,
      LatLng startLocation, LatLng endLocation,
      TransferPoint transfer1, TransferPoint transfer2) {
    
    try {
      // Create first segment: from start location to first transfer point
      LatLng startPoint = findClosestPointOnPolyline(startLocation, startLine.polyline);
      List<LatLng> segment1Polyline = extractPolylineSegment(
        startLine.polyline, startPoint, transfer1.pointOnLine1);
      
      double distance1 = _calculatePolylineDistance(segment1Polyline);
      
      // Find landmarks for first segment
      Landmark startLandmark1 = findNearestLandmark(startPoint, startLine.landmarksGo);
      Landmark endLandmark1 = findNearestLandmark(transfer1.pointOnLine1, startLine.landmarksGo);
      
      RouteSegment segment1 = RouteSegment(
        busLineId: startLine.lineId,
        busLineName: startLine.name,
        startPoint: startPoint,
        endPoint: transfer1.pointOnLine1,
        startLandmarkName: startLandmark1.name,
        endLandmarkName: endLandmark1.name,
        distanceMeters: distance1,
        segmentPolyline: segment1Polyline,
      );
      
      // Create second segment: from first transfer to second transfer
      List<LatLng> segment2Polyline = extractPolylineSegment(
        intermediateLine.polyline, transfer1.pointOnLine2, transfer2.pointOnLine1);
      
      double distance2 = _calculatePolylineDistance(segment2Polyline);
      
      // Find landmarks for second segment
      Landmark startLandmark2 = findNearestLandmark(transfer1.pointOnLine2, intermediateLine.landmarksGo);
      Landmark endLandmark2 = findNearestLandmark(transfer2.pointOnLine1, intermediateLine.landmarksGo);
      
      RouteSegment segment2 = RouteSegment(
        busLineId: intermediateLine.lineId,
        busLineName: intermediateLine.name,
        startPoint: transfer1.pointOnLine2,
        endPoint: transfer2.pointOnLine1,
        startLandmarkName: startLandmark2.name,
        endLandmarkName: endLandmark2.name,
        distanceMeters: distance2,
        segmentPolyline: segment2Polyline,
      );
      
      // Create third segment: from second transfer to destination
      LatLng endPoint = findClosestPointOnPolyline(endLocation, endLine.polyline);
      List<LatLng> segment3Polyline = extractPolylineSegment(
        endLine.polyline, transfer2.pointOnLine2, endPoint);
      
      double distance3 = _calculatePolylineDistance(segment3Polyline);
      
      // Find landmarks for third segment
      Landmark startLandmark3 = findNearestLandmark(transfer2.pointOnLine2, endLine.landmarksGo);
      Landmark endLandmark3 = findNearestLandmark(endPoint, endLine.landmarksGo);
      
      RouteSegment segment3 = RouteSegment(
        busLineId: endLine.lineId,
        busLineName: endLine.name,
        startPoint: transfer2.pointOnLine2,
        endPoint: endPoint,
        startLandmarkName: startLandmark3.name,
        endLandmarkName: endLandmark3.name,
        distanceMeters: distance3,
        segmentPolyline: segment3Polyline,
      );
      
      double totalDistance = distance1 + distance2 + distance3;
      
      return RouteCandidate(
        segments: [segment1, segment2, segment3],
        totalDistance: totalDistance,
      );
    } catch (e) {
      print('Error creating two-transfer route: $e');
      return null;
    }
  }
  
  /// Calculate the total distance of a polyline
  static double _calculatePolylineDistance(List<LatLng> polyline) {
    double distance = 0;
    for (int i = 0; i < polyline.length - 1; i++) {
      distance += Geolocator.distanceBetween(
        polyline[i].latitude,
        polyline[i].longitude,
        polyline[i + 1].latitude,
        polyline[i + 1].longitude,
      );
    }
    return distance;
  }
}

class TransferPoint {
  LatLng pointOnLine1;
  LatLng pointOnLine2;
  double transferDistanceMeters;

  TransferPoint({
    required this.pointOnLine1,
    required this.pointOnLine2,
    required this.transferDistanceMeters,
  });
}

class RouteCandidate {
  final List<RouteSegment> segments;
  final double totalDistance;

  RouteCandidate({
    required this.segments,
    required this.totalDistance,
  });
}
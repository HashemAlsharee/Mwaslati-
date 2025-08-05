import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

class MapsService {
  /// Get the Google Maps API key
  static String get apiKey => AppConstants.googleMapsApiKey;
  
  /// Get current user location
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }
  
  /// Create initial camera position
  static CameraPosition getInitialCameraPosition() {
    return const CameraPosition(
      target: LatLng(
        AppConstants.defaultLatitude,
        AppConstants.defaultLongitude,
      ),
      zoom: AppConstants.defaultZoom,
    );
  }
  
  /// Create camera position from coordinates
  static CameraPosition createCameraPosition(double latitude, double longitude, {double zoom = 12.0}) {
    return CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: zoom,
    );
  }
  
  /// Calculate distance between two points using Haversine formula
  static double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
  
  /// Calculate distance from user to a bus line polyline
  static double calculateDistanceToPolyline(Position userLocation, List<LatLng> polyline) {
    if (polyline.isEmpty) return double.infinity;
    
    double minDistance = double.infinity;
    
    for (int i = 0; i < polyline.length - 1; i++) {
      double distance = _distanceToLineSegment(
        userLocation.latitude,
        userLocation.longitude,
        polyline[i].latitude,
        polyline[i].longitude,
        polyline[i + 1].latitude,
        polyline[i + 1].longitude,
      );
      
      if (distance < minDistance) {
        minDistance = distance;
      }
    }
    
    return minDistance;
  }
  
  /// Calculate distance from point to line segment
  static double _distanceToLineSegment(
    double px, double py, double x1, double y1, double x2, double y2) {
    
    double A = px - x1;
    double B = py - y1;
    double C = x2 - x1;
    double D = y2 - y1;
    
    double dot = A * C + B * D;
    double lenSq = C * C + D * D;
    
    if (lenSq == 0) {
      return Geolocator.distanceBetween(px, py, x1, y1);
    }
    
    double param = dot / lenSq;
    
    double xx, yy;
    if (param < 0) {
      xx = x1;
      yy = y1;
    } else if (param > 1) {
      xx = x2;
      yy = y2;
    } else {
      xx = x1 + param * C;
      yy = y1 + param * D;
    }
    
    return Geolocator.distanceBetween(px, py, xx, yy);
  }
  
  /// Check if a bus line is nearby (within threshold)
  static bool isBusLineNearby(Position userLocation, List<LatLng> polyline, {double threshold = 300}) {
    double distance = calculateDistanceToPolyline(userLocation, polyline);
    return distance <= threshold;
  }
  
  /// Format distance for display
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} م';
    } else {
      double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)} كم';
    }
  }
  
  /// Convert GeoPoint to LatLng
  static LatLng geoPointToLatLng(dynamic geoPoint) {
    if (geoPoint is Map<String, dynamic>) {
      return LatLng(geoPoint['latitude'], geoPoint['longitude']);
    }
    return LatLng(geoPoint.latitude, geoPoint.longitude);
  }
  
  /// Convert list of GeoPoints to list of LatLng
  static List<LatLng> geoPointsToLatLngs(List<dynamic> geoPoints) {
    return geoPoints.map((point) {
      if (point is GeoPoint) {
        return LatLng(point.latitude, point.longitude);
      }
      return const LatLng(0, 0);
    }).toList();
  }

  static List<GeoPoint> latLngsToGeoPoints(List<LatLng> latLngs) {
    return latLngs
        .map((latLng) => GeoPoint(latLng.latitude, latLng.longitude))
        .toList();
  }
} 
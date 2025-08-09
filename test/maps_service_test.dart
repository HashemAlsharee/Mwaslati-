import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:busui/core/services/maps_service.dart';

void main() {
  group('Maps Service Tests', () {
    test('getInitialCameraPosition returns valid camera position', () {
      final cameraPosition = MapsService.getInitialCameraPosition();
      expect(cameraPosition, isNotNull);
      expect(cameraPosition.target, isNotNull);
      expect(cameraPosition.zoom, isNotNull);
    });

    test('createCameraPosition returns valid camera position', () {
      const latitude = 24.7136;
      const longitude = 46.6753;
      const zoom = 15.0;

      final cameraPosition = MapsService.createCameraPosition(latitude, longitude, zoom: zoom);
      expect(cameraPosition, isNotNull);
      expect(cameraPosition.target.latitude, equals(latitude));
      expect(cameraPosition.target.longitude, equals(longitude));
      expect(cameraPosition.zoom, equals(zoom));
    });

    test('calculateDistance returns valid distance', () {
      const startLat = 24.7136;
      const startLng = 46.6753;
      const endLat = 24.7137;
      const endLng = 46.6754;

      final distance = MapsService.calculateDistance(startLat, startLng, endLat, endLng);
      expect(distance, isNotNull);
      expect(distance, isA<double>());
      expect(distance, greaterThan(0));
    });

    test('formatDistance formats correctly for meters', () {
      const distanceInMeters = 500.0;
      final formatted = MapsService.formatDistance(distanceInMeters);
      expect(formatted, contains('م'));
      expect(formatted, contains('500'));
    });

    test('formatDistance formats correctly for kilometers', () {
      const distanceInMeters = 1500.0;
      final formatted = MapsService.formatDistance(distanceInMeters);
      expect(formatted, contains('كم'));
      expect(formatted, contains('1.5'));
    });

    test('geoPointToLatLng converts correctly', () {
      const latitude = 24.7136;
      const longitude = 46.6753;
      final geoPoint = {'latitude': latitude, 'longitude': longitude};

      final latLng = MapsService.geoPointToLatLng(geoPoint);
      expect(latLng.latitude, equals(latitude));
      expect(latLng.longitude, equals(longitude));
    });

    test('geoPointsToLatLngs converts list correctly', () {
      final geoPoints = [
        {'latitude': 24.7136, 'longitude': 46.6753},
        {'latitude': 24.7137, 'longitude': 46.6754},
      ];

      final latLngs = MapsService.geoPointsToLatLngs(geoPoints);
      expect(latLngs, hasLength(2));
      expect(latLngs[0].latitude, equals(24.7136));
      expect(latLngs[1].longitude, equals(46.6754));
    });

    test('latLngsToGeoPoints converts correctly', () {
      final latLngs = [
        const LatLng(24.7136, 46.6753),
        const LatLng(24.7137, 46.6754),
      ];

      final geoPoints = MapsService.latLngsToGeoPoints(latLngs);
      expect(geoPoints, hasLength(2));
      expect(geoPoints[0].latitude, equals(24.7136));
      expect(geoPoints[1].longitude, equals(46.6754));
    });
  });
} 
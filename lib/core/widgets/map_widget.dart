import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/logger_service.dart';
import '../services/maps_service.dart';

class BusMapWidget extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final double? initialZoom;
  final Set<Marker>? markers;
  final Set<Polyline>? polylines;
  final Function(LatLng)? onMapTap;
  final Function(CameraPosition)? onCameraMove;
  final Position? userLocation;
  final Function(GoogleMapController)? onMapCreated;

  const BusMapWidget({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialZoom,
    this.markers,
    this.polylines,
    this.onMapTap,
    this.onCameraMove,
    this.userLocation,
    this.onMapCreated,
  });

  @override
  State<BusMapWidget> createState() => _BusMapWidgetState();
}

class _BusMapWidgetState extends State<BusMapWidget> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Get user location
      Position? position = await MapsService.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _currentPosition = position ?? widget.userLocation;
        _isLoading = false;
      });

      // Add user location marker
      if (_currentPosition != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('user_location'),
            position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            infoWindow: const InfoWindow(
              title: 'موقعك الحالي',
              snippet: 'أنت هنا',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      }

      // Add custom markers and polylines
      if (widget.markers != null) {
        _markers.addAll(widget.markers!);
      }
      if (widget.polylines != null) {
        _polylines.addAll(widget.polylines!);
      }

      // Move camera to user location
      if (_currentPosition != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            MapsService.createCameraPosition(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              zoom: widget.initialZoom ?? 15.0,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Debug logging for polylines
    LoggerService.debug('BusMapWidget polylines count: ${widget.polylines?.length ?? 0}');
    if (widget.polylines != null) {
      for (final poly in widget.polylines!) {
        LoggerService.debug('Polyline: id=${poly.polylineId.value}, points=${poly.points.length}');
      }
    }

    return GoogleMap(
      initialCameraPosition: _getInitialCameraPosition(),
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        if (widget.onMapCreated != null) {
          widget.onMapCreated!(controller);
        }
        // Move to user location after map is created
        if (_currentPosition != null) {
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              MapsService.createCameraPosition(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                zoom: widget.initialZoom ?? 15.0,
              ),
            ),
          );
        }
      },
      onTap: widget.onMapTap,
      onCameraMove: widget.onCameraMove,
      markers: widget.markers ?? {},
      polylines: widget.polylines ?? {},
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: true,
    );
  }

  CameraPosition _getInitialCameraPosition() {
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      return MapsService.createCameraPosition(
        widget.initialLatitude!,
        widget.initialLongitude!,
        zoom: widget.initialZoom ?? 12.0,
      );
    } else if (_currentPosition != null) {
      return MapsService.createCameraPosition(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        zoom: widget.initialZoom ?? 15.0,
      );
    } else {
      return MapsService.getInitialCameraPosition();
    }
  }
} 
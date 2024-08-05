// location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  // Check location permission and get the current location if granted
  Future<void> checkLocationPermission(
      Function(LatLng) onLocationRetrieved) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _getCurrentLocation(onLocationRetrieved);
    } else {
      // ignore: avoid_print
      print("El usuario no otorgó permisos de ubicación.");
    }
  }

  // Get the current location and pass it to the provided callback
  Future<void> _getCurrentLocation(Function(LatLng) onLocationRetrieved) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      onLocationRetrieved(LatLng(position.latitude, position.longitude));
    } catch (e) {
      // ignore: avoid_print
      print("Error obteniendo ubicación: $e");
    }
  }

  // Get the current location and return it as a LatLng object
  Future<LatLng?> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      // ignore: avoid_print
      print("Error obteniendo ubicación: $e");
      return null;
    }
  }

  // Stream that provides real-time location updates
  Stream<LatLng> get locationStream async* {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      yield* Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).map(
          (Position position) => LatLng(position.latitude, position.longitude));
    } else {
      // ignore: avoid_print
      print("El usuario no otorgó permisos de ubicación.");
    }
  }
}

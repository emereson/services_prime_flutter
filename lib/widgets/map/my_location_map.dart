import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyLocationMap extends StatefulWidget {
  final LatLng initialPosition;

  const MyLocationMap({
    super.key,
    required this.initialPosition,
  });

  @override
  MyLocationMapState createState() => MyLocationMapState();
}

class MyLocationMapState extends State<MyLocationMap> {
  late GoogleMapController mapController;
  late LatLng _selectedLatLng;

  @override
  void initState() {
    super.initState();
    _selectedLatLng = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _selectedLatLng,
              zoom: 15.0,
            ),
            markers: _buildMarkers(),
            mapType: MapType.normal,
          ),
        ),
        Positioned(
          bottom: 16.0,
          left: 16.0,
          child: FloatingActionButton(
            onPressed: _goToCurrentLocation,
            backgroundColor: Colors.white,
            foregroundColor: Colors.red, // Color del icono
            elevation: 4.0, // Elevación (sombra)
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _moveCameraToPosition(_selectedLatLng);
  }

  void _moveCameraToPosition(LatLng position) {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 15.0,
        ),
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    return {
      Marker(
        markerId: const MarkerId('my-location'),
        position: _selectedLatLng,
        draggable: false,
      ),
    };
  }

  void _goToCurrentLocation() {
    // Implementa la lógica para obtener y mover a la ubicación actual del usuario
    // Aquí puedes usar la ubicación inicial como ejemplo
    _moveCameraToPosition(widget.initialPosition);
  }
}

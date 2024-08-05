import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  final LatLng initialPosition;
  final Function(LatLng) onLocationSelected;

  const MapWidget({
    super.key,
    required this.initialPosition,
    required this.onLocationSelected,
  });

  @override
  MapWidgetState createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  late GoogleMapController mapController;
  LatLng _selectedLatLng = const LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _selectedLatLng = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _selectedLatLng,
        zoom: 15.0,
      ),
      markers: _buildMarkers(),
      onTap: _onMapTap,
      mapType: MapType.normal, // Aquí se especifica el tipo de mapa clásico
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
    return <Marker>{
      Marker(
        markerId: const MarkerId('selected-location'),
        position: _selectedLatLng,
        draggable: true,
        onDragEnd: (newPosition) {
          setState(() {
            _selectedLatLng = newPosition;
          });
          widget.onLocationSelected(newPosition);
        },
      ),
    };
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      _selectedLatLng = latLng;
    });
    widget.onLocationSelected(latLng);
  }
}

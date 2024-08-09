import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tecnyapp_flutter/components/tecnichal/requestList/service_list_panel.dart';
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/screen/technicalScreen/sharing_location_screen.dart';
import 'package:tecnyapp_flutter/service/auth/user_data_service.dart';
import 'package:tecnyapp_flutter/service/location/location_service.dart';
import 'package:tecnyapp_flutter/widgets/drawer/my_drawer.dart';
import 'package:http/http.dart' as http;
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RequestListScreen extends StatefulWidget {
  const RequestListScreen({
    super.key,
  });

  @override
  State<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen> {
  LatLng _myLocation = const LatLng(0, 0);
  bool isLocationRetrieved = false;
  bool _viewScreen = false;
  late GoogleMapController _mapController;
  final socket = IO.io('https://serviciosmap-backend-production.up.railway.app',
      IO.OptionBuilder().setTransports(['websocket']).enableForceNew().build());
  late Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    LocationService().checkLocationPermission((LatLng? latLng) {
      if (latLng != null) {
        setState(() {
          _myLocation = latLng;
          isLocationRetrieved = true;
        });
      }
    });
    Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      sendLocation(_myLocation);
    });
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userJsonString = await UserDataService.getUserData();
    if (userJsonString != null) {
      setState(() {
        userData = jsonDecode(userJsonString);
      });
      validSharingLocation();
      socket.onConnect((_) {
        socket.emit('registerClient', userData['id']);
      });
    }
  }

  Future<void> validSharingLocation() async {
    if (userData.isNotEmpty) {
      final url = Uri.parse(
          '${Config.apiUrl}/proposal/sharing-location/true/technical/${userData['id']}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const SharingLocationScreen()),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _viewScreen = true;
          });
        }
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _goToCurrentLocation() {
    _mapController.animateCamera(CameraUpdate.newLatLngZoom(_myLocation, 17.0));
  }

  void sendLocation(LatLng location) async {
    socket.emit('sendTechnicalLocation', {
      'technical': userData,
      'location': {
        'latitude': _myLocation.latitude.toString(),
        'longitude': _myLocation.longitude.toString(),
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_viewScreen) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: const Text(
            "Lista de Servicios",
            style: TextStyle(fontSize: 20),
          ),
        ),
        drawer: const MyDrawer(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Column(
          children: [
            if (!isLocationRetrieved)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            if (isLocationRetrieved)
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              StreamBuilder<LatLng>(
                                stream: LocationService().locationStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    _myLocation = snapshot.data!;
                                    _mapController.animateCamera(
                                      CameraUpdate.newLatLng(_myLocation),
                                    );
                                    sendLocation(_myLocation);
                                  }
                                  return GoogleMap(
                                    onMapCreated: _onMapCreated,
                                    initialCameraPosition: CameraPosition(
                                      target: _myLocation,
                                      zoom: 17.0,
                                    ),
                                    markers: {
                                      Marker(
                                        markerId:
                                            const MarkerId('currentLocation'),
                                        position: _myLocation,
                                        icon: BitmapDescriptor
                                            .defaultMarkerWithHue(
                                          BitmapDescriptor.hueAzure,
                                        ),
                                      ),
                                    },
                                  );
                                },
                              ),
                              Positioned(
                                left: 16.0,
                                bottom: 16.0,
                                child: FloatingActionButton(
                                  onPressed: _goToCurrentLocation,
                                  backgroundColor: Colors.white,
                                  foregroundColor:
                                      Colors.red, // Color del icono
                                  elevation: 4.0, // Elevación (sombra)
                                  child: const Icon(Icons.my_location),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                    ServiceListPanel(
                        socket: socket,
                        userData: userData,
                        myLocation: _myLocation),
                  ],
                ),
              ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: const Text("Cargando..."),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}

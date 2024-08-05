import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tecnyapp_flutter/components/user/viewLocation/tecnichal_card.dart';
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/screen/userScreen/payments.dart';
import 'package:tecnyapp_flutter/service/auth/user_data_service.dart';
import 'package:tecnyapp_flutter/widgets/drawer/my_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ViewLocationScreen extends StatefulWidget {
  const ViewLocationScreen({super.key});

  @override
  ViewLocationScreenState createState() => ViewLocationScreenState();
}

class ViewLocationScreenState extends State<ViewLocationScreen> {
  late GoogleMapController _mapController;
  late LatLng tenyLocation = const LatLng(0, 0);
  late LatLng serviceLocation = const LatLng(0, 0);
  StreamController<LatLng> locationStreamController =
      StreamController<LatLng>();

  bool pay = false;

  late Map<String, dynamic> userData = {};
  late Map<String, dynamic> proposal = {};
  final socket = IO.io('https://serviciosmap-backend-production.up.railway.app',
      IO.OptionBuilder().setTransports(['websocket']).enableForceNew().build());
  Stream<LatLng> get locationStream => locationStreamController.stream;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    locationStreamController.close();
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  void initializeSocket() {
    socket.onConnect((_) {
      socket.emit('registerClient', userData['id']);
    });

    socket.on('newLocation', (data) {
      double latitude = double.parse(data['latitude']);
      double longitude = double.parse(data['longitude']);
      if (mounted) {
        setState(() {
          locationStreamController.add(LatLng(latitude, longitude));
        });
      }
    });

    socket.on('newPay', (data) {
      getProposal();
    });

    socket.onDisconnect((_) {});
  }

  Future<void> _loadUserData() async {
    final userJsonString = await UserDataService.getUserData();
    if (userJsonString != null) {
      if (mounted) {
        setState(() {
          userData = jsonDecode(userJsonString);
          initializeSocket();
          getProposal();
        });
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _goToCurrentLocation() {
    _mapController
        .animateCamera(CameraUpdate.newLatLngZoom(tenyLocation, 20.0));
  }

  Future<void> getProposal() async {
    if (userData.isNotEmpty) {
      final url = Uri.parse(
          '${Config.apiUrl}/proposal/sharing-location/true/client/${userData['id']}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            proposal = responseData['proposal'];
          });
          if (proposal.isNotEmpty) {
            String coordinatesString =
                proposal['service_request']['coordinates'];
            List<String> coordinates = coordinatesString.split(',');
            double latitude = double.tryParse(coordinates[0]) ?? 0.0;
            double longitude = double.tryParse(coordinates[1]) ?? 0.0;
            setState(() {
              serviceLocation = LatLng(latitude, longitude);
            });
          }
          if (proposal['service_request']['statusPay'] == 'esperando pago') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Payments()),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = proposal['user']?['profile_photo'] != null
        ? '${Config.imgUrl}/image/${proposal['user']['profile_photo']}'
        : 'https://img.freepik.com/vector-premium/ilustracion-avatar-estudiante-icono-perfil-usuario-avatar-jovenes_118339-4402.jpg';

    if (proposal.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: const Text(
            "Mi Mapa",
            style: TextStyle(fontSize: 20),
          ),
        ),
        drawer: const MyDrawer(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Column(
          children: [
            TecnichalCard(
              imageUrl: imageUrl,
              proposal: proposal,
              userData: userData,
            ),
            Expanded(
              child: Stack(
                children: [
                  StreamBuilder<LatLng>(
                    stream: locationStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        tenyLocation = snapshot.data!;
                        _mapController.animateCamera(
                          CameraUpdate.newLatLng(tenyLocation),
                        );
                      }

                      return GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: tenyLocation,
                          zoom: 20.0,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('Tecnico'),
                            position: tenyLocation,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueAzure,
                            ),
                          ),
                          Marker(
                            markerId: const MarkerId('Cliente'),
                            position: serviceLocation,
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
                      foregroundColor: Colors.red,
                      elevation: 4.0,
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(proposal['service_request']?['address'] ?? 'ss'),
            const SizedBox(height: 10),
            const Text(
              'El tecnico esta en camino .....',
              style: TextStyle(
                  color: Color.fromARGB(234, 223, 193, 10), fontSize: 16),
            ),
            const SizedBox(height: 10),
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

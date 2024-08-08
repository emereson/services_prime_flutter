import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:tecnyapp_flutter/components/user/proposalsList/proposal_functions.dart';
import 'package:tecnyapp_flutter/components/user/proposalsList/proposals_list.dart';
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/screen/userScreen/view_location_screen.dart';
import 'package:tecnyapp_flutter/service/auth/user_data_service.dart';
import 'package:tecnyapp_flutter/service/location/location_service.dart';
import 'package:tecnyapp_flutter/widgets/drawer/my_drawer.dart';
import 'package:tecnyapp_flutter/widgets/map/my_location_map.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ProposalsScreen extends StatefulWidget {
  const ProposalsScreen({super.key});

  @override
  State<ProposalsScreen> createState() => _ProposalsScreenState();
}

class _ProposalsScreenState extends State<ProposalsScreen> {
  late Map<String, dynamic> userData = {};
  late Map<String, dynamic> serviceRequest = {};

  LatLng _myLocation = const LatLng(0, 0);
  bool isLocationRetrieved = false;
  bool _viewScreen = false;
  bool isLoading = false;
  final socket = IO.io('https://serviciosmap-backend-production.up.railway.app',
      IO.OptionBuilder().setTransports(['websocket']).enableForceNew().build());

  @override
  void initState() {
    super.initState();
    _loadUserData();
    LocationService().checkLocationPermission((LatLng? latLng) {
      if (latLng != null && mounted) {
        setState(() {
          _myLocation = latLng;
          isLocationRetrieved = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initializeSocket() {
    socket.onConnect((_) {
      socket.emit('registerClient', userData['id']);
    });
  }

  Future<void> _loadUserData() async {
    final userJsonString = await UserDataService.getUserData();
    if (userJsonString != null && mounted) {
      setState(() {
        userData = jsonDecode(userJsonString);
        validSharingLocation();
        validExistService();
      });
      initializeSocket();
    }
  }

  Future<void> validExistService() async {
    final url =
        Uri.parse('${Config.apiUrl}/service-request/user/${userData['id']}');
    final response = await http.get(url);

    if (response.statusCode == 200 && mounted) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        serviceRequest = jsonResponse['serviceRequest'];
      });
    }
  }

  Future<void> validSharingLocation() async {
    final url = Uri.parse(
        '${Config.apiUrl}/proposal/sharing-location/true/client/${userData['id']}');
    final response = await http.get(url);

    if (response.statusCode == 200 && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ViewLocationScreen()),
      );
    } else if (mounted) {
      setState(() {
        _viewScreen = true;
      });
    }
  }

  void showPopUp(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar propuesta'),
          content:
              const Text('¿Está seguro que quiere eliminar este servicio?'),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white, // Color del texto
                      backgroundColor: Colors.red, // Color de fondo
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 30), // Espacio entre los botones
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white, // Color del texto
                      backgroundColor: Colors.green, // Color de fondo
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Proposalfunctions.cancelService(
                          serviceRequest, socket, context);
                    },
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_viewScreen) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: const Text(
            "Tus Propuestas",
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
                          child: MyLocationMap(
                            initialPosition: _myLocation,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                    ProposalsList(
                        userData: userData,
                        serviceRequest: serviceRequest,
                        validSharingLocation: validSharingLocation,
                        socket: socket),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 100,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 20),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showPopUp(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 255, 42, 42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(
                            Icons.cancel_schedule_send_rounded,
                            size: 25,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Cancelar servicio',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
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

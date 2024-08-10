import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tecnyapp_flutter/components/tecnichal/sharingLocation/customer_card_proposal.dart';
import 'package:tecnyapp_flutter/components/tecnichal/sharingLocation/proforma.dart';
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/screen/technicalScreen/request_list_screen.dart';
import 'package:tecnyapp_flutter/screen/technicalScreen/start_of_repair.dart';
import 'package:tecnyapp_flutter/service/auth/user_data_service.dart';
import 'package:tecnyapp_flutter/service/location/location_service.dart';
import 'package:tecnyapp_flutter/service/waiting_for_payment.dart';
import 'package:tecnyapp_flutter/widgets/drawer/my_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SharingLocationScreen extends StatefulWidget {
  const SharingLocationScreen({
    super.key,
  });

  @override
  SharingLocationScreenState createState() => SharingLocationScreenState();
}

class SharingLocationScreenState extends State<SharingLocationScreen>
    with SingleTickerProviderStateMixin {
  late GoogleMapController _mapController;
  LatLng tenyLocation = const LatLng(0, 0);
  LatLng clientLocation = const LatLng(0, 0);
  bool isLoading = false;
  bool viewScreen = false;
  bool viewProforma = false;
  bool pay = false;
  Timer? _locationTimer;

  late Map<String, dynamic> userData = {};
  late Map<String, dynamic> proposal = {};
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  final socket = IO.io('https://serviciosmap-backend-production.up.railway.app',
      IO.OptionBuilder().setTransports(['websocket']).enableForceNew().build());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _loadUserData();
    if (pay != true) {
      _locationTimer =
          Timer.periodic(const Duration(milliseconds: 3000), (Timer timer) {
        sendLocation(tenyLocation);
      });
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();

    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  void initializeSocket() {
    socket.onConnect((_) {
      socket.emit('registerClient', userData['id']);
    });
    socket.on('newpayment', (data) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RequestListScreen()),
        );
      }
    });

    socket.onDisconnect((_) {});
  }

  Future<void> _loadUserData() async {
    final userJsonString = await UserDataService.getUserData();
    if (userJsonString != null) {
      setState(() {
        userData = jsonDecode(userJsonString);
      });
      getProposal();
      initializeSocket();
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _goToCurrentLocation() {
    _mapController
        .animateCamera(CameraUpdate.newLatLngZoom(tenyLocation, 17.0));
  }

  Future<void> getProposal() async {
    if (userData.isNotEmpty) {
      final url = Uri.parse(
          '${Config.apiUrl}/proposal/sharing-location/true/technical/${userData['id']}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (!mounted) return; // Verifica si el widget está montado
        setState(() {
          proposal = responseData['proposal'];
        });
        if (proposal.isNotEmpty) {
          String coordinatesString = proposal['service_request']['coordinates'];
          List<String> coordinates = coordinatesString.split(',');
          double latitude = double.tryParse(coordinates[0]) ?? 0.0;
          double longitude = double.tryParse(coordinates[1]) ?? 0.0;
          if (!mounted) return;
          setState(() {
            clientLocation = LatLng(latitude, longitude);
          });
        }
        validExistProformaProposalId();
        if (proposal['service_request']['statusPay'] == 'esperando pago') {
          onPayChanged(true);
        }
      }
    }
  }

  void sendLocation(LatLng location) async {
    if (proposal.isNotEmpty) {
      Map<String, dynamic> data = {
        'clientId': proposal['service_request']['user_id'],
        'location': {
          'latitude': location.latitude.toString(),
          'longitude': location.longitude.toString(),
        },
      };
      socket.emit('locationUpdate', data);
    }
  }

  Future<void> validExistProformaProposalId() async {
    if (proposal.isNotEmpty) {
      final url = Uri.parse('${Config.apiUrl}/proforma/exist-proforma')
          .replace(queryParameters: {
        'technical_id': userData['id'].toString(),
        'proposal_id': proposal['id'].toString(),
      });

      final response = await http.get(url);

      if (response.statusCode != 200) {
        setState(() {
          viewScreen = true;
        });
      }
    }
  }

  void toggleProforma() {
    setState(() {
      viewProforma = !viewProforma;
      if (viewProforma) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void onPayChanged(bool newValue) {
    setState(() {
      pay = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl =
        '${Config.imgUrl}/image/${proposal['service_request']?['service_img']}';

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
      body: viewScreen
          ? Stack(
              children: [
                Column(
                  children: [
                    CustomerCardProposal(
                      imageUrl: imageUrl,
                      proposal: proposal,
                      userData: userData,
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          StreamBuilder<LatLng>(
                            stream: LocationService().locationStream,
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
                                  zoom: 17.0,
                                ),
                                markers: {
                                  Marker(
                                    markerId: const MarkerId('currentLocation'),
                                    position: tenyLocation,
                                    icon: BitmapDescriptor.defaultMarkerWithHue(
                                      BitmapDescriptor.hueAzure,
                                    ),
                                  ),
                                  Marker(
                                    markerId: const MarkerId('Cliente'),
                                    position: clientLocation,
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
                              foregroundColor: Colors.red, // Color del icono
                              elevation: 4.0, // Elevación (sombra)
                              child: const Icon(Icons.my_location),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(proposal['service_request']?['address'] ?? 'ss'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: toggleProforma,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 30),
                        backgroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Proforma de Reparacion',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
                SlideTransition(
                  position: _offsetAnimation,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Proforma(
                          proposal: proposal,
                          onClose: toggleProforma,
                          socket: socket,
                          onPayChanged: onPayChanged),
                    ),
                  ),
                ),
                if (pay) const WaitingForPayment(),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

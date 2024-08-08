import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tecnyapp_flutter/components/tecnichal/requestList/proposal_sent_card.dart';
import 'dart:convert';
import 'package:tecnyapp_flutter/components/tecnichal/requestList/service_list_card.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/utils/local_notifications.dart';

class ServiceListPanel extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final LatLng myLocation;
  final IO.Socket socket;

  const ServiceListPanel({
    super.key,
    required this.userData,
    required this.myLocation,
    required this.socket,
  });

  @override
  ServiceListPanelState createState() => ServiceListPanelState();
}

class ServiceListPanelState extends State<ServiceListPanel>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> jsonListServices = [];
  List<Map<String, dynamic>> jsonListProposals = [];
  bool _isInForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getServices();
    getProposals();
    initializeSocket();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _isInForeground = state == AppLifecycleState.resumed;
    });
  }

  void initializeSocket() {
    widget.socket.on('proposalAccepted', (data) {
      if (!_isInForeground) {
        final localNotifications =
            Provider.of<LocalNotifications>(context, listen: false);

        localNotifications.showNotification(
          title: 'Alguien acepto tu propuesta de reparacion',
          body: '${data['name']} acepto tu propuesta',
        );
      }
      if (mounted) {
        getProposals();
        getServices();
      }
    });

    widget.socket.on('newServiceRequest', (data) {
      if (widget.userData?['list_services'].contains(data['type_service'])) {
        if (!_isInForeground) {
          final localNotifications =
              Provider.of<LocalNotifications>(context, listen: false);

          localNotifications.showNotification(
            title: 'Nueva solicitud de ${data['type_service']}',
            body: '${data['description']}, ${data['address']}',
          );
        }
      }
      if (mounted) {
        getProposals();
        getServices();
      }
    });

    widget.socket.on('cancelService', (data) {
      if (mounted) {
        getProposals();
        getServices();
      }
    });
  }

  void getServices() async {
    if (widget.userData != null) {
      final url = Uri.parse(
          '${Config.apiUrl}/service-request?userId=${widget.userData?['id']}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success') {
          if (mounted) {
            setState(() {
              jsonListServices = List<Map<String, dynamic>>.from(
                  jsonResponse['serviceRequests']);
            });
          }
        } else {
          throw Exception('Failed to load service requests');
        }
      }
    }
  }

  void getProposals() async {
    if (widget.userData != null) {
      final userId = widget.userData!['id'];
      final url = Uri.parse('${Config.apiUrl}/proposal?userId=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success') {
          if (mounted) {
            setState(() {
              jsonListProposals =
                  List<Map<String, dynamic>>.from(jsonResponse['proposals']);
            });
          }
        } else {
          throw Exception('Failed to load proposals');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(0, 0, 0, 0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ...jsonListProposals.map((proposal) {
              String imageUrl =
                  '${Config.imgUrl}/image/${proposal['service_request']['service_img']}';
              return ProposalSentCard(
                imageUrl: imageUrl,
                proposal: proposal,
                userData: widget.userData,
                socket: widget.socket,
              );
            }),
            ...jsonListServices.map((service) {
              String imageUrl =
                  '${Config.imgUrl}/image/${service['service_img']}';
              return ServiceListCard(
                imageUrl: imageUrl,
                service: service,
                userData: widget.userData,
                socket: widget.socket,
                getProposals: getProposals,
                getServices: getServices,
              );
            }),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

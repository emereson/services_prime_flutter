import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tecnyapp_flutter/components/user/proposalsList/proposals_list_card.dart';
import 'dart:convert';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/utils/local_notifications.dart';

class ProposalsList extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Map<String, dynamic> serviceRequest;
  final Function validSharingLocation;
  final IO.Socket socket;

  const ProposalsList(
      {super.key,
      required this.userData,
      required this.serviceRequest,
      required this.validSharingLocation,
      required this.socket});

  @override
  ProposalsListState createState() => ProposalsListState();
}

class ProposalsListState extends State<ProposalsList>
    with WidgetsBindingObserver {
  List<dynamic> proposals = [];

  bool _isInForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchServiceRequest();
    widget.socket.on('newProposal', (data) {
      fetchServiceRequest();
      if (!_isInForeground) {
        final localNotifications =
            Provider.of<LocalNotifications>(context, listen: false);

        localNotifications.showNotification(
          title: 'Propuesta nueva',
          body:
              'El tecnico ${data['name']} le envio una propuesta de s/.${data['cost_of_diagnosis']} ',
        );
      }
    });
    widget.socket.on('sharingLocation', (data) {
      widget.validSharingLocation();
    });
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

  Future<void> fetchServiceRequest() async {
    final userId = widget.userData!['id'];
    final url = Uri.parse('${Config.apiUrl}/service-request/user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      if (mounted) {
        final jsonResponse = jsonDecode(response.body);
        final serviceRequest = jsonResponse['serviceRequest'];
        if (serviceRequest != null) {
          setState(() {
            proposals = serviceRequest['proposals'] ?? [];
          });
        }
      }
    } else {
      // Manejar error de respuesta aquí
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...proposals.map((item) {
              if (item is! Map<String, dynamic>) {
                return const SizedBox.shrink();
              }

              final Map<String, dynamic> proposal = item;
              String imageUrl = proposal['user'] != null &&
                      proposal['user']['profile_photo'] != null
                  ? '${Config.imgUrl}/image/${proposal['user']['profile_photo']}'
                  : 'https://img.freepik.com/vector-premium/ilustracion-avatar-estudiante-icono-perfil-usuario-avatar-jovenes_118339-4402.jpg';

              return ProposalsListCard(
                imageUrl: imageUrl,
                proposal: proposal,
                userData: widget.userData ?? {},
                socket: widget.socket,
                serviceRequest: widget.serviceRequest,
                fetchServiceRequest: fetchServiceRequest,
              );
            }),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

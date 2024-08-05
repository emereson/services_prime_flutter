import 'package:flutter/material.dart';
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/screen/technicalScreen/sharing_location_screen.dart';
import 'package:tecnyapp_flutter/utils/app_sanck_bar.dart';
import 'package:http/http.dart' as http;
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ProposalSentCard extends StatefulWidget {
  final String imageUrl;
  final Map<String, dynamic> proposal;
  final Map<String, dynamic>? userData;
  final IO.Socket socket;

  const ProposalSentCard({
    super.key,
    required this.imageUrl,
    required this.proposal,
    required this.userData,
    required this.socket,
  });

  @override
  State<ProposalSentCard> createState() => _ProposalSentCardState();
}

class _ProposalSentCardState extends State<ProposalSentCard> {
  bool _isLoading = false;
  final baseUrl = Config.apiUrl;

  Future<void> sharingLocation(BuildContext context) async {
    final url = '$baseUrl/proposal/sharing-location/${widget.proposal['id']}';

    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      widget.socket.emit('sendSharingLocation', widget.proposal['client_id']);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const SharingLocationScreen()),
        );
      }
    } else {
      if (context.mounted) {
        AppSnackbar.showError(
            context, 'Hubo un problema al compartir la ubicación');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          border: Border.all(
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              height: MediaQuery.of(context).size.width * 0.25,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: MediaQuery.of(context).size.width * 0.25,
                    color: Colors.grey,
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.proposal['service_request']['user']?['name']),
                      Text(
                          'telf. ${widget.proposal['service_request']?['user']?['phone_number']}'),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    's',
                    // widget.proposal['type_proposal'],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.proposal['service_request']['address'] ??
                        'No Address',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.proposal['service_request']['description'] ??
                        'No Description',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.proposal['service_request']['status_request'],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        's/.${widget.proposal['cost_of_diagnosis']}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inverseSurface,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.proposal['time'] ?? 'No Description',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inverseSurface,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          await sharingLocation(
                              context); // Llama a compartir ubicación

                          setState(() {
                            _isLoading = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 15),
                          backgroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Empezar',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

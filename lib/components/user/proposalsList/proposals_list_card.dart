import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/utils/app_sanck_bar.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ProposalsListCard extends StatefulWidget {
  final String imageUrl;
  final Map<String, dynamic> proposal;
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? serviceRequest;
  final IO.Socket socket;
  final Function fetchServiceRequest;

  const ProposalsListCard(
      {super.key,
      required this.imageUrl,
      required this.proposal,
      required this.userData,
      required this.serviceRequest,
      required this.socket,
      required this.fetchServiceRequest});

  @override
  ProposalsListCardState createState() => ProposalsListCardState();
}

class ProposalsListCardState extends State<ProposalsListCard> {
  bool _isLoading = false;

  Future<void> acceptProposal(
    BuildContext context,
  ) async {
    final url = '${Config.apiUrl}/proposal/approved/${widget.proposal['id']}';

    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      if (context.mounted) {
        AppSnackbar.showError(context, 'propuesta aceptada');
      }
      _isLoading = false;
      widget.socket.emit('acceptProposal', {
        'id': widget.proposal['user_id'],
        'user': widget.userData,
      });
      widget.fetchServiceRequest();
    } else {
      if (context.mounted) {
        AppSnackbar.showError(context, 'Error al aceptar la propuesta');
      }
      _isLoading = false;
    }
  }

  void showPopUp(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar propuesta'),
          content: Text(
              '¿Está seguro que quiere aceptar la propuesta del técnico ${widget.proposal['user']['name']}?'),
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
                      setState(() {
                        _isLoading = false;
                      });
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
                      Navigator.of(context).pop();
                      acceptProposal(context);
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(180, 0, 0, 0),
          border: Border.all(
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Center(
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.proposal['user']['name'],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Calif: ${widget.proposal['user']['stars']} estrellas',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        's/.${widget.proposal['cost_of_diagnosis']}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${widget.proposal['time']}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                showPopUp(context);
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                    color: Colors.green,
                    width: 1,
                  ),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Aceptar',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/utils/app_sanck_bar.dart';
import 'package:http/http.dart' as http;
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ServiceListCard extends StatefulWidget {
  final String imageUrl;
  final Map<String, dynamic> service;
  final Map<String, dynamic>? userData;
  final IO.Socket socket;
  final Function getProposals;
  final Function getServices;

  const ServiceListCard({
    super.key,
    required this.imageUrl,
    required this.service,
    required this.userData,
    required this.socket,
    required this.getProposals,
    required this.getServices,
  });

  @override
  State<ServiceListCard> createState() => _ServiceListCardState();
}

class _ServiceListCardState extends State<ServiceListCard> {
  final TextEditingController costDiagnosisController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  bool _isLoading = false;
  final baseUrl = Config.apiUrl;

  Future<void> createProposal(
    BuildContext context,
    String costDiagnosisController,
    String timeController,
  ) async {
    final userId = widget.userData?['id'].toString() ?? 'unknown';
    if (costDiagnosisController.isEmpty || timeController.isEmpty) {
      AppSnackbar.showError(context, 'Por favor, completa todos los campos');
      return;
    }

    // Validar y convertir el tiempo ingresado a un formato coherente
    final formattedTime = timeController;

    final url = '$baseUrl/proposal/${widget.service['id']}';

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'cost_of_diagnosis': costDiagnosisController,
        'time': formattedTime,
        'userId': userId,
        'client_id': widget.service['user_id'].toString()
      }),
    );
    final data = {
      "id": widget.service['user']['id'],
      "user": {
        'name': widget.userData?['name'],
        'cost_of_diagnosis': costDiagnosisController,
        'time': formattedTime,
      }
    };
    if (response.statusCode == 200) {
      widget.socket.emit('sendProposal', data);

      if (context.mounted) {
        AppSnackbar.showSuccess(context, 'La propuesta se envió exitosamente');
        widget.getProposals();
        widget.getServices();
      }
    } else {
      if (context.mounted) {
        AppSnackbar.showError(context, 'Error al enviar la propuesta');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(205, 0, 0, 0),
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
              width: MediaQuery.of(context).size.width * 0.23,
              height: MediaQuery.of(context).size.width * 0.23,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.23,
                    height: MediaQuery.of(context).size.width * 0.23,
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
                      Text(
                        widget.service['user']['name'],
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'telf. ${widget.service['user']['phone_number']}',
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.service['type_service'],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.service['address'] ?? 'No Address',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.service['description'] ?? 'No Description',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.service['status_request'] ?? 'No Status',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: costDiagnosisController,
                          decoration: InputDecoration(
                            hintText: 'S/.',
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                          ),
                          style: const TextStyle(fontSize: 14),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: timeController,
                          decoration: InputDecoration(
                            hintText: 'Tiempo',
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                          ),
                          style: const TextStyle(fontSize: 14),
                          onChanged: (value) {
                            // Puedes validar el tiempo en tiempo real si es necesario
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          await createProposal(
                            context,
                            costDiagnosisController.text,
                            timeController.text,
                          );
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 15),
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
                                'Enviar',
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

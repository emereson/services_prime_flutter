import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importante para usar FilteringTextInputFormatter
import 'package:http/http.dart' as http;
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/screen/technicalScreen/start_of_repair.dart';
import 'package:tecnyapp_flutter/service/auth/user_data_service.dart';
import 'package:tecnyapp_flutter/utils/app_sanck_bar.dart';
import 'package:tecnyapp_flutter/widgets/custom_expansion_tile.dart';
import 'package:tecnyapp_flutter/widgets/label_top_textarea.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Proforma extends StatefulWidget {
  final Map<String, dynamic> proposal;
  final VoidCallback onClose;
  final IO.Socket socket;
  final ValueChanged<bool> onPayChanged;
  const Proforma({
    super.key,
    required this.proposal,
    required this.onClose,
    required this.socket,
    required this.onPayChanged, // Acepta el callback
  });

  @override
  State<Proforma> createState() => _ProformaState();
}

class _ProformaState extends State<Proforma> {
  final TextEditingController descriptionController = TextEditingController();
  final baseUrl = Config.apiUrl;

  late Map<String, dynamic> userData = {};
  late List<dynamic> allServices = [];
  bool _isLoading = true;
  Map<String, TextEditingController> controllers = {};
  Map<String, dynamic> formData = {};
  double total = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchData();
  }

  Future<void> _loadUserData() async {
    final userJsonString = await UserDataService.getUserData();
    if (userJsonString != null) {
      setState(() {
        userData = jsonDecode(userJsonString);
      });
    }
  }

  Future<void> fetchData() async {
    final url = Uri.parse(
        '$baseUrl/service?name=${widget.proposal['service_request']['type_service']}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['status'] == 'success') {
        setState(() {
          allServices = jsonResponse['services'];
          _isLoading = false;
        });
      }
    }
  }

  void _updateTotal(price, min, max) {
    total = 0;
    double? priceValue = double.tryParse(price);
    double? minValue = double.tryParse(min);
    double? maxValue = double.tryParse(max);

    if (priceValue == null ||
        minValue == null ||
        maxValue == null ||
        priceValue < minValue ||
        priceValue > maxValue) {
      AppSnackbar.showMin(context, 'El precio debe estar entre $min y $max.');
      return;
    } else {
      controllers.forEach((key, controller) {
        double value = double.tryParse(controller.text) ?? 0;
        total += value;
      });

      setState(() {});
    }
  }

  void _saveProforma() {
    createProforma(context, formData);
  }

  void createProforma(BuildContext context, Map<String, dynamic> data) async {
    if (total == 0) {
      if (context.mounted) {
        AppSnackbar.showError(context, 'Por favor ingresa un precio valido ');
      }
    } else {
      final url = Uri.parse('$baseUrl/proforma');
      final response = await http.post(
        url,
        body: json.encode({
          ...data,
          'technical_id': userData['id'],
          'client_id': widget.proposal['client_id'],
          'service_request_id': widget.proposal['service_request_id'],
          'proposal_id': widget.proposal['id'],
          'description': descriptionController.text,
          'total': total
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        widget.socket.emit('sendPay', widget.proposal['client_id']);
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StartOfRepair()),
          );
        }
      }
    }
  }

  void decline() async {
    final url = Uri.parse(
        '$baseUrl/service-request/status/${widget.proposal['service_request_id']}');
    final response = await http.patch(
      url,
      body: json.encode({
        'status_request': 'Diagnostico finalizado',
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      widget.socket.emit('sendPay', widget.proposal['client_id']);
      widget.onPayChanged(true);
    }
  }

  void showPopUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Guardar Proforma'),
          content: const Text('Esta seguro que quiere guardar la proforma'),
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
                      _saveProforma();
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
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onClose,
              ),
              const Text('Ver mapa', style: TextStyle(fontSize: 18)),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: allServices.map((service) {
                      return CustomExpansionTile(
                        marginHorizontal: 15,
                        title: service['service_name'],
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        textColor: const Color.fromARGB(255, 248, 248, 248),
                        children: (service['service_categories'] as List)
                            .map<Widget>((category) {
                          return CustomExpansionTile(
                            marginHorizontal: 0,
                            title: category['category_name'],
                            backgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            textColor: const Color.fromARGB(255, 248, 248, 248),
                            children: (category['category_products'] as List)
                                .map<Widget>((product) {
                              return CustomExpansionTile(
                                marginHorizontal: 0,
                                title: product['product_name'],
                                backgroundColor:
                                    Theme.of(context).colorScheme.tertiary,
                                textColor:
                                    const Color.fromARGB(255, 248, 248, 248),
                                children: (product['product_systems'] as List)
                                    .map<Widget>((system) {
                                  return CustomExpansionTile(
                                    marginHorizontal: 0,
                                    title: system['system_name'],
                                    backgroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    textColor: const Color.fromARGB(
                                        255, 248, 248, 248),
                                    children: (system['system_options'] as List)
                                        .map<Widget>((systemOption) {
                                      String systemOptionKey =
                                          '${system['id']}-${systemOption['id']}';
                                      if (!controllers
                                          .containsKey(systemOptionKey)) {
                                        controllers[systemOptionKey] =
                                            TextEditingController();
                                      }

                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                          border: Border.all(
                                            width: 1,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(systemOption['option_name']),
                                            TextField(
                                              controller:
                                                  controllers[systemOptionKey],
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                  decimal: true),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(
                                                        r'[0-9]+(\.[0-9]*)?')),
                                              ],
                                              decoration: InputDecoration(
                                                labelText:
                                                    '${systemOption['minimum_range']} - ${systemOption['maximum_range']}',
                                              ),
                                              onChanged: (_) {
                                                setState(() {
                                                  // Actualizar el estado formData
                                                  formData = {
                                                    'type_service':
                                                        service['service_name'],
                                                    'category': category[
                                                        'category_name'],
                                                    'products':
                                                        product['product_name'],
                                                    'systems': product[
                                                            'product_systems']
                                                        .map((system) {
                                                      return {
                                                        'system': system[
                                                            'system_name'],
                                                        'systemOptionPrices':
                                                            system['system_options']
                                                                .map((opt) {
                                                          return {
                                                            'option_name': opt[
                                                                'option_name'],
                                                            'price': double.tryParse(
                                                                    controllers['${system['id']}-${opt['id']}']
                                                                            ?.text ??
                                                                        '') ??
                                                                0,
                                                          };
                                                        }).toList(),
                                                      };
                                                    }).toList(),
                                                  };
                                                });
                                                _updateTotal(
                                                    controllers[systemOptionKey]
                                                        ?.text,
                                                    systemOption[
                                                        'minimum_range'],
                                                    systemOption[
                                                        'maximum_range']);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  );
                                }).toList(),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LabelTopTextarea(
                  controller: descriptionController,
                  label: 'Descripción',
                  icon: Icons.description,
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: $total',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 8),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: decline,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 15),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'RECHAZAR',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          showPopUp();
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
                        child: const Text(
                          'ACEPTAR',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ])
              ],
            ),
          ),
        ],
      ),
    );
  }
}

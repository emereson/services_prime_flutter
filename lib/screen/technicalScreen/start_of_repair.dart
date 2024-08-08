import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:tecnyapp_flutter/components/tecnichal/StartOfRepair/expansion_tile_img.dart';
import 'package:tecnyapp_flutter/components/tecnichal/StartOfRepair/functions_star_or_repair.dart';
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/screen/technicalScreen/request_list_screen.dart';
import 'package:tecnyapp_flutter/service/auth/user_data_service.dart';
import 'package:tecnyapp_flutter/service/waiting_for_payment.dart';
import 'package:tecnyapp_flutter/widgets/drawer/my_drawer.dart';
import 'package:tecnyapp_flutter/widgets/my_button.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class StartOfRepair extends StatefulWidget {
  const StartOfRepair({super.key});

  @override
  State<StartOfRepair> createState() => _StartOfRepairState();
}

class _StartOfRepairState extends State<StartOfRepair> {
  Map<String, dynamic> userData = {};
  Map<String, dynamic> proposal = {};
  Map<String, dynamic> proforma = {};

  bool viewScreen = false;
  bool isLoading = false;
  bool pay = false;

  // Image lists for each section
  List<dynamic> panoramicaImages = [null, null, null];
  List<dynamic> modeloImages = [null, null, null];
  List<dynamic> averiasImages = [null, null, null];
  List<dynamic> materialesImages = [null, null, null];
  List<dynamic> instalationImages = [null, null, null];

  final socket = IO.io('https://serviciosmap-backend-production.up.railway.app',
      IO.OptionBuilder().setTransports(['websocket']).enableForceNew().build());

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
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
      initializeSocket();
      getProposal();
    }
  }

  Future<void> getProposal() async {
    if (userData.isNotEmpty) {
      final url = Uri.parse(
          '${Config.apiUrl}/proposal/sharing-location/true/technical/${userData['id']}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          proposal = responseData['proposal'];
        });
        validExistProformaProposalId();
        if (proposal['service_request']['repairs'][0] != null) {
          print('${responseData['proposal']['service_request']['repairs'][0]}');
          panoramicaImages = [
            proposal['service_request']['repairs'][0]['panorama_img_1'],
            proposal['service_request']['repairs'][0]['panorama_img_2'],
            proposal['service_request']['repairs'][0]['panorama_img_3']
          ];
          modeloImages = [
            proposal['service_request']['repairs'][0]['model_img_1'],
            proposal['service_request']['repairs'][0]['model_img_2'],
            proposal['service_request']['repairs'][0]['model_img_3']
          ];
          averiasImages = [
            proposal['service_request']['repairs'][0]['breakdowns_img_1'],
            proposal['service_request']['repairs'][0]['breakdowns_img_2'],
            proposal['service_request']['repairs'][0]['breakdowns_img_3']
          ];
          materialesImages = [
            proposal['service_request']['repairs'][0]['materials_img_1'],
            proposal['service_request']['repairs'][0]['materials_img_2'],
            proposal['service_request']['repairs'][0]['materials_img_3']
          ];
          instalationImages = [
            proposal['service_request']['repairs'][0]['facility_img_1'],
            proposal['service_request']['repairs'][0]['facility_img_2'],
            proposal['service_request']['repairs'][0]['facility_img_3']
          ];
        }
      }
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

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          proforma = responseData['proforma'];
          viewScreen = true;
        });
      }
    }
  }

  Future<void> pickImage(int index, List<dynamic> images, String sectionName,
      ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        // Verifica el tipo antes de asignar
        final file = File(pickedFile.path);
        images[index] = file;
      });
    }
  }

  void showPickerDialog(BuildContext context, int index, List<dynamic> images,
      String sectionName) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  pickImage(index, images, sectionName, ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () {
                  pickImage(index, images, sectionName, ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void onPayChanged(bool newValue) {
    setState(() {
      pay = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text(
          "Inicio de reparación",
          style: TextStyle(fontSize: 20),
        ),
      ),
      drawer: const MyDrawer(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: viewScreen
          ? Container(
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(15),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Servicio: ${proforma['type_service']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ExpansionTile(
                            title: const Text(
                              'Foto de inicio',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            collapsedBackgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            backgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            children: [
                              ExpansionTileImg(
                                title: 'Panorámica',
                                images: panoramicaImages,
                                pickImage: (index) {
                                  showPickerDialog(context, index,
                                      panoramicaImages, 'Panorámica');
                                },
                              ),
                              ExpansionTileImg(
                                title: 'Modelo',
                                images: modeloImages,
                                pickImage: (index) {
                                  showPickerDialog(
                                      context, index, modeloImages, 'Modelo');
                                },
                              ),
                              ExpansionTileImg(
                                title: 'Averías',
                                images: averiasImages,
                                pickImage: (index) {
                                  showPickerDialog(
                                      context, index, averiasImages, 'Averías');
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ExpansionTile(
                            title: const Text(
                              'Foto de proceso',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            collapsedBackgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            backgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            children: [
                              ExpansionTileImg(
                                title: 'Materiales',
                                images: materialesImages,
                                pickImage: (index) {
                                  showPickerDialog(context, index,
                                      materialesImages, 'Materiales');
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ExpansionTile(
                            title: const Text(
                              'Fotos finales',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            collapsedBackgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            backgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            children: [
                              ExpansionTileImg(
                                title: 'Instalación',
                                images: instalationImages,
                                pickImage: (index) {
                                  showPickerDialog(context, index,
                                      instalationImages, 'Instalación');
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyButton(
                            colorButton:
                                Theme.of(context).colorScheme.onPrimary,
                            text: "Guardar",
                            onTap: () async {
                              if (proposal['service_request']['repairs'][0] !=
                                  null) {
                                await FunctionsStarOrRepair.updateRepair(
                                    context,
                                    proposal['service_request']?['repairs']?[0]
                                        ?['id'],
                                    panoramicaImages,
                                    modeloImages,
                                    averiasImages,
                                    materialesImages,
                                    instalationImages,
                                    onPayChanged);
                              } else {
                                await FunctionsStarOrRepair.createRepair(
                                    context,
                                    userData,
                                    proposal,
                                    proforma,
                                    panoramicaImages,
                                    modeloImages,
                                    averiasImages,
                                    materialesImages,
                                    instalationImages,
                                    onPayChanged);
                              }
                            },
                          ),
                          const SizedBox(width: 10),
                          MyButton(
                            colorButton:
                                Theme.of(context).colorScheme.onPrimary,
                            text: "Finalizar",
                            onTap: () async {
                              setState(() {
                                isLoading = true;
                              });

                              await FunctionsStarOrRepair.finalizerRepair(
                                  context,
                                  proposal,
                                  socket,
                                  proposal['service_request']?['repairs']?[0]
                                      ?['id'],
                                  panoramicaImages,
                                  modeloImages,
                                  averiasImages,
                                  materialesImages,
                                  instalationImages,
                                  onPayChanged);

                              setState(() {
                                isLoading = false;
                              });
                            },
                          ),
                        ],
                      )),
                  if (pay) const WaitingForPayment(),
                  if (proposal['service_request']['statusPay'] ==
                      'esperando pago')
                    const WaitingForPayment(),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

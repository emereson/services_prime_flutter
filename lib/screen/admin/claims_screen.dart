import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/service/auth/auth_service.dart';
import 'package:tecnyapp_flutter/service/auth/user_data_service.dart';
import 'package:tecnyapp_flutter/utils/app_sanck_bar.dart';
import 'package:tecnyapp_flutter/widgets/drawer/my_drawer.dart';
import 'package:tecnyapp_flutter/widgets/label_top.dart';
import 'package:tecnyapp_flutter/widgets/label_top_textarea.dart';
import 'package:tecnyapp_flutter/widgets/my_button.dart';
import 'package:http/http.dart' as http;

class ClaimsScreen extends StatefulWidget {
  const ClaimsScreen({super.key});

  @override
  State<ClaimsScreen> createState() => _ClaimsScreenState();
}

class _ClaimsScreenState extends State<ClaimsScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<dynamic> currentServices = [];
  Map<String, dynamic> userData = {};
  File? document;

  String? _token;
  int idClaim = 0;
  int? idTechnical;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final jsonString = await UserDataService.getUserData();
    final token = await AuthService.getToken();
    if (jsonString != null) {
      setState(() {
        userData = jsonDecode(jsonString);
        _token = token;
      });
      getClients();
    }
  }

  Future<void> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        document = File(result.files.single.path!);
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        Navigator.of(context).pop();

        updatePopUp();
      });
    }
  }

  void getClients() async {
    final url = Uri.parse(
        '${Config.apiUrl}/user/services?name=${nameController.text}&dni=${dniController.text}');
    final response =
        await http.get(url, headers: {'Authorization': 'Bearer $_token'});

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        currentServices = jsonResponse['serviceRequests'];
      });
    }
  }

  Future<void> updateClaim() async {
    if (document == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una imagen primero'),
        ),
      );
      return;
    }

    final url = Uri.parse('${Config.apiUrl}/claim/$idClaim');
    var request = http.MultipartRequest('PATCH', url);

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $_token',
    });
    request.fields['detail2'] = descriptionController.text;

    request.files.add(await http.MultipartFile.fromPath(
      'document',
      document!.path,
    ));

    var response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      setState(() {
        descriptionController.text = '';
        document = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('la factura se guardo correctamente'),
          ),
        );
      }
      getClients();
    }
  }

  void createClaim(int id) async {
    final url = Uri.parse('${Config.apiUrl}/claim/$id');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $_token', // Agregar token si es necesario
      },
      body: jsonEncode(<String, dynamic>{
        'detail1': descriptionController.text,
        'technical_id': idTechnical // Accediendo al texto del controlador
      }),
    );

    if (response.statusCode == 200) {
      getClients();

      if (mounted) {
        AppSnackbar.showSuccess(context, 'El reclamo se creo exitosamente');
      }
      setState(() {
        descriptionController.text = '';
      });
    }
  }

  void showPopUp(BuildContext context, Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Crear reclamo'),
          actions: [
            Column(children: [
              LabelTopTextarea(
                  controller: descriptionController,
                  label: 'Escribe detalle del reclamo'),
              const SizedBox(height: 30),
              Row(
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
                        descriptionController.text = '';
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
                      createClaim(service['id']);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
            ]),
          ],
        );
      },
    );
  }

  void updatePopUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Finalizar reclamo'),
          actions: [
            Column(children: [
              LabelTopTextarea(
                  controller: descriptionController,
                  label: 'Escribe detalle del reclamo'),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: pickDocument,
                child: document != null
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadiusDirectional.circular(8),

                          border: Border.all(
                            width: 1,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ), // Corregido: Border.all
                        ),
                        child: const Text(
                          'El documento se subio correctamente',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,

                          borderRadius: BorderRadiusDirectional.circular(8),

                          border: Border.all(
                            width: 1,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ), // Corregido: Border.all
                        ),
                        child: Column(
                          children: [
                            const Text('Cargar cv del técnico'),
                            const SizedBox(height: 20),
                            Icon(
                              Icons.edit_document,
                              size: 50,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              '''Cargar el cv  del técnico Haga clic para cargar, Formato Soportado, .pdf, .doc''',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 30),
              Row(
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
                        descriptionController.text = '';
                        document = null;
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
                      updateClaim();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
            ]),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text(
          "Reclamos",
          style: TextStyle(fontSize: 20),
        ),
      ),
      drawer: const MyDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              LabelTop(
                controller: nameController,
                label: 'Nombre',
                icon: Icons.person_4,
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: LabelTop(
                      controller: dniController,
                      label: 'Dni',
                      icon: Icons.document_scanner_sharp,
                    ),
                  ),
                  const SizedBox(width: 10),
                  MyButton(
                    text: "Buscar",
                    colorButton: Theme.of(context).colorScheme.onPrimary,
                    onTap: () {}, // Llamada correcta al método
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...currentServices.map<Widget>((service) {
                return Container(
                  key: Key(service['id'].toString()),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          border: Border.all(
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                              height: MediaQuery.of(context).size.width * 0.2,
                              child: Image.network(
                                '${Config.imgUrl}/image/${service['service_img']}',
                                fit: BoxFit.fill,
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: MediaQuery.of(context).size.width * 0.2,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    height:
                                        MediaQuery.of(context).size.width * 0.2,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    service['type_service'],
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'cliente: ${service['user']['name']}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    ' ${service['description']}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'tec: ${service['proposals'][0]?['user']['name']}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ' ${service['claims'].isEmpty ? 'Sin Reclamos' : service['claims'][0]?['document'] != null ? 'Reclamo finalizado' : 'Pendiente de reclamo'}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                const SizedBox(height: 40),
                                if (service['claims'].isEmpty)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        idTechnical = service['proposals'][0]
                                            ?['user']['id'];
                                      });
                                      showPopUp(context, service);
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                    ),
                                    child: const Text(
                                      'Crear Reclamo',
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 216, 216, 216),
                                      ),
                                    ),
                                  )
                                else if (service['claims'][0]?['document'] !=
                                    null)
                                  const Text(
                                    'Ya cuenta  con un reclamo',
                                    style: TextStyle(
                                      color: Color.fromRGBO(231, 231, 231, 1),
                                      fontSize: 9,
                                    ),
                                  )
                                else
                                  TextButton(
                                    onPressed: () {
                                      updatePopUp();
                                      setState(() {
                                        idClaim = service['claims'][0]?['id'];
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 0, 77, 165),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                    ),
                                    child: const Text(
                                      'Finalizar Reclamo',
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 216, 216, 216),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

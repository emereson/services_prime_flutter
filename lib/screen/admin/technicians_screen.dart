import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/screen/admin/add_technical_screen.dart';
import 'package:tecnyapp_flutter/service/auth/auth_service.dart';
import 'package:tecnyapp_flutter/service/auth/user_data_service.dart';
import 'package:tecnyapp_flutter/utils/app_sanck_bar.dart';
import 'package:tecnyapp_flutter/widgets/drawer/my_drawer.dart';
import 'package:tecnyapp_flutter/widgets/label_top.dart';
import 'package:tecnyapp_flutter/widgets/label_top_select.dart';
import 'package:http/http.dart' as http;
import 'package:tecnyapp_flutter/widgets/my_button.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:url_launcher/url_launcher.dart';

class TechniciansScreen extends StatefulWidget {
  const TechniciansScreen({super.key});

  @override
  State<TechniciansScreen> createState() => TechniciansScreenState();
}

class TechniciansScreenState extends State<TechniciansScreen> {
  final TextEditingController nameController = TextEditingController();
  String? _token;
  String? selectedOption;
  List<dynamic> allServices = [];
  List<dynamic> usersOnline = [];

  List<dynamic> technicians = [];
  late Map<String, dynamic> userData;
  bool existTechnical = false;
  bool cv = false;

  final socket = IO.io('https://serviciosmap-backend-production.up.railway.app',
      IO.OptionBuilder().setTransports(['websocket']).enableForceNew().build());

  @override
  void initState() {
    super.initState();
    loadUserData();
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
    socket.on('technicalLocation', (data) {
      if (mounted) {
        setState(() {
          usersOnline = data;
        });
      }
    });
  }

  Future<void> loadUserData() async {
    final jsonString = await UserDataService.getUserData();
    final token = await AuthService.getToken();
    if (jsonString != null) {
      setState(() {
        userData = jsonDecode(jsonString);
        _token = token;
      });

      getService();
      initializeSocket();
    }
  }

  Future<void> getService() async {
    final url = Uri.parse('${Config.apiUrl}/service');
    final response = await http.get(
      url,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['status'] == 'success') {
        if (mounted) {
          setState(() {
            allServices = jsonResponse['services'];
          });
        }
      }
    }
  }

  void getTechnicians() async {
    final url = Uri.parse(
        '${Config.apiUrl}/user/technicians?name=${nameController.text}&typeService=${selectedOption.toString()}');
    final response =
        await http.get(url, headers: {'Authorization': 'Bearer $_token'});

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (mounted) {
        setState(() {
          technicians = jsonResponse['users']; // Ajuste correcto
        });
      }
    }
  }

  Future<void> deleteTechnical(BuildContext context, technical) async {
    final url = Uri.parse('${Config.apiUrl}/user/${technical?['id']}');

    final response =
        await http.delete(url, headers: {'Authorization': 'Bearer $_token'});

    if (response.statusCode == 200) {
      if (context.mounted) {
        AppSnackbar.showError(context, 'Usuario eliminado');
      }
      getTechnicians();
    } else {
      if (context.mounted) {
        AppSnackbar.showError(
            context, 'Error al eliminar el usuario ${response.body}');
      }
    }
  }

  void showPopUp(BuildContext context, Map<String, dynamic> technical) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Tecnico'),
          content: Text(
              'Esta seguro que quiere eliminar al tecnico ${technical['name']}'),
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
                      deleteTechnical(context, technical);
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text(
          "Ver técnicos",
          style: TextStyle(fontSize: 20),
        ),
      ),
      drawer: const MyDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              LabelTopSelect(
                label: 'Elegir Servicio',
                options: allServices
                    .map((service) => service['service_name'] as String)
                    .toList(),
                selectedValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: LabelTop(
                      controller: nameController,
                      label: 'Nombre',
                      icon: Icons.person_4,
                    ),
                  ),
                  const SizedBox(width: 10),
                  MyButton(
                    text: "Buscar",
                    colorButton: Theme.of(context).colorScheme.onPrimary,

                    onTap: getTechnicians, // Llamada correcta al método
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(
                      width: 10), // Espacio entre el TextField y el botón
                  MyButton(
                    colorButton: const Color.fromARGB(234, 48, 129, 173),
                    text: "Agregar tecnico",
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTechnicalScreen(
                            technical: const {},
                            existTechnical: existTechnical,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...technicians.map<Widget>((technical) {
                return Container(
                  key: Key(technical['id'].toString()),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                              height: MediaQuery.of(context).size.width * 0.2,
                              child: Image.network(
                                '${Config.imgUrl}/image/${technical?['profile_photo']}',
                                fit: BoxFit.cover,
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    technical['name'],
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'cel: ${technical['phone_number']}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Calif: ${technical['stars']} estrellas',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 15,
                                      height: 15,
                                      decoration: BoxDecoration(
                                          color: usersOnline.any(
                                            (user) =>
                                                user['technical']['id']
                                                    .toString() ==
                                                technical['id'].toString(),
                                          )
                                              ? const Color.fromARGB(
                                                  255,
                                                  20,
                                                  239,
                                                  0) // Verde si está conectado
                                              : const Color.fromARGB(
                                                  255, 255, 1, 1),
                                          borderRadius: BorderRadius.circular(
                                              50) // Rojo si no está conectado
                                          ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      usersOnline.any(
                                        (user) =>
                                            user['technical']['id']
                                                .toString() ==
                                            technical['id'].toString(),
                                      )
                                          ? 'Conectado'
                                          : 'Desconectado',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                ElevatedButton(
                                  onPressed: () async {
                                    Uri documentUrl = Uri.parse(
                                        '${Config.imgUrl}/cv/${technical['cv']}');
                                    await launchUrl(
                                      documentUrl,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 7, horizontal: 15),
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .onPrimary, // Cambia el color según tu tema
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Descargar CV',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddTechnicalScreen(
                                              technical: technical,
                                              existTechnical: true,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 7, horizontal: 15),
                                        minimumSize: Size.zero,
                                        backgroundColor: const Color.fromARGB(
                                          234,
                                          48,
                                          129,
                                          173,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Icon(Icons.edit,
                                          size: 20,
                                          color: Color.fromARGB(
                                              255, 248, 248, 248)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        showPopUp(context, technical);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 7, horizontal: 15),
                                        minimumSize: Size.zero,
                                        backgroundColor: const Color.fromARGB(
                                            255, 255, 1, 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Icon(Icons.delete,
                                          size: 20,
                                          color: Color.fromARGB(
                                              255, 255, 255, 255)),
                                    ),
                                  ],
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

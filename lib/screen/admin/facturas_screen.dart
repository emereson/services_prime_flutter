import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/service/auth/auth_service.dart';
import 'package:tecnyapp_flutter/service/auth/user_data_service.dart';
import 'package:tecnyapp_flutter/widgets/drawer/my_drawer.dart';
import 'package:tecnyapp_flutter/widgets/label_top.dart';
import 'package:tecnyapp_flutter/widgets/my_button.dart';
import 'package:http/http.dart' as http;

class FacturasScreen extends StatefulWidget {
  const FacturasScreen({super.key});

  @override
  State<FacturasScreen> createState() => _FacturasScreenState();
}

class _FacturasScreenState extends State<FacturasScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  String? _token;
  Map<String, dynamic>? userData;
  File? image;
  bool isLoading = false;
  String? selectPay;

  List<dynamic> currentServices = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final jsonString = await UserDataService.getUserData();
    final token = await AuthService.getToken();
    if (jsonString != null && token != null) {
      setState(() {
        userData = jsonDecode(jsonString);
        _token = token;
      });
      getServices();
    }
  }

  void getServices() async {
    final url = Uri.parse(
        '${Config.apiUrl}/user/services?name=${nameController.text}&dni=${dniController.text}');
    final response =
        await http.get(url, headers: {'Authorization': 'Bearer $_token'});

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (mounted) {
        setState(() {
          currentServices = jsonResponse['serviceRequests']; // Ajuste correcto
        });
      }
    }
  }

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });

      // Espera un momento antes de abrir el diálogo para asegurar que el estado se actualice
      Future.delayed(const Duration(milliseconds: 100), () {
        Navigator.of(context).pop();

        showPopUp();
      });
    }
  }

  Future<void> _uploadImage() async {
    setState(() {
      isLoading = true;
    });
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una imagen primero'),
        ),
      );
      return;
    }

    final url = Uri.parse('${Config.apiUrl}/pay/$selectPay');
    var request = http.MultipartRequest('PATCH', url);

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $_token',
    });
    request.files.add(await http.MultipartFile.fromPath(
      'factura_img',
      image!.path,
    ));

    var response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('la factura se guardo correctamente'),
          ),
        );
      }
      getServices();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showPopUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cargar boleta / factura'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1,
                      ),
                    ),
                    child: image != null
                        ? Image.file(
                            image!,
                            width: 300,
                            fit: BoxFit.cover,
                          )
                        : const Column(
                            children: [
                              Text(
                                'Haga clic para cargar la factura, Formato Soportado .jpg, .png',
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              Icon(Icons.add),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      image = null;
                    });
                  },
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 30),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _uploadImage();
                    setState(() {
                      image = null;
                    });
                  },
                  child: const Text('Guardar'),
                ),
              ],
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
          "Cargar boleta a servicios finalizados",
          style: TextStyle(fontSize: 20),
        ),
      ),
      drawer: const MyDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    onTap: getServices, // Llamada correcta al método
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                              height: MediaQuery.of(context).size.width * 0.2,
                              child: Image.network(
                                '${Config.imgUrl}/image/${service?['service_img']}',
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
                                children: [
                                  Text(
                                    service['type_service'],
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inverseSurface,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'cliente: ${service['user']['name']}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inverseSurface,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    service['description'],
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    service['description'],
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            service['status_request'],
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            service['statusPay'],
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      Center(
                                          child: service['payments'][0]
                                                      ['factura_img'] ==
                                                  null
                                              ? GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      selectPay =
                                                          service['payments'][0]
                                                                  ['id']
                                                              .toString();
                                                    });
                                                    showPopUp();
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 15,
                                                        vertical: 10),
                                                    decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: const Text(
                                                      'Cargar',
                                                      style: TextStyle(
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                                )
                                              : GestureDetector(
                                                  onTap: () {},
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 15,
                                                        vertical: 10),
                                                    decoration: BoxDecoration(
                                                        color: const Color
                                                            .fromARGB(
                                                            234, 223, 193, 10),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: const Text(
                                                      'Enviada',
                                                      style: TextStyle(
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                                )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
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

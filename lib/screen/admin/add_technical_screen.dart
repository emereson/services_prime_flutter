import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/screen/admin/technicians_screen.dart';
import 'package:tecnyapp_flutter/service/auth/auth_service.dart';
import 'package:tecnyapp_flutter/utils/app_sanck_bar.dart';
import 'package:tecnyapp_flutter/widgets/drawer/my_drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:tecnyapp_flutter/widgets/label_top.dart';
import 'package:tecnyapp_flutter/widgets/my_button.dart';
import 'package:http/http.dart' as http;

class AddTechnicalScreen extends StatefulWidget {
  final Map<String, dynamic>? technical;
  final bool existTechnical;

  const AddTechnicalScreen(
      {super.key, required this.technical, required this.existTechnical});

  @override
  State<AddTechnicalScreen> createState() => _AddTechnicalScreenState();
}

class _AddTechnicalScreenState extends State<AddTechnicalScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  File? image;
  File? cv;
  bool viewImage = true;
  List<dynamic> selectServices = [];
  List<dynamic> allServices = [];
  String? _token;

  @override
  void initState() {
    super.initState();
    loadToken();
    fetchData();
    loadTechnical();
  }

  Future<void> loadTechnical() async {
    if (widget.existTechnical) {
      nameController.text = widget.technical?['name'] ?? 'eee';
      dniController.text = widget.technical?['dni'] ?? '';
      phoneNumberController.text = widget.technical?['phone_number'] ?? '';
      setState(() {
        selectServices = widget.technical?['list_services'];
      });
    }
  }

  Future<void> loadToken() async {
    final token = await AuthService.getToken();
    _token = token;
  }

  Future<void> fetchData() async {
    final url = Uri.parse('${Config.apiUrl}/service');
    final response = await http.get(url);

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

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  void showPickerDialog(BuildContext context) {
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
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickCv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        cv = File(result.files.single.path!);
      });
    }
  }

  Future<void> registerTechnician(BuildContext context) async {
    final name = nameController.text;
    final dni = dniController.text;
    final phoneNumber = phoneNumberController.text;
    final selectServicesType = selectServices;
    final profilePhoto = image;
    final cvSelect = cv;

    // Validación de campos
    if (widget.existTechnical) {
      if (name.isEmpty ||
          dni.isEmpty ||
          phoneNumber.isEmpty ||
          selectServicesType.isEmpty) {
        AppSnackbar.showError(context, 'Por favor, completa todos los campos');
        return;
      }
    } else {
      if (name.isEmpty ||
          dni.isEmpty ||
          phoneNumber.isEmpty ||
          selectServicesType.isEmpty ||
          profilePhoto == null ||
          cvSelect == null) {
        AppSnackbar.showError(context, 'Por favor, completa todos los campos');
        return;
      }
    }

    final url = widget.existTechnical
        ? Uri.parse('${Config.apiUrl}/user/${widget.technical?['id']}')
        : Uri.parse('${Config.apiUrl}/user/register/technician');

    final request =
        http.MultipartRequest(widget.existTechnical ? 'PATCH' : 'POST', url)
          ..headers.addAll({
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $_token',
          })
          ..fields['name'] = name
          ..fields['dni'] = dni
          ..fields['phone_number'] = phoneNumber
          ..fields['selectServices'] = jsonEncode(selectServicesType);

    if (profilePhoto != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'profile_photo', profilePhoto.path));
    }
    if (cvSelect != null) {
      request.files.add(await http.MultipartFile.fromPath('cv', cvSelect.path));
    }

    try {
      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 201) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TechniciansScreen()),
          );
        }
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(
            'Failed to create/update technician with status code: ${response.statusCode}, message: ${errorResponse['message']}');
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.showError(context, 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text(
          "Agregar o editar técnico",
          style: TextStyle(fontSize: 20),
        ),
      ),
      drawer: const MyDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              LabelTop(
                controller: nameController,
                label: 'Nombres y apellidos',
                icon: Icons.person_4,
              ),
              LabelTop(
                controller: dniController,
                label: 'DNI',
                icon: Icons.person_4,
              ),
              LabelTop(
                controller: phoneNumberController,
                label: 'Teléfono',
                icon: Icons.phone,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  MyButton(
                    colorButton: viewImage
                        ? const Color.fromARGB(234, 223, 193, 10)
                        : const Color.fromARGB(255, 66, 66, 66),
                    text: "Foto",
                    onTap: () async {
                      setState(() {
                        viewImage = true;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  MyButton(
                    colorButton: !viewImage
                        ? const Color.fromARGB(234, 223, 193, 10)
                        : const Color.fromARGB(255, 66, 66, 66),
                    text: "CV",
                    onTap: () async {
                      setState(() {
                        viewImage = false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              viewImage
                  ? GestureDetector(
                      onTap: () => showPickerDialog(context),
                      child: image != null || widget.existTechnical
                          ? Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary,
                                borderRadius:
                                    BorderRadiusDirectional.circular(8),

                                border: Border.all(
                                  width: 1,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                ), // Corregido: Border.all
                              ),
                              child: image == null
                                  ? Image.network(
                                      '${Config.imgUrl}/image/${widget.technical?['profile_photo']}',
                                      width: 150,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      image!,
                                      width: 150,
                                      fit: BoxFit.cover,
                                    ),
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary,
                                borderRadius:
                                    BorderRadiusDirectional.circular(8),

                                border: Border.all(
                                  width: 1,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                ), // Corregido: Border.all
                              ),
                              child: Column(
                                children: [
                                  const Text('Cargar foto del tecnico'),
                                  const SizedBox(height: 20),
                                  Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    '''Haga clic para cargar, Soportado .jpg, .png''',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                    )
                  : GestureDetector(
                      onTap: () async {
                        await _pickCv();
                      },
                      child: cv != null
                          ? Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary,
                                borderRadius:
                                    BorderRadiusDirectional.circular(8),

                                border: Border.all(
                                  width: 1,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                ), // Corregido: Border.all
                              ),
                              child: const Text(
                                'El cv del tecnico se subio correctamente',
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary,

                                borderRadius:
                                    BorderRadiusDirectional.circular(8),

                                border: Border.all(
                                  width: 1,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                ), // Corregido: Border.all
                              ),
                              child: Column(
                                children: [
                                  const Text('Cargar cv del técnico'),
                                  const SizedBox(height: 20),
                                  Icon(
                                    Icons.edit_document,
                                    size: 50,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
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
              const SizedBox(height: 40),
              Text(
                '¿Qué servicios brinda?',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              ...allServices.map<Widget>((service) {
                return GestureDetector(
                  key: Key(service['id'].toString()),
                  onTap: () {
                    setState(() {
                      if (selectServices.contains(service['service_name'])) {
                        selectServices.remove(service['service_name']);
                      } else {
                        selectServices.add(service['service_name']);
                      }
                    });
                  },
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: selectServices
                                      .contains(service['service_name'])
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            service['service_name'],
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inverseSurface,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyButton(
                    text: "CANCELAR",
                    colorButton: const Color.fromARGB(255, 243, 18, 18),
                    onTap: () {
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TechniciansScreen(),
                          ),
                        );
                      }
                    }, // Llamada correcta al método
                  ),
                  const SizedBox(width: 20),
                  MyButton(
                    text: "GUARDAR",
                    colorButton: Theme.of(context).colorScheme.onPrimary,
                    onTap: () {
                      registerTechnician(context);
                    }, // Llamada correcta al método
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

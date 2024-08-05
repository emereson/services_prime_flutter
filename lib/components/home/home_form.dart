import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/screen/userScreen/proposals_screen.dart';
import 'package:tecnyapp_flutter/service/location/location_service.dart';
import 'package:tecnyapp_flutter/utils/app_sanck_bar.dart';
import 'package:tecnyapp_flutter/widgets/label_top.dart';
import 'package:tecnyapp_flutter/widgets/label_top_select.dart';
import 'package:tecnyapp_flutter/widgets/label_top_textarea.dart';
import 'package:tecnyapp_flutter/widgets/map/map_dialog.dart';
import 'package:tecnyapp_flutter/widgets/my_button.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HomeForm extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final List<dynamic> allServices;
  final ValueChanged<bool> onPayChanged;

  const HomeForm({
    super.key,
    required this.userData,
    required this.allServices,
    required this.onPayChanged,
  });

  @override
  State<HomeForm> createState() => _HomeFormState();
}

class _HomeFormState extends State<HomeForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool _isLoading = false;
  LatLng _selectedLatLng = const LatLng(0, 0);
  bool isLocationRetrieved = false;
  String? selectedOption;
  File? _image;
  final baseUrl = Config.apiUrl;

  late Map<String, dynamic> userData;
  final socket = IO.io('https://serviciosmap-backend-production.up.railway.app',
      IO.OptionBuilder().setTransports(['websocket']).enableForceNew().build());

  @override
  void initState() {
    super.initState();
    userData = widget.userData ?? {};
    nameController.text = userData['name'] ?? '';
    dniController.text = userData['dni'] ?? '';
    socket.onConnect((_) {
      socket.emit('registerClient', widget.userData?['id']);
    });
    LocationService().checkLocationPermission((LatLng? latLng) {
      if (latLng != null) {
        if (mounted) {
          setState(() {
            _selectedLatLng = latLng;
            isLocationRetrieved = true;
            getAddressFromLatLng(latLng);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    if (socket.connected) {
      socket.emit('disconnectClient', {'id': widget.userData?['id']});
    }
    socket.disconnect();
    super.dispose();
  }

  Future<void> createServiceRequest(BuildContext context) async {
    final name = nameController.text;
    final dni = dniController.text;
    final address = addressController.text;
    final coordinates =
        "${_selectedLatLng.latitude},${_selectedLatLng.longitude}";
    final description = descriptionController.text;
    final image = _image;

    if (selectedOption == null ||
        name.isEmpty ||
        dni.isEmpty ||
        address.isEmpty ||
        coordinates.isEmpty ||
        description.isEmpty ||
        image == null) {
      AppSnackbar.showError(context, 'Por favor, completa todos los campos');
      return;
    }
    widget.onPayChanged(true);
    final url = Uri.parse('$baseUrl/service-request/${userData['id']}');
    var request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
    });

    // Añadir campos de texto
    request.fields['type_service'] = selectedOption!;
    request.fields['name'] = name;
    request.fields['dni'] = dni;
    request.fields['address'] = address;
    request.fields['coordinates'] = coordinates;
    request.fields['description'] = description;

    // Añadir archivo de imagen
    request.files.add(await http.MultipartFile.fromPath(
      'service_img',
      image.path,
    ));

    var response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      Map<String, dynamic> data = jsonResponse['serviceRequest'];
      if (socket.connected) {
        socket.emit('serviceRequest', data);
      }

      if (jsonResponse['status'] == 'success') {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProposalsScreen()),
          );
        }
      } else {
        throw Exception('Failed to create service: ${jsonResponse['message']}');
      }
    } else {
      final errorResponse = json.decode(response.body);
      throw Exception(
          'Failed to create service with status code: ${response.statusCode}, message: ${errorResponse['message']}');
    }
  }

  void _openMapDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MapDialog(
          initialPosition: _selectedLatLng,
          onLocationSelected: (LatLng latLng) {
            setState(() {
              _selectedLatLng = latLng;
              getAddressFromLatLng(latLng);
            });
          },
          onSave: () {
            getAddressFromLatLng(_selectedLatLng);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void getAddressFromLatLng(LatLng latLng) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      if (mounted) {
        setState(() {
          addressController.text =
              "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
        });
      }
    } else {
      setState(() {
        addressController.text = "";
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        LabelTopSelect(
          label: 'Elegir Servicio',
          options: widget.allServices
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
        LabelTop(
          controller: nameController,
          label: 'Nombre y Apellido',
          icon: Icons.person,
        ),
        const SizedBox(height: 10),
        LabelTop(
          controller: dniController,
          label: 'DNI',
          icon: Icons.document_scanner,
        ),
        const SizedBox(height: 20),
        LabelTop(
          controller: addressController,
          label: 'Dirección',
          icon: Icons.location_on,
        ),
        const SizedBox(height: 10),
        Center(
          child: MyButton(
            text: 'Ver Mapa',
            onTap: _openMapDialog,
            colorButton: Theme.of(context).colorScheme.onPrimary,
          ),
        ),

        const SizedBox(height: 20), // Espacio adicional entre los elementos
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Adjuntar foto del equipo a revisar',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (_image != null)
              SizedBox(
                width: 150,
                child: Image.file(_image!),
              ),
            const SizedBox(height: 10),
            IconButton(
              icon: const Icon(
                Icons.camera_alt,
                size: 60,
              ),
              onPressed: () => showPickerDialog(context),
            ),
          ],
        ),
        LabelTopTextarea(
          controller: descriptionController,
          label: 'Descripción',
          icon: Icons.description,
        ),
        const SizedBox(height: 30),
        _isLoading
            ? const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(),
                ),
              )
            : Center(
                child: MyButton(
                  colorButton: Theme.of(context).colorScheme.onPrimary,
                  text: "Guardar",
                  onTap: () async {
                    setState(() {
                      _isLoading = true;
                    });

                    await createServiceRequest(context);

                    setState(() {
                      _isLoading = false;
                    });
                  },
                ),
              ),
      ],
    );
  }
}

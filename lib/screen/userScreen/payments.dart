import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/screen/userScreen/home_screen.dart';
import 'package:tecnyapp_flutter/service/auth/auth_service.dart';
import 'package:tecnyapp_flutter/widgets/drawer/my_drawer.dart';
import 'package:tecnyapp_flutter/service/auth/user_data_service.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tecnyapp_flutter/widgets/my_button.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Payments extends StatefulWidget {
  const Payments({super.key});

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  String? _token;

  late Map<String, dynamic> userData = {};
  late Map<String, dynamic> proposal = {};
  String total = '0.0';
  File? _image;
  bool _isLoading = false;
  final socket = IO.io('https://serviciosmap-backend-production.up.railway.app',
      IO.OptionBuilder().setTransports(['websocket']).enableForceNew().build());

  bool _viewScreen = false;
  String typePay = 'Natural';

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

    socket.onDisconnect((_) {});
  }

  Future<void> _loadUserData() async {
    final userJsonString = await UserDataService.getUserData();
    if (userJsonString != null) {
      setState(() {
        userData = jsonDecode(userJsonString);
      });
      await getProposal();
      initializeSocket();
    }
    final token = await AuthService.getToken();
    _token = token;
  }

  Future<void> getProposal() async {
    if (userData.isNotEmpty) {
      final url = Uri.parse(
          '${Config.apiUrl}/proposal/sharing-location/true/client/${userData['id']}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            proposal = responseData['proposal'];
            total = proposal['proformas'].isNotEmpty
                ? proposal['proformas'][0]['total']
                : proposal['cost_of_diagnosis'];
          });
          _viewScreen = true;
        }
      }
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

  Future<void> createPay() async {
    setState(() {
      _isLoading = true;
    });
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una imagen primero'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('${Config.apiUrl}/pay');
    var request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $_token',
    });
    request.fields['technical_id'] = proposal['user_id'].toString();
    request.fields['client_id'] = userData['id'].toString();
    request.fields['service_request_id'] =
        proposal['service_request_id'].toString();
    request.fields['proposal_id'] = proposal['id'].toString();
    request.fields['type_pay'] = typePay;
    request.fields['total'] = total;

    request.files.add(await http.MultipartFile.fromPath(
      'pay_img',
      _image!.path,
    ));

    var response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
      });
      socket.emit('sendPayment', proposal['user_id']);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_viewScreen) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: const Text(
            "Pagos",
            style: TextStyle(fontSize: 20),
          ),
        ),
        drawer: const MyDrawer(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(
                16.0), // Ajusta el padding según lo necesites
            child: Column(
              children: [
                Text(
                  'Servicio: ${proposal['service_request']['type_service']}',
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 66, 66, 66),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border(
                      top: BorderSide(color: Colors.white, width: 1),
                      bottom: BorderSide(color: Colors.white, width: 1),
                      left: BorderSide(color: Colors.white, width: 1),
                      right: BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'N° de yape: 954 789 355',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          typePay = 'Natural';
                        });
                      },
                      child: Row(
                        children: [
                          const Text('Natural'),
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(left: 8.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: typePay == 'Natural'
                                    ? const Color.fromARGB(255, 17, 196, 236)
                                    : Theme.of(context).colorScheme.tertiary,
                                width: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 50),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          typePay = 'Jurídica';
                        });
                      },
                      child: Row(
                        children: [
                          const Text('Jurídica'),
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(left: 8.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: typePay == 'Jurídica'
                                    ? const Color.fromARGB(255, 17, 196, 236)
                                    : Theme.of(context).colorScheme.tertiary,
                                width: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  'TOTAL A PAGAR: S/. $total',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: GestureDetector(
                    onTap: () => showPickerDialog(context),
                    child: Center(
                      child: _image != null
                          ? Image.file(
                              _image!,
                              height: 300,
                              width: 150,
                              fit: BoxFit.cover,
                            )
                          : const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.upload,
                                  size: 40,
                                  color: Color.fromARGB(255, 240, 240, 240),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Cargar foto del voucher\n\nHaga clic para cargar o arrastre y suelte\nFormato Soportado: .jpg, .png',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color:
                                          Color.fromARGB(255, 247, 247, 247)),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : MyButton(
                          colorButton: Theme.of(context).colorScheme.onPrimary,
                          onTap: createPay,
                          text: 'Pagar',
                        ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: const Text("Cargando..."),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}

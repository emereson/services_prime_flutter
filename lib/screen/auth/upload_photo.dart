import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/screen/userScreen/home_screen.dart';
import 'package:tecnyapp_flutter/service/auth/auth_provider.dart';
import 'package:tecnyapp_flutter/service/auth/auth_service.dart';
import 'package:tecnyapp_flutter/service/auth/user_data_service.dart';
import 'package:tecnyapp_flutter/service/loading_page.dart';
import 'package:tecnyapp_flutter/widgets/my_button.dart';

class UploadPhoto extends StatefulWidget {
  const UploadPhoto({super.key});

  @override
  State<UploadPhoto> createState() => _UploadPhotoState();
}

class _UploadPhotoState extends State<UploadPhoto> {
  String? _token;
  File? _image;
  bool _isLoading = false;
  late Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userJsonString = await UserDataService.getUserData();
    if (userJsonString != null) {
      setState(() {
        userData = jsonDecode(userJsonString);
      });
    }
    final token = await AuthService.getToken();
    _token = token;
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

  void _showPickerDialog(BuildContext context) {
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

  Future<void> _uploadImage() async {
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);

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

    final url =
        Uri.parse('${Config.apiUrl}/user/upload-photo/${userData['id']}');
    var request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $_token',
    });
    request.files.add(await http.MultipartFile.fromPath(
      'profile_photo',
      _image!.path,
    ));

    var response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final String token = responseBody['token'];
      final Map<String, dynamic> userData = responseBody['user'];

      await authProvider.setToken(token);

      await UserDataService.saveUserData(jsonEncode(userData));
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  void _skipUpload() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text(
          'Subir Foto de Perfil',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              onPressed: _skipUpload,
              child: Text(
                'Omitir',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(15),
        child: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  FractionallySizedBox(
                    widthFactor: 0.6,
                    child: Text(
                      "Esto te ayudará a mejorar tu identificación",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () => _showPickerDialog(context),
                    child: _image != null
                        ? Image.file(
                            _image!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.add_a_photo,
                            size: 150,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showPickerDialog(context),
                    child: Text(
                      'Seleccionar Imagen',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  MyButton(
                    colorButton: Theme.of(context).colorScheme.onPrimary,
                    onTap: _uploadImage,
                    text: 'Subir Imagen',
                  ),
                ],
              ),
            ),
            if (_isLoading) const LoadingPage(),
          ],
        ),
      ),
    );
  }
}

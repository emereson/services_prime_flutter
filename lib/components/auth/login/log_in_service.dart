import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/screen/auth/upload_photo.dart';
import 'package:tecnyapp_flutter/screen/userScreen/home_screen.dart';
import 'package:tecnyapp_flutter/service/auth/auth_provider.dart';
import 'package:tecnyapp_flutter/service/auth/user_data_service.dart';
import 'package:tecnyapp_flutter/utils/app_sanck_bar.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

class LogInService {
  static Future<void> login(
    BuildContext context,
    String name,
    String phoneNumber,
    String dni,
    bool termsConditions,
  ) async {
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    const baseUrl = Config.apiUrl;

    if (name.isEmpty || phoneNumber.isEmpty || dni.isEmpty) {
      AppSnackbar.showError(context, 'Por favor, completa todos los campos');
      return;
    }

    if (!termsConditions) {
      // Mostrar el AlertDialog si los términos y condiciones no están aceptados
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Términos y Condiciones"),
            content: const SingleChildScrollView(
              child: Text(
                'Por favor, acepta los términos y condiciones.',
                textAlign: TextAlign.justify,
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(234, 223, 193, 10),
                ),
                child: const Text(
                  "Cerrar",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el diálogo
                  // Aquí puedes agregar lógica para aceptar los términos si es necesario
                },
              ),
            ],
          );
        },
      );
      return; // Salir de la función si los términos y condiciones no están aceptados
    }

    const url = '$baseUrl/user/login';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'phone_number': phoneNumber,
          'dni': dni,
          'role': 'user'
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String token = responseBody['token'];
        final Map<String, dynamic> userData = responseBody['user'];

        await authProvider.setToken(token);

        await UserDataService.saveUserData(jsonEncode(userData));
        if (userData['profile_photo'] == null) {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UploadPhoto()),
            );
          }
        } else {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      } else {
        if (context.mounted) {
          AppSnackbar.showError(context, 'DNI o teléfono incorrecto');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.showError(context, 'Error al ingresar: $e');
      }
    }
  }
}

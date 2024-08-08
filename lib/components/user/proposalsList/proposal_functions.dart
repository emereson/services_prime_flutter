import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/screen/userScreen/home_screen.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Proposalfunctions {
  static Future<void> cancelService(Map<String, dynamic> serviceRequest,
      IO.Socket socket, BuildContext context) async {
    final serviceId = serviceRequest['id'];

    final url = Uri.parse('${Config.apiUrl}/service-request/$serviceId');
    final response = await http.delete(url);
    if (response.statusCode == 200) {
      socket.emit('sendCancelService');
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }
}

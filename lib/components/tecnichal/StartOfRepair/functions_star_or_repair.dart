import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/utils/app_sanck_bar.dart';

class FunctionsStarOrRepair {
  static Future<void> createRepair(
    BuildContext context,
    Map<String, dynamic> userData,
    Map<String, dynamic> proposal,
    Map<String, dynamic> proforma,
    List<dynamic> panoramicaImages,
    List<dynamic> modeloImages,
    List<dynamic> averiasImages,
    List<dynamic> materialesImages,
    List<dynamic> instalationImages,
    final ValueChanged<bool> onPayChanged,
  ) async {
    final url = Uri.parse('${Config.apiUrl}/repair');
    var request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
    });

    // Añadir campos de texto
    request.fields['technical_id'] = userData['id'].toString();
    request.fields['client_id'] = proforma['client_id'].toString();
    request.fields['service_request_id'] =
        proforma['service_request_id'].toString();
    request.fields['proposal_id'] = proforma['proposal_id'].toString();

    // Agregar archivos solo si no son null
    if (panoramicaImages[0] != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'panorama_img_1',
        panoramicaImages[0]!.path,
      ));
    }
    if (panoramicaImages[1] != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'panorama_img_2',
        panoramicaImages[1]!.path,
      ));
    }
    if (panoramicaImages[2] != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'panorama_img_3',
        panoramicaImages[2]!.path,
      ));
    }
    if (modeloImages[0] != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'model_img_1',
        modeloImages[0]!.path,
      ));
    }
    if (modeloImages[1] != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'model_img_2',
        modeloImages[1]!.path,
      ));
    }
    if (modeloImages[2] != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'model_img_3',
        modeloImages[2]!.path,
      ));
    }
    if (averiasImages[0] != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'breakdowns_img_1',
        averiasImages[0]!.path,
      ));
    }
    if (averiasImages[1] != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'breakdowns_img_2',
        averiasImages[1]!.path,
      ));
    }
    if (averiasImages[2] != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'breakdowns_img_3',
        averiasImages[2]!.path,
      ));
    }
    if (materialesImages[0] != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'materials_img_1',
        materialesImages[0]!.path,
      ));
    }
    if (materialesImages[1] != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'materials_img_2',
        materialesImages[1]!.path,
      ));
    }
    if (materialesImages[2] != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'materials_img_3',
        materialesImages[2]!.path,
      ));
    }
    if (instalationImages[0] != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'facility_img_1',
        instalationImages[0]!.path,
      ));
    }
    if (instalationImages[1] != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'facility_img_2',
        instalationImages[1]!.path,
      ));
    }
    if (instalationImages[2] != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'facility_img_3',
        instalationImages[2]!.path,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      print('object ${response.body}');
    } else {
      final errorResponse = json.decode(response.body);
      throw Exception(
          'Failed to create service with status code: ${response.statusCode}, message: ${errorResponse['message']}');
    }
  }

  static Future<void> updateRepair(
    BuildContext context,
    int id,
    List<dynamic> panoramicaImages,
    List<dynamic> modeloImages,
    List<dynamic> averiasImages,
    List<dynamic> materialesImages,
    List<dynamic> instalationImages,
    final ValueChanged<bool> onPayChanged,
  ) async {
    final url = Uri.parse('${Config.apiUrl}/repair/$id');
    var request = http.MultipartRequest('PATCH', url);

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
    });

    // Agregar archivos solo si no son null
    if (panoramicaImages[0] != null && panoramicaImages[0] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'panorama_img_1',
        (panoramicaImages[0] as File).path,
      ));
    }

    if (panoramicaImages[1] != null && panoramicaImages[1] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'panorama_img_2',
        panoramicaImages[1]!.path,
      ));
    }
    if (panoramicaImages[2] != null && panoramicaImages[2] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'panorama_img_3',
        panoramicaImages[2]!.path,
      ));
    }
    if (modeloImages[0] != null && modeloImages[0] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'model_img_1',
        modeloImages[0]!.path,
      ));
    }
    if (modeloImages[1] != null && modeloImages[1] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'model_img_2',
        modeloImages[1]!.path,
      ));
    }
    if (modeloImages[2] != null && modeloImages[2] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'model_img_3',
        modeloImages[2]!.path,
      ));
    }
    if (averiasImages[0] != null && averiasImages[0] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'breakdowns_img_1',
        averiasImages[0]!.path,
      ));
    }
    if (averiasImages[1] != null && averiasImages[1] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'breakdowns_img_2',
        averiasImages[1]!.path,
      ));
    }
    if (averiasImages[2] != null && averiasImages[2] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'breakdowns_img_3',
        averiasImages[2]!.path,
      ));
    }
    if (materialesImages[0] != null && materialesImages[0] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'materials_img_1',
        materialesImages[0]!.path,
      ));
    }
    if (materialesImages[1] != null && materialesImages[1] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'materials_img_2',
        materialesImages[1]!.path,
      ));
    }
    if (materialesImages[2] != null && materialesImages[2] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'materials_img_3',
        materialesImages[2]!.path,
      ));
    }
    if (instalationImages[0] != null && instalationImages[0] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'facility_img_1',
        instalationImages[0]!.path,
      ));
    }
    if (instalationImages[1] != null && instalationImages[1] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'facility_img_2',
        instalationImages[1]!.path,
      ));
    }
    if (instalationImages[2] != null && instalationImages[2] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'facility_img_3',
        instalationImages[2]!.path,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      if (context.mounted) {
        AppSnackbar.showError(
            context, 'Las imagenes se guardaron correctamente');
      }
    }
  }

  static Future<void> finalizerRepair(
    BuildContext context,
    Map<String, dynamic> proposal,
    IO.Socket socket,
    int id,
    List<dynamic> panoramicaImages,
    List<dynamic> modeloImages,
    List<dynamic> averiasImages,
    List<dynamic> materialesImages,
    List<dynamic> instalationImages,
    final ValueChanged<bool> onPayChanged,
  ) async {
    final url = Uri.parse('${Config.apiUrl}/repair/finalizer/$id');
    var request = http.MultipartRequest('PATCH', url);

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
    });

    // Agregar archivos solo si no son null
    if (panoramicaImages[0] != null && panoramicaImages[0] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'panorama_img_1',
        (panoramicaImages[0] as File).path,
      ));
    }

    if (panoramicaImages[1] != null && panoramicaImages[1] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'panorama_img_2',
        panoramicaImages[1]!.path,
      ));
    }
    if (panoramicaImages[2] != null && panoramicaImages[2] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'panorama_img_3',
        panoramicaImages[2]!.path,
      ));
    }
    if (modeloImages[0] != null && modeloImages[0] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'model_img_1',
        modeloImages[0]!.path,
      ));
    }
    if (modeloImages[1] != null && modeloImages[1] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'model_img_2',
        modeloImages[1]!.path,
      ));
    }
    if (modeloImages[2] != null && modeloImages[2] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'model_img_3',
        modeloImages[2]!.path,
      ));
    }
    if (averiasImages[0] != null && averiasImages[0] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'breakdowns_img_1',
        averiasImages[0]!.path,
      ));
    }
    if (averiasImages[1] != null && averiasImages[1] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'breakdowns_img_2',
        averiasImages[1]!.path,
      ));
    }
    if (averiasImages[2] != null && averiasImages[2] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'breakdowns_img_3',
        averiasImages[2]!.path,
      ));
    }
    if (materialesImages[0] != null && materialesImages[0] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'materials_img_1',
        materialesImages[0]!.path,
      ));
    }
    if (materialesImages[1] != null && materialesImages[1] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'materials_img_2',
        materialesImages[1]!.path,
      ));
    }
    if (materialesImages[2] != null && materialesImages[2] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'materials_img_3',
        materialesImages[2]!.path,
      ));
    }
    if (instalationImages[0] != null && instalationImages[0] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'facility_img_1',
        instalationImages[0]!.path,
      ));
    }
    if (instalationImages[1] != null && instalationImages[1] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'facility_img_2',
        instalationImages[1]!.path,
      ));
    }
    if (instalationImages[2] != null && instalationImages[2] is File) {
      request.files.add(await http.MultipartFile.fromPath(
        'facility_img_3',
        instalationImages[2]!.path,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      socket.emit('sendPay', proposal['client_id']);
      onPayChanged(true);
    }
  }
}

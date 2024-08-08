import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tecnyapp_flutter/screen/userScreen/home_screen.dart';
import 'package:tecnyapp_flutter/utils/app_sanck_bar.dart';
import 'package:tecnyapp_flutter/widgets/drawer/my_drawer.dart';
import 'package:tecnyapp_flutter/widgets/label_top_textarea.dart';
import 'package:tecnyapp_flutter/widgets/my_button.dart';
import 'package:http/http.dart' as http;
import 'package:tecnyapp_flutter/config.dart';

class CalificationScreen extends StatefulWidget {
  final Map<String, dynamic> proposal; // Cambio aquí
  const CalificationScreen(
      {super.key,
      required this.proposal}); // Eliminar const si se usa en el constructor

  @override
  State<CalificationScreen> createState() => _CalificationScreenState();
}

class _CalificationScreenState extends State<CalificationScreen> {
  final TextEditingController descriptionController = TextEditingController();
  int _selectedStars = 0;
  bool _viewScreen =
      false; // Inicia en false, cambia a true cuando los datos estén listos

  @override
  void initState() {
    super.initState();
    _loadData(); // Cargar datos iniciales si es necesario
  }

  Future<void> _loadData() async {
    // Simula una carga de datos, actualiza _viewScreen a true cuando termines
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _viewScreen =
          true; // Cambia a true para mostrar la pantalla de calificación
    });
  }

  Future<void> createProposal() async {
    const url = '${Config.apiUrl}/qualification';

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': widget.proposal['client_id'],
        'technical_id': widget.proposal['user']['id'],
        'service_request_id': widget.proposal['service_request_id'],
        'stars': _selectedStars,
        'comment': descriptionController.text
      }),
    );

    if (response.statusCode == 200) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      if (mounted) {
        AppSnackbar.showError(context, 'Error al enviar la propuesta');
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
            "Calificar al tecnico",
            style: TextStyle(fontSize: 20),
          ),
        ),
        drawer: const MyDrawer(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'tecnico:${widget.proposal['user']['name']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 0.5,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                const SizedBox(height: 20),
                _buildStarRating(),
                const SizedBox(height: 20),
                LabelTopTextarea(
                  controller: descriptionController,
                  label: 'Comentario',
                  icon: Icons.description,
                ),
                const SizedBox(height: 20),
                Center(
                  child: MyButton(
                    colorButton: Theme.of(context).colorScheme.onPrimary,
                    text: "Guardar",
                    onTap: () async {
                      await createProposal(); // Llamada a createProposal
                    },
                  ),
                )
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

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(5, (index) {
        return IconButton(
          icon: Icon(
            _selectedStars > index ? Icons.star : Icons.star_border,
            color: _selectedStars > index
                ? Theme.of(context).colorScheme.onPrimary
                : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _selectedStars = index + 1;
            });
          },
        );
      }),
    );
  }
}

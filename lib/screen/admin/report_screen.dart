import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/service/auth/auth_service.dart';
import 'package:tecnyapp_flutter/utils/local_notifications.dart';
import 'package:tecnyapp_flutter/widgets/date.dart';
import 'package:tecnyapp_flutter/widgets/drawer/my_drawer.dart';
import 'package:tecnyapp_flutter/widgets/label_top_select.dart';
import 'package:http/http.dart' as http;
import 'package:tecnyapp_flutter/widgets/my_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String startDate = DateTime.now().toLocal().toIso8601String().split('T')[0];
  String endDate = DateTime.now().toLocal().toIso8601String().split('T')[0];
  String? selectedOption;
  String? selectedService;
  String? selectedTechnical;
  String? selectStatus;

  String? _token;

  List<dynamic> allServices = [];
  List<dynamic> technicians = [];

  @override
  void initState() {
    super.initState();
    getService();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final token = await AuthService.getToken();
    setState(() {
      _token = token;
    });
    getTechnicians();
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
    final url = Uri.parse('${Config.apiUrl}/user/technicians');
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

  // Future<void> downloadFile() async {
  //   final status = await Permission.storage.request();

  //   if (status.isGranted) {
  //     final url = Uri.parse(
  //         '${Config.apiUrl}/exel/globalProduction?typeService=${selectedService.toString()}&startDate=$startDate&endDate=$endDate&name=$selectedTechnical');
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       final directory =
  //           await getExternalStorageDirectory(); // Cambia a almacenamiento externo
  //       final filePath = '${directory?.path}/data.xlsx';
  //       final file = File(filePath);
  //       await file.writeAsBytes(response.bodyBytes);

  //       if (mounted) {
  //         final localNotifications =
  //             Provider.of<LocalNotifications>(context, listen: false);

  //         localNotifications.showNotification(
  //           title: 'Descarga completa',
  //           body: 'El archivo ha sido descargado exitosamente en $filePath.',
  //         );
  //       }
  //     } else {
  //       print('Permiso de almacenamiento denegado.');
  //     }
  //   }
  // }

  Future<void> downloasRankingTechnician() async {
    final url = Uri.parse(
        '${Config.apiUrl}/exel/rankingTechnician?nameTec=$selectedTechnical&startDate=$startDate&endDate=$endDate');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final directory =
          await getExternalStorageDirectory(); // Cambia a almacenamiento externo
      final filePath = '${directory!.path}/data.xlsx';

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      if (mounted) {
        final localNotifications =
            Provider.of<LocalNotifications>(context, listen: false);

        localNotifications.showNotification(
          title: 'Descarga completa',
          body: 'El archivo ha sido descargado exitosamente en $filePath.',
        );
      }
    }
  }

  Future<void> rankingProductionsTec() async {
    final url = Uri.parse(
        '${Config.apiUrl}/exel/rankingProductionsTec?startDate=$startDate&endDate=$endDate');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final directory =
          await getExternalStorageDirectory(); // Cambia a almacenamiento externo
      final filePath = '${directory!.path}/data.xlsx';

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      if (mounted) {
        final localNotifications =
            Provider.of<LocalNotifications>(context, listen: false);

        localNotifications.showNotification(
          title: 'Descarga completa',
          body: 'El archivo ha sido descargado exitosamente en $filePath.',
        );
      }
    }
  }

  Future<void> claims() async {
    final url = Uri.parse(
        '${Config.apiUrl}/exel/claims?startDate=$startDate&endDate=$endDate');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final directory =
          await getExternalStorageDirectory(); // Cambia a almacenamiento externo
      final filePath = '${directory!.path}/data.xlsx';

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      if (mounted) {
        final localNotifications =
            Provider.of<LocalNotifications>(context, listen: false);

        localNotifications.showNotification(
          title: 'Descarga completa',
          body: 'El archivo ha sido descargado exitosamente en $filePath.',
        );
      }
    }
  }

  Future<void> stateProduction() async {
    final url = Uri.parse(
        '${Config.apiUrl}/exel/stateProduction?startDate=$startDate&endDate=$endDate&status=$selectStatus');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final directory =
          await getExternalStorageDirectory(); // Cambia a almacenamiento externo
      final filePath = '${directory!.path}/data.xlsx';

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      if (mounted) {
        final localNotifications =
            Provider.of<LocalNotifications>(context, listen: false);

        localNotifications.showNotification(
          title: 'Descarga completa',
          body: 'El archivo ha sido descargado exitosamente en $filePath.',
        );
      }
    }
  }

  Future<void> downloadFile(
      BuildContext context, String url, String fileName) async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      final response = await http.get(Uri.parse(url));

      print('object$url');

      if (response.statusCode == 200) {
        // Usa el directorio de descargas
        final filePath = await FilePicker.platform.saveFile(
          dialogTitle: 'Selecciona la ubicación para guardar el archivo',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
        );

        if (filePath != null) {
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
        }
      } else {
        print('object${response.body}');
      }
    }
  }

  void generateExel() async {
    if (selectedOption == 'Producción global') {
      downloadFile(
          context,
          '${Config.apiUrl}/exel/globalProduction?typeService=${selectedService.toString()}&startDate=$startDate&endDate=$endDate&name=$selectedTechnical',
          'produccion_global');
    }
    if (selectedOption == 'Producción por servicio') {
      downloadFile(
          context,
          '${Config.apiUrl}/exel/globalProduction?typeService=${selectedService.toString()}&startDate=$startDate&endDate=$endDate',
          'produccion_servicio');
    }
    if (selectedOption == 'Producción por tecnico') {
      downloadFile(
          context,
          '${Config.apiUrl}/exel/globalProduction?typeService=${selectedService.toString()}&startDate=$startDate&endDate=$endDate&name=$selectedTechnical',
          'produccion_tecnico');
    }
    if (selectedOption == 'Ranking calificación por tecnico') {
      downloadFile(
          context,
          '${Config.apiUrl}/exel/rankingTechnician?nameTec=$selectedTechnical&startDate=$startDate&endDate=$endDate',
          'ranking_tecnico');
    }
    if (selectedOption == 'Ranking producción todos tecnicos') {
      downloadFile(
          context,
          '${Config.apiUrl}/exel/rankingProductionsTec?startDate=$startDate&endDate=$endDate',
          'ranking_todos_tecnicos');
    }
    if (selectedOption == 'Reclamos') {
      downloadFile(
          context,
          '${Config.apiUrl}/exel/claims?startDate=$startDate&endDate=$endDate',
          'reclamos');
    }
    if (selectedOption == 'Produccion por estados') {
      downloadFile(
          context,
          '${Config.apiUrl}/exel/stateProduction?startDate=$startDate&endDate=$endDate&status=$selectStatus',
          'produccion_estados');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text(
          "Reportes",
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
                label: 'Elegir tipo de reporte',
                options: const [
                  'Producción global',
                  'Producción por servicio',
                  'Producción por tecnico',
                  'Ranking calificación por tecnico',
                  'Ranking producción todos tecnicos',
                  'Reclamos',
                  'Reclamos por tecnicos',
                  'Produccion por estados'
                ],
                selectedValue: selectedOption,
                onChanged: (value) {
                  selectedService = null;
                  selectedTechnical = null;
                  setState(() {
                    selectedOption = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              if (selectedOption == 'Producción por servicio')
                LabelTopSelect(
                  label: 'Elegir Servicio',
                  options: allServices
                      .map((service) => service['service_name'] as String)
                      .toList(),
                  selectedValue: selectedService,
                  onChanged: (value) {
                    setState(() {
                      selectedService = value;
                    });
                  },
                ),
              if (selectedOption == 'Producción por tecnico')
                LabelTopSelect(
                  label: 'Elegir Tecnico',
                  options: technicians
                      .map((technical) => technical['name'] as String)
                      .toList(),
                  selectedValue: selectedTechnical,
                  onChanged: (value) {
                    setState(() {
                      selectedTechnical = value;
                    });
                  },
                ),
              if (selectedOption == 'Ranking calificación por tecnico')
                LabelTopSelect(
                  label: 'Elegir Tecnico',
                  options: technicians
                      .map((technical) => technical['name'] as String)
                      .toList(),
                  selectedValue: selectedTechnical,
                  onChanged: (value) {
                    setState(() {
                      selectedTechnical = value;
                    });
                  },
                ),
              if (selectedOption == 'Produccion por estados')
                LabelTopSelect(
                  label: 'Elegir Tecnico',
                  options: const [
                    'Diagnostico pendiente',
                    'Diagnostico aprobado',
                    'Diagnostico confirmado',
                    'Reparación',
                    'Diagnostico finalizado',
                    'Reparacion Finalizada',
                    'Solicitud cancelada'
                  ],
                  selectedValue: selectStatus,
                  onChanged: (value) {
                    setState(() {
                      selectStatus = value;
                    });
                  },
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: DateSelector(
                      date: startDate,
                      label: 'Fecha inicio',
                      icon: Icons.calendar_today,
                      onDateSelected: (newDate) {
                        setState(() {
                          startDate = newDate;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: DateSelector(
                      date: endDate,
                      label: 'Fecha fin',
                      icon: Icons.calendar_today,
                      onDateSelected: (newDate) {
                        setState(() {
                          endDate = newDate;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              MyButton(
                text: 'Generar',
                onTap: generateExel,
                colorButton: Theme.of(context).colorScheme.onPrimary,
              )
            ],
          ),
        ),
      ),
    );
  }
}

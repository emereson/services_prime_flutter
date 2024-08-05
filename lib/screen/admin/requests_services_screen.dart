import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tecnyapp_flutter/components/admin/requests_services/details/details_request_service.dart';
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/service/auth/auth_service.dart';
import 'package:tecnyapp_flutter/service/auth/user_data_service.dart';
import 'package:tecnyapp_flutter/utils/app_sanck_bar.dart';
import 'package:tecnyapp_flutter/widgets/date.dart';
import 'package:tecnyapp_flutter/widgets/drawer/my_drawer.dart';
import 'package:tecnyapp_flutter/widgets/label_top.dart';
import 'package:tecnyapp_flutter/widgets/label_top_select.dart';
import 'package:http/http.dart' as http;
import 'package:tecnyapp_flutter/widgets/my_button.dart';

class RequestsServicesScreen extends StatefulWidget {
  const RequestsServicesScreen({super.key});

  @override
  State<RequestsServicesScreen> createState() => RequestsServicesScreenState();
}

class RequestsServicesScreenState extends State<RequestsServicesScreen> {
  final TextEditingController nameController = TextEditingController();

  String? _token;
  String? selectedOption;
  List<dynamic> allServices = [];
  List<dynamic> requestsServices = [];
  String startDate = DateTime.now().toLocal().toIso8601String().split('T')[0];
  String endDate = DateTime.now().toLocal().toIso8601String().split('T')[0];
  late Map<String, dynamic> userData;
  bool existTechnical = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final jsonString = await UserDataService.getUserData();
    final token = await AuthService.getToken();
    if (jsonString != null) {
      setState(() {
        userData = jsonDecode(jsonString);
        _token = token;
      });

      getService();
    }
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

  void getrequestsServices() async {
    final url = Uri.parse(
        '${Config.apiUrl}/service-request/all?typeService=${selectedOption.toString()}&startDate=$startDate&endDate=$endDate');
    final response =
        await http.get(url, headers: {'Authorization': 'Bearer $_token'});

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (mounted) {
        setState(() {
          requestsServices = jsonResponse['serviceRequests']; // Ajuste correcto
        });
      }
    }
  }

  Future<void> deleteTechnical(BuildContext context, technical) async {
    final url = Uri.parse('${Config.apiUrl}/user/${technical?['id']}');

    final response =
        await http.delete(url, headers: {'Authorization': 'Bearer $_token'});

    if (response.statusCode == 200) {
      if (context.mounted) {
        AppSnackbar.showError(context, 'Usuario eliminado');
      }
      getrequestsServices();
    } else {
      if (context.mounted) {
        AppSnackbar.showError(
            context, 'Error al eliminar el usuario ${response.body}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text(
          "Servicios solicitados",
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
                label: 'Elegir Servicio',
                options: allServices
                    .map((service) => service['service_name'] as String)
                    .toList(),
                selectedValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value;
                  });
                },
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 10),
              LabelTop(
                controller: nameController,
                label: 'Tecnico',
                icon: Icons.person_4,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(
                      width: 10), // Espacio entre el TextField y el botón
                  MyButton(
                    text: "Buscar",
                    colorButton: Theme.of(context).colorScheme.onPrimary,

                    onTap: getrequestsServices, // Llamada correcta al método
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...requestsServices.map<Widget>((service) {
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
                                    service['user']['name'],
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inverseSurface,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    service['address'],
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
                                      fontSize: 14,
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
                                                  .onSurface,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            service['statusPay'],
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              width: 100,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: Center(
                                                child: Text(
                                                  'Tec. Cercanos',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 13,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .inverseSurface,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailsRequestService(
                                                            selectService:
                                                                service['id']
                                                                    .toString())),
                                              );
                                            },
                                            child: Container(
                                              width: 100,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                  color: const Color.fromARGB(
                                                      255, 6, 178, 40),
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: Center(
                                                child: Text(
                                                  'Detalles',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 13,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .inverseSurface,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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

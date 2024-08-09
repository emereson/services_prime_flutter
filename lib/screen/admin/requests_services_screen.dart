import 'dart:convert';
import 'dart:math';
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
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:url_launcher/url_launcher.dart';

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
  final socket = IO.io('https://serviciosmap-backend-production.up.railway.app',
      IO.OptionBuilder().setTransports(['websocket']).enableForceNew().build());

  List<dynamic> usersOnline = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void initializeSocket() {
    socket.onConnect((_) {
      socket.emit('registerClient', userData['id']);
    });
    socket.on('technicalLocation', (data) {
      if (mounted) {
        setState(() {
          usersOnline = data;
        });
      }
    });
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
      initializeSocket();
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

  double haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radio de la Tierra en km
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distancia en km
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void showPopUp(
      BuildContext context, Map<String, dynamic> service, String myLocation) {
    // Extraer latitud y longitud de myLocation
    final myLatLng = myLocation.split(',');
    final myLat = double.parse(myLatLng[0]);
    final myLng = double.parse(myLatLng[1]);

    // Filtrar técnicos que están a menos de 10 km
    final nearbyTechnicals = usersOnline.where((technical) {
      final technicalLat = double.parse(technical['location']['latitude']);
      final technicalLng = double.parse(technical['location']['longitude']);
      final distance = haversine(myLat, myLng, technicalLat, technicalLng);

      return distance <= 10; // Filtrar técnicos en un radio de 10 km
    }).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Técnicos cercanos al servicio'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Ajusta el tamaño de la columna
            children: [
              const Text('Listado de técnicos cercanos al servicio solicitado'),
              const SizedBox(height: 20),
              ...nearbyTechnicals.map<Widget>((technical) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      border: Border.all(
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('${technical['technical']['name']}',
                                style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 10),
                            Text('${technical['technical']['phone_number']}',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 3),
                        GestureDetector(
                          onTap: () async {
                            final latitude = technical['location']['latitude'];
                            final longitude =
                                technical['location']['longitude'];
                            final googleMapsUrl = Uri.parse(
                                'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

                            if (await canLaunchUrl(googleMapsUrl)) {
                              await launchUrl(googleMapsUrl,
                                  mode: LaunchMode.externalApplication);
                            } else {
                              throw 'No se pudo abrir Google Maps';
                            }
                          },
                          child: Text(
                            'coordenadas: ${technical['location']['latitude']} ${technical['location']['longitude']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(234, 223, 193, 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }), // Convierte la lista a un Widget List
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white, // Color del texto
                  backgroundColor: Colors.red, // Color de fondo
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ),
          ],
        );
      },
    );
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
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  showPopUp(context, service,
                                                      service['coordinates']);
                                                },
                                                child: Container(
                                                  width: 100,
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8),
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                  child: Center(
                                                    child: Text(
                                                      'Tec. Cercanos',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 13,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .inverseSurface,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
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
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8),
                                                  decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 6, 178, 40),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                  child: Center(
                                                    child: Text(
                                                      'Detalles',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
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

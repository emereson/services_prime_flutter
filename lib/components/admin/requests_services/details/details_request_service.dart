import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tecnyapp_flutter/components/admin/requests_services/details/expansion_exist_img.dart';
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/service/auth/auth_service.dart';
import 'package:tecnyapp_flutter/widgets/drawer/my_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tecnyapp_flutter/widgets/my_button.dart';

class DetailsRequestService extends StatefulWidget {
  final String selectService;

  const DetailsRequestService({super.key, required this.selectService});

  @override
  State<DetailsRequestService> createState() => _DetailsRequestServiceState();
}

class _DetailsRequestServiceState extends State<DetailsRequestService> {
  late Map<String, dynamic> serviceData;
  late Map<String, dynamic> proformaData;
  late Map<String, dynamic> repairsData;
  late Map<String, dynamic> payments;
  final baseUrl = Config.apiUrl;
  File? image;

  bool viewScreen = false;
  bool isLoading = false;

  String? _token;

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  Future<void> loadToken() async {
    final token = await AuthService.getToken();
    if (token != null) {
      setState(() {
        _token = token;
      });

      getrequestsServices();
    }
  }

  void getrequestsServices() async {
    final url = Uri.parse('$baseUrl/service-request/${widget.selectService}');
    final response =
        await http.get(url, headers: {'Authorization': 'Bearer $_token'});

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (mounted) {
        setState(() {
          serviceData = jsonResponse['serviceRequest'];
        });
        setState(() {
          proformaData = serviceData['proformas'].length > 0
              ? serviceData['proformas'][0]
              : {};
          repairsData = serviceData['repairs'].length > 0
              ? serviceData['repairs'][0]
              : {};
          payments = serviceData['payments'].length > 0
              ? serviceData['payments'][0]
              : {};
          viewScreen = true;
        });
      }
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    setState(() {
      isLoading = true;
    });
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una imagen primero'),
        ),
      );
      return;
    }

    final url = Uri.parse('$baseUrl/pay/${payments['id']}');
    var request = http.MultipartRequest('PATCH', url);

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $_token',
    });
    request.files.add(await http.MultipartFile.fromPath(
      'factura_img',
      image!.path,
    ));

    var response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('la factura se guardo correctamente'),
          ),
        );
      }
      getrequestsServices();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (viewScreen) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: const Text(
            "Detalle del servicio solicitado",
            style: TextStyle(fontSize: 20),
          ),
        ),
        drawer: const MyDrawer(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ExpansionTile(
                    expandedCrossAxisAlignment: CrossAxisAlignment.center,
                    title: const Text(
                      'Materiales de reparacion',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${proformaData['type_service']}/${proformaData['category']}/${proformaData['products']}',
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'tipos:',
                              style: TextStyle(
                                color: Color.fromARGB(255, 191, 191, 191),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Column(children: [
                              if (proformaData['systems'] != null)
                                ...proformaData['systems']
                                    .map<Widget>((system) => Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              system['system'],
                                            ),
                                            Column(
                                              children: [
                                                ...system['systemOptionPrices']
                                                    .map<Widget>((options) =>
                                                        Row(
                                                          children: [
                                                            Text(
                                                              options[
                                                                  'option_name'],
                                                              style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .inversePrimary,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            Text(
                                                              's/.${options['price']}',
                                                              style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .inversePrimary,
                                                              ),
                                                            )
                                                          ],
                                                        ))
                                                    .toList(),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        ))
                                    .toList(),
                            ]),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                'TOTAL:     s/.${proformaData['total']}',
                                style: const TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                  'Descripción: ${proformaData['description']}'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ExpansionTile(
                    expandedCrossAxisAlignment: CrossAxisAlignment.center,
                    title: const Text(
                      'Fotos de la reparación',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary,
                                border: Border.all(
                                  width: 1,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ExpansionTile(
                                title: const Text(
                                  'Foto de inicio',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                children: [
                                  ExpansionExistImg(
                                    title: 'Panorámica',
                                    imageUrls: [
                                      repairsData['panorama_img_1'],
                                      repairsData['panorama_img_2'],
                                      repairsData['panorama_img_3']
                                    ],
                                  ),
                                  ExpansionExistImg(
                                    title: 'Modelo',
                                    imageUrls: [
                                      repairsData['model_img_1'],
                                      repairsData['model_img_2'],
                                      repairsData['model_img_3']
                                    ],
                                  ),
                                  ExpansionExistImg(
                                    title: 'Averías',
                                    imageUrls: [
                                      repairsData['breakdowns_img_1'],
                                      repairsData['breakdowns_img_2'],
                                      repairsData['breakdowns_img_3']
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary,
                                border: Border.all(
                                  width: 1,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ExpansionTile(
                                title: const Text(
                                  'Foto de proceso',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                children: [
                                  ExpansionExistImg(
                                    title: 'Panorámica',
                                    imageUrls: [
                                      repairsData['materials_img_1'],
                                      repairsData['materials_img_2'],
                                      repairsData['materials_img_3']
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary,
                                border: Border.all(
                                  width: 1,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ExpansionTile(
                                title: const Text(
                                  'Fotos finales',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                children: [
                                  ExpansionExistImg(
                                    title: 'Panorámica',
                                    imageUrls: [
                                      repairsData['facility_img_1'],
                                      repairsData['facility_img_2'],
                                      repairsData['facility_img_3']
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ExpansionTile(
                    expandedCrossAxisAlignment: CrossAxisAlignment.center,
                    title: const Text(
                      'Gestion de pagos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${proformaData['type_service']}/${proformaData['category']}/${proformaData['products']}',
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Voucher del servicio',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  width: 1,
                                ),
                              ),
                              child: payments['pay_img'] != null
                                  ? Image.network(
                                      '${Config.imgUrl}/image/${payments['pay_img']!}',
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : const Text('No hay pago'),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Boleta o factura ',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: payments['factura_img'] != null
                                      ? Image.network(
                                          '${Config.imgUrl}/image/${payments['factura_img']!}',
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : GestureDetector(
                                          onTap: pickImage,
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                width: 1,
                                              ),
                                            ),
                                            child: image != null
                                                ? Image.file(
                                                    image!,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  )
                                                : const Column(
                                                    children: [
                                                      Text(
                                                        'Haga clic para cargar la factura, Formato Soportado .jpg, .png',
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      SizedBox(height: 20),
                                                      Icon(Icons.add),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                )),
                            const SizedBox(height: 20),
                            payments['factura_img'] == null
                                ? isLoading
                                    ? const CircularProgressIndicator()
                                    : Center(
                                        child: MyButton(
                                          colorButton: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          onTap: _uploadImage,
                                          text: 'GUARDAR',
                                        ),
                                      )
                                : const SizedBox(height: 0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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

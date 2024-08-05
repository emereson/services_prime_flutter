import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/utils/app_sanck_bar.dart';
import 'package:tecnyapp_flutter/widgets/custom_expansion_tile.dart';
import 'package:tecnyapp_flutter/widgets/drawer/my_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:tecnyapp_flutter/widgets/label_top.dart';

class ConfigureMaterials extends StatefulWidget {
  const ConfigureMaterials({super.key});

  @override
  State<ConfigureMaterials> createState() => _ConfigureMaterialsState();
}

class _ConfigureMaterialsState extends State<ConfigureMaterials> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController minController = TextEditingController();
  final TextEditingController maxController = TextEditingController();

  late List<dynamic> allServices = [];
  bool _isLoading = true;
  Map<String, TextEditingController> controllers = {};
  Map<String, dynamic> formData = {};

  @override
  void initState() {
    super.initState();
    fetchService();
  }

  Future<void> fetchService() async {
    final url = Uri.parse('${Config.apiUrl}/service');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['status'] == 'success') {
        setState(() {
          allServices = jsonResponse['services'];
          _isLoading = false;
        });
      }
    }
  }

  void createOption(int id) async {
    final url = Uri.parse('${Config.apiUrl}/system-option/$id');
    final response = await http.post(
      url,
      body: json.encode({
        'option_name': nameController.text,
        'minimum_range': minController.text,
        'maximum_range': maxController.text,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        nameController.text = '';
        minController.text = '';
        maxController.text = '';
      });
      fetchService();
      if (mounted) {
        AppSnackbar.showError(context, 'La opcion se creo correctamente');
      }
    }
  }

  void updateOption(int id) async {
    final url = Uri.parse('${Config.apiUrl}/system-option/$id');
    final response = await http.patch(
      url,
      body: json.encode({
        'option_name': nameController.text,
        'minimum_range': minController.text,
        'maximum_range': maxController.text,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        nameController.text = '';
        minController.text = '';
        maxController.text = '';
      });
      fetchService();
    }
  }

  void deleteOption(int id) async {
    final url = Uri.parse('${Config.apiUrl}/system-option/$id');
    final response = await http.delete(
      url,
    );

    if (response.statusCode == 200) {
      if (mounted) {
        AppSnackbar.showError(context, 'Opcion eliminada');
      }
      fetchService();
    }
  }

  void createOptionPopUp(
      BuildContext context, Map<String, dynamic> productSystem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Crear Opcion'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ingresa los datos para la nueva opcion'),
                const SizedBox(height: 10),
                LabelTop(
                  controller: nameController,
                  label: 'Nombre',
                  icon: Icons.abc_outlined,
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9]+(\.[0-9]*)?')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'min',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: maxController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9]+(\.[0-9]*)?')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'max',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
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
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 30), // Espacio entre los botones
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white, // Color del texto
                    backgroundColor: Colors.green, // Color de fondo
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    createOption(productSystem['id']);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void showPopUp(BuildContext context, Map<String, dynamic> systemOption) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Opcion'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Datos de la opcion ${systemOption['option_name']}'),
                const SizedBox(height: 10),
                LabelTop(
                  controller: nameController,
                  label: 'Nombre',
                  icon: Icons.abc_outlined,
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9]+(\.[0-9]*)?')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'min',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: maxController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9]+(\.[0-9]*)?')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'max',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
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
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 30), // Espacio entre los botones
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white, // Color del texto
                    backgroundColor: Colors.green, // Color de fondo
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    updateOption(systemOption['id']);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void deleteOptionPop(
      BuildContext context, Map<String, dynamic> systemOption) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Opcion'),
          content: Text(
              'Esta seguro que quiere eliminar  la opcion ${systemOption['option_name']}'),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
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
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 30), // Espacio entre los botones
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white, // Color del texto
                      backgroundColor: Colors.green, // Color de fondo
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      deleteOption(systemOption['id']);
                    },
                    child: const Text('Aceptar'),
                  ),
                ],
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
          "Configurar precios de materiales",
          style: TextStyle(fontSize: 20),
        ),
      ),
      drawer: const MyDrawer(),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: allServices.map((service) {
                      return CustomExpansionTile(
                        marginHorizontal: 5,
                        title: service['service_name'],
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        textColor: const Color.fromARGB(255, 248, 248, 248),
                        children: (service['service_categories'] as List)
                            .map<Widget>((category) {
                          return CustomExpansionTile(
                            marginHorizontal: 0,
                            title: category['category_name'],
                            backgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            textColor: const Color.fromARGB(255, 248, 248, 248),
                            children: (category['category_products'] as List)
                                .map<Widget>((product) {
                              return CustomExpansionTile(
                                marginHorizontal: 0,
                                title: product['product_name'],
                                backgroundColor:
                                    Theme.of(context).colorScheme.tertiary,
                                textColor:
                                    const Color.fromARGB(255, 248, 248, 248),
                                children: (product['product_systems'] as List)
                                    .map<Widget>((system) {
                                  return CustomExpansionTile(
                                      marginHorizontal: 0,
                                      title: system['system_name'],
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      textColor: const Color.fromARGB(
                                          255, 248, 248, 248),
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const SizedBox(width: 30),
                                            GestureDetector(
                                              onTap: () {
                                                createOptionPopUp(
                                                    context, system);
                                              },
                                              child: Container(
                                                width: 120,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14),
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Center(
                                                  child: Text(
                                                    "Agregar",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 14,
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
                                        ...(system['system_options'] as List)
                                            .map<Widget>((systemOption) {
                                          return Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 2),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .tertiary,
                                                border: Border.all(
                                                  width: 1,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .tertiary,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(systemOption[
                                                        'option_name']),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                        '${systemOption['minimum_range']} - ${systemOption['maximum_range']}'),
                                                    const SizedBox(width: 20),
                                                    TextButton(
                                                      onPressed: () {
                                                        showPopUp(
                                                          context,
                                                          systemOption,
                                                        );
                                                        setState(() {
                                                          nameController.text =
                                                              systemOption[
                                                                  'option_name'];
                                                          minController.text =
                                                              systemOption[
                                                                  'minimum_range'];
                                                          maxController.text =
                                                              systemOption[
                                                                  'maximum_range'];
                                                        });
                                                      },
                                                      style:
                                                          TextButton.styleFrom(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4,
                                                                horizontal: 10),
                                                        minimumSize: Size.zero,
                                                        backgroundColor:
                                                            const Color
                                                                .fromARGB(
                                                          234,
                                                          48,
                                                          129,
                                                          173,
                                                        ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: const Icon(
                                                          Icons.edit,
                                                          color: Color.fromARGB(
                                                              255,
                                                              248,
                                                              248,
                                                              248)),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    TextButton(
                                                      onPressed: () {
                                                        deleteOptionPop(context,
                                                            systemOption);
                                                      },
                                                      style:
                                                          TextButton.styleFrom(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4,
                                                                horizontal: 10),
                                                        minimumSize: Size.zero,
                                                        backgroundColor:
                                                            const Color
                                                                .fromARGB(
                                                                255, 255, 1, 1),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: const Icon(
                                                          Icons.delete,
                                                          color: Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255)),
                                                    ),
                                                  ],
                                                ),
                                              ]));
                                        }),
                                      ]);
                                }).toList(),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
          ],
        ),
      )),
    );
  }
}

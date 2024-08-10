import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tecnyapp_flutter/components/admin/dashboard_grid_item.dart';
import 'package:tecnyapp_flutter/screen/admin/claims_screen.dart';
import 'package:tecnyapp_flutter/screen/admin/clients_screen.dart';
import 'package:tecnyapp_flutter/screen/admin/configure_materials.dart';
import 'package:tecnyapp_flutter/screen/admin/facturas_screen.dart';
import 'package:tecnyapp_flutter/screen/admin/report_screen.dart';
import 'package:tecnyapp_flutter/screen/admin/requests_services_screen.dart';
import 'package:tecnyapp_flutter/screen/admin/technicians_screen.dart';
import 'package:tecnyapp_flutter/service/auth/user_data_service.dart';
import 'package:tecnyapp_flutter/widgets/drawer/my_drawer.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final socket = IO.io('https://serviciosmap-backend-production.up.railway.app',
      IO.OptionBuilder().setTransports(['websocket']).enableForceNew().build());
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
      initializeSocket();
    }
  }

  void initializeSocket() {
    socket.onConnect((_) {
      socket.emit('registerClient', userData['id']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text(
          "Acceso administrador",
          style: TextStyle(fontSize: 20),
        ),
      ),
      drawer: const MyDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2 / 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            children: [
              DashboardGridItem(
                imagePath: Icons.engineering_rounded,
                title: 'Tecnicos',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TechniciansScreen()),
                  );
                },
              ),
              DashboardGridItem(
                imagePath: Icons.boy,
                title: 'Clientes',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ClientsScreen()),
                  );
                },
              ),
              DashboardGridItem(
                imagePath: Icons.assignment_rounded,
                title: 'Servicios solicitados',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RequestsServicesScreen()),
                  );
                },
              ),
              DashboardGridItem(
                imagePath: Icons.auto_stories,
                title: 'Reclamos',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ClaimsScreen()),
                  );
                },
              ),
              DashboardGridItem(
                imagePath: Icons.content_paste_sharp,
                title: 'Cargar boletas y facturas',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FacturasScreen()),
                  );
                },
              ),
              DashboardGridItem(
                imagePath: Icons.handyman_sharp,
                title: 'Configurar materiales',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ConfigureMaterials()),
                  );
                },
              ),
              DashboardGridItem(
                imagePath: Icons.report,
                title: 'Reportes',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ReportScreen()),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

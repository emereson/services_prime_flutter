import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:tecnyapp_flutter/components/home/home_form.dart';
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/screen/userScreen/proposals_screen.dart';
import 'package:tecnyapp_flutter/service/auth/user_data_service.dart';
import 'package:tecnyapp_flutter/service/loading_page.dart';
import 'package:tecnyapp_flutter/service/location/location_service.dart';
import 'package:tecnyapp_flutter/widgets/drawer/my_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _viewHome = false;
  bool isLocationRetrieved = false;
  List<dynamic> allServices = [];
  late Map<String, dynamic> userData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    userData = {};

    loadUserData();
    LocationService().checkLocationPermission((LatLng? latLng) {
      if (latLng != null) {
        if (mounted) {
          setState(() {
            isLocationRetrieved = true;
          });
        }
      }
    });
    fetchData();
  }

  Future<void> loadUserData() async {
    final jsonString = await UserDataService.getUserData();
    if (jsonString != null) {
      setState(() {
        userData = jsonDecode(jsonString);
      });
      validExistService();
      fetchData();
    }
  }

  Future<void> fetchData() async {
    final url = Uri.parse('${Config.apiUrl}/service');
    final response = await http.get(url);

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

  Future<void> validExistService() async {
    final url =
        Uri.parse('${Config.apiUrl}/service-request/user/${userData['id']}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProposalsScreen()),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _viewHome = true;
        });
      }
    }
  }

  void onPayChanged(bool newValue) {
    setState(() {
      _isLoading = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_viewHome) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: const Text(
            "Solicitud de Servicio",
            style: TextStyle(fontSize: 20),
          ),
        ),
        drawer: const MyDrawer(),
        body: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(15),
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: HomeForm(
                  onPayChanged: onPayChanged,
                  userData: userData,
                  allServices: allServices,
                ),
              ),
              if (_isLoading) const LoadingPage(),
            ],
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

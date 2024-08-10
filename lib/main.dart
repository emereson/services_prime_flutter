import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tecnyapp_flutter/config.dart';
import 'package:tecnyapp_flutter/screen/admin/dashboard_screen.dart';
import 'package:tecnyapp_flutter/screen/auth/upload_photo.dart';
import 'package:tecnyapp_flutter/screen/technicalScreen/start_of_repair.dart';
import 'package:tecnyapp_flutter/screen/userScreen/home_screen.dart';
import 'package:tecnyapp_flutter/screen/auth/login_screen.dart';
import 'package:tecnyapp_flutter/screen/technicalScreen/request_list_screen.dart';
import 'package:tecnyapp_flutter/screen/technicalScreen/sharing_location_screen.dart';
import 'package:tecnyapp_flutter/service/auth/user_data_service.dart';
import 'package:tecnyapp_flutter/themes/theme_provider.dart';
import 'package:tecnyapp_flutter/service/auth/auth_provider.dart';
import 'package:tecnyapp_flutter/utils/local_notifications.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localNotifications = LocalNotifications();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider()..loadToken(),
        ),
        Provider<LocalNotifications>.value(value: localNotifications),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> _getInitialRoute(AuthProvider authProvider) async {
    if (authProvider.isAuthenticated) {
      final userData = await UserDataService.getUserData();
      final user = jsonDecode(userData as String) ?? {};

      if (user.isEmpty) {
        return '/login';
      }

      if (user['role'] == 'technical') {
        final url = Uri.parse(
            '${Config.apiUrl}/proposal/sharing-location/true/technical/${user['id']}');
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final responseData =
              jsonDecode(response.body) as Map<String, dynamic>;
          final proposal = responseData['proposal'] as Map<String, dynamic>?;

          if (proposal != null && proposal.isNotEmpty) {
            final existProformaUrl =
                Uri.parse('${Config.apiUrl}/proforma/exist-proforma')
                    .replace(queryParameters: {
              'technical_id': user['id'].toString(),
              'proposal_id': proposal['id'].toString(),
            });

            final existProformaResponse = await http.get(existProformaUrl);
            if (existProformaResponse.statusCode == 200) {
              return '/start-repair';
            }
          }

          return '/sharing-location-screen';
        } else {
          // Manejo del error de la solicitud
          debugPrint('Error fetching sharing location: ${response.statusCode}');
        }

        return '/request-list';
      } else if (user['role'] == 'user') {
        return user['profile_photo'] == null ? '/upload-photo' : '/home';
      } else if (user['role'] == 'admin') {
        return '/dashboard';
      }
    }

    return '/login';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return FutureBuilder<String>(
          future: _getInitialRoute(authProvider),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              // Manejo de error
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final initialRoute = snapshot.data ?? '/login';

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: Provider.of<ThemeProvider>(context).themeData,
              initialRoute: initialRoute,
              routes: {
                '/home': (context) => const HomeScreen(),
                '/request-list': (context) => authProvider.isAuthenticated
                    ? const RequestListScreen()
                    : const LoginScreen(),
                '/sharing-location-screen': (context) =>
                    authProvider.isAuthenticated
                        ? const SharingLocationScreen()
                        : const LoginScreen(),
                '/start-repair': (context) => authProvider.isAuthenticated
                    ? const StartOfRepair()
                    : const LoginScreen(),
                '/dashboard': (context) => authProvider.isAuthenticated
                    ? const DashboardScreen()
                    : const LoginScreen(),
                '/login': (context) => const LoginScreen(),
                '/upload-photo': (context) => authProvider.isAuthenticated
                    ? const UploadPhoto()
                    : const LoginScreen(),
              },
            );
          },
        );
      },
    );
  }
}

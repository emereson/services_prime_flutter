import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tecnyapp_flutter/screen/admin/dashboard_screen.dart';
import 'package:tecnyapp_flutter/screen/auth/upload_photo.dart';
import 'package:tecnyapp_flutter/screen/userScreen/home_screen.dart';
import 'package:tecnyapp_flutter/screen/auth/login_screen.dart';
import 'package:tecnyapp_flutter/screen/technicalScreen/request_list_screen.dart';
import 'package:tecnyapp_flutter/screen/technicalScreen/sharing_location_screen.dart';
import 'package:tecnyapp_flutter/service/auth/user_data_service.dart';
import 'package:tecnyapp_flutter/themes/theme_provider.dart';
import 'package:tecnyapp_flutter/service/auth/auth_provider.dart';
import 'package:tecnyapp_flutter/utils/local_notifications.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Asegúrate de inicializar los bindings de Flutter

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

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return FutureBuilder(
          future: UserDataService.getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // Manejo del caso en que snapshot.data es nulo o no se puede decodificar
            final userData =
                snapshot.hasData ? jsonDecode(snapshot.data as String) : null;

            String initialRoute = '/login';

            if (authProvider.isAuthenticated && userData != null) {
              switch (userData['role']) {
                case 'technical':
                  initialRoute = '/request-list';
                  break;
                case 'user':
                  initialRoute = userData['profile_photo'] == null
                      ? '/upload-photo'
                      : '/home';
                  break;
                case 'admin':
                  initialRoute = '/dashboard';
                  break;
                default:
                  initialRoute = '/login';
              }
            }

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: Provider.of<ThemeProvider>(context).themeData,
              initialRoute: initialRoute,
              routes: {
                '/home': (context) => const HomeScreen(),
                '/request-list': (context) => authProvider.isAuthenticated
                    ? const RequestListScreen()
                    : const LoginScreen(),
                '/dashboard': (context) => authProvider.isAuthenticated
                    ? DashboardScreen(userData: userData)
                    : const LoginScreen(),
                '/login': (context) {
                  if (authProvider.isAuthenticated) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).pushReplacementNamed(initialRoute);
                    });
                    return const SizedBox
                        .shrink(); // Return an empty widget while redirecting
                  }
                  return const LoginScreen();
                },
                '/sharing-location/technical': (context) =>
                    authProvider.isAuthenticated
                        ? const SharingLocationScreen()
                        : const LoginScreen(),
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

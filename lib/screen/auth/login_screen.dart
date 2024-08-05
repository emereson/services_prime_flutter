import 'package:flutter/material.dart';
import 'package:tecnyapp_flutter/components/auth/login/log_in_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height, // Corregido
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 200,
                ),
                const SizedBox(height: 20),
                FractionallySizedBox(
                  widthFactor: 0.7,
                  child: Text(
                    "BIENVENIDO A SERVICIOS PRIME",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const LogInForm(), // Uso de const para optimización
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

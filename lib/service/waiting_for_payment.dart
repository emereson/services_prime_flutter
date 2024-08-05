import 'package:flutter/material.dart';

class WaitingForPayment extends StatelessWidget {
  const WaitingForPayment({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      top: 0,
      left: 0,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 150,
              ),
              const SizedBox(height: 20),
              const Text(
                'Esperando Pago',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

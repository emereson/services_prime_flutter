import 'package:flutter/material.dart';

class DashboardGridItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap; // Añadido para manejar la navegación

  const DashboardGridItem({
    super.key,
    required this.imagePath,
    required this.title,
    required this.onTap, // Añadido para manejar la navegación
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Navega a otra pantalla cuando se hace clic
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Image.asset(
                imagePath,
                height: 70,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

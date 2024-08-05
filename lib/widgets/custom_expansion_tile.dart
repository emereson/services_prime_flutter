import 'package:flutter/material.dart';

class CustomExpansionTile extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final List<Widget> children;
  final double marginHorizontal; // Cambiado a double

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.textColor,
    required this.children,
    required this.marginHorizontal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: marginHorizontal), // Usar marginHorizontal directamente
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          width: 1,
          color: backgroundColor,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        children: children,
      ),
    );
  }
}

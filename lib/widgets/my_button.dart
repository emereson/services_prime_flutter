import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  final Color colorButton;

  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.colorButton,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
            color: colorButton, borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
          ),
        ),
      ),
    );
  }
}

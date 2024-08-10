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
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        minimumSize: Size.zero,
        backgroundColor: colorButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 15,
          color: Theme.of(context).colorScheme.inverseSurface,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class DateSelector extends StatelessWidget {
  final String date;
  final String label;
  final IconData icon;
  final Function(String) onDateSelected;

  const DateSelector({
    super.key,
    required this.date,
    required this.label,
    required this.icon,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.parse(date),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          String formattedDate =
              "${pickedDate.toLocal().year}-${pickedDate.toLocal().month.toString().padLeft(2, '0')}-${pickedDate.toLocal().day.toString().padLeft(2, '0')}";
          onDateSelected(formattedDate);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.all(5.0),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: InputBorder.none,
          ),
          child: Text(date),
        ),
      ),
    );
  }
}

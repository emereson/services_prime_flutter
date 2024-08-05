import 'package:flutter/material.dart';
import 'package:tecnyapp_flutter/widgets/label_top.dart';
import 'package:tecnyapp_flutter/widgets/label_top_select.dart';

class FormSectionHome extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController dniController;
  final TextEditingController addressController;
  final String? selectedOption;
  final Function(String?) onChanged;
  final VoidCallback onMapButtonPressed;

  const FormSectionHome({
    super.key,
    required this.nameController,
    required this.dniController,
    required this.addressController,
    required this.selectedOption,
    required this.onChanged,
    required this.onMapButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        LabelTopSelect(
          label: 'Elegir Servicio',
          options: const [
            'Opción 1',
            'Opción 2',
            'Opción 3',
          ],
          selectedValue: selectedOption,
          onChanged: onChanged,
        ),
        const SizedBox(height: 10),
        LabelTop(
          controller: nameController,
          label: 'Nombre y Apellido',
          icon: Icons.person,
        ),
        const SizedBox(height: 10),
        LabelTop(
          controller: dniController,
          label: 'DNI',
          icon: Icons.document_scanner,
        ),
        const SizedBox(height: 20),
        LabelTop(
          controller: addressController,
          label: 'Dirección',
          icon: Icons.location_on,
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: onMapButtonPressed,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(
              Theme.of(context).colorScheme.tertiary,
            ),
            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          child: const Text(
            'Ver Mapa',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

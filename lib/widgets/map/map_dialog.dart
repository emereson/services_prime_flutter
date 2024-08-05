import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tecnyapp_flutter/components/home/map_widget.dart';

class MapDialog extends StatelessWidget {
  final LatLng initialPosition;
  final Function(LatLng) onLocationSelected;
  final Function() onSave;

  // ignore: use_super_parameters
  const MapDialog({
    Key? key,
    required this.initialPosition,
    required this.onLocationSelected,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 700,
        width: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: MapWidget(
                initialPosition: initialPosition,
                onLocationSelected: onLocationSelected,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onSave,
              child: Container(
                padding: const EdgeInsets.all(15),
                width: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Guardar Ubicación',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

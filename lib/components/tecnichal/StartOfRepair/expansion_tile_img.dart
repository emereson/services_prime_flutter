import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tecnyapp_flutter/config.dart';

class ExpansionTileImg extends StatelessWidget {
  final String title;
  final List<dynamic> images;
  final Function(int) pickImage;

  const ExpansionTileImg({
    super.key,
    required this.title,
    required this.images,
    required this.pickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.secondary,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        collapsedBackgroundColor: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        children: [
          const Text('Cargar Fotos'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
            child: const Text(
              'Haga clic para cargar o arrastre y suelte. Formato Soportado .jpg, .png',
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < images.length; i++)
                GestureDetector(
                  onTap: () => pickImage(i),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.tertiary,
                        width: 1,
                      ),
                    ),
                    child: images[i] != null
                        ? images[i] is File
                            ? Image.file(
                                images[i] as File,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                '${Config.imgUrl}/image/${images[i]}',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                        : const Icon(Icons.add),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tecnyapp_flutter/config.dart';

class ExpansionExistImg extends StatelessWidget {
  final String title;
  final List<String?> imageUrls;

  const ExpansionExistImg({
    super.key,
    required this.title,
    required this.imageUrls,
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
              for (int i = 0; i < imageUrls.length; i++)
                Container(
                  margin: const EdgeInsets.all(8),
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: MediaQuery.of(context).size.width * 0.2,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 1,
                    ),
                  ),
                  child: imageUrls[i] != null
                      ? Image.network(
                          '${Config.imgUrl}/image/${imageUrls[i]!}',
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: MediaQuery.of(context).size.width * 0.2,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.add),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

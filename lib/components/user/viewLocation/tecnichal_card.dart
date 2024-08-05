import 'package:flutter/material.dart';

class TecnichalCard extends StatefulWidget {
  final String imageUrl;
  final Map<String, dynamic> proposal;
  final Map<String, dynamic>? userData;

  const TecnichalCard({
    super.key,
    required this.proposal,
    required this.userData,
    required this.imageUrl,
  });

  @override
  State<TecnichalCard> createState() => _TecnichalCardState();
}

class _TecnichalCardState extends State<TecnichalCard> {
  late Map<String, dynamic> proposal;

  @override
  void initState() {
    super.initState();
    proposal = widget.proposal;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        border: Border.all(
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            height: 160,
            child: Center(
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 180,
                    color: Colors.grey,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 15),
          Container(
            alignment: Alignment.center,
            height: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tec. ${proposal['user']?['name']}',
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'telef. ${proposal['user']?['phone_number'] ?? ''}',
                ),
                const SizedBox(height: 2),
                Text(
                  'calif. ${proposal['user']?['stars']} estrellas',
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      's/.${proposal['cost_of_diagnosis']}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inverseSurface,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      proposal['time'] ?? 'N',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inverseSurface,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

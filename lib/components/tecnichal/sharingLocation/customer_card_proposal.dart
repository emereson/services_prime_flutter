import 'package:flutter/material.dart';

class CustomerCardProposal extends StatefulWidget {
  final String imageUrl;
  final Map<String, dynamic> proposal;
  final Map<String, dynamic>? userData;

  const CustomerCardProposal({
    super.key,
    required this.proposal,
    required this.userData,
    required this.imageUrl,
  });

  @override
  State<CustomerCardProposal> createState() => _CustomerCardProposalState();
}

class _CustomerCardProposalState extends State<CustomerCardProposal> {
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
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(10),
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
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      proposal['service_request']?['user']?['name'] ?? '',
                    ),
                    Text(
                      'telf. ${proposal['service_request']?['user']?['phone_number'] ?? ''}',
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  's', // Reemplaza 's' con datos válidos o define claramente qué debería mostrar
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  proposal['service_request']?['address'] ?? 'No Address',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  proposal['service_request']?['description'] ??
                      'No Description',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  proposal['service_request']?['status_request'] ?? '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
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
                      proposal['time'] ?? 'No Description',
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
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MontaggioScreen extends StatefulWidget {
  final double metriQuadri;

  const MontaggioScreen({super.key, required this.metriQuadri});

  @override
  State<MontaggioScreen> createState() => _MontaggioScreenState();
}

class _MontaggioScreenState extends State<MontaggioScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController prezzoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Montaggio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome del Montatore',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Mq dello stand: ${widget.metriQuadri.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: prezzoController,
              decoration: const InputDecoration(labelText: 'Prezzo Totale (€)'),
              keyboardType: TextInputType.number,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Aggiungi'),
                onPressed: () {
                  if (nomeController.text.isNotEmpty &&
                      prezzoController.text.isNotEmpty) {
                    final servizio = {
                      'tipo': 'Montaggio',
                      'descrizione': nomeController.text,
                      'quantita': widget.metriQuadri,
                      'prezzo': double.tryParse(prezzoController.text) ?? 0,
                    };
                    Navigator.pop(context, servizio);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

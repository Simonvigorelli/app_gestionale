import 'package:flutter/material.dart';

class ImpiantoElettricoScreen extends StatefulWidget {
  final double dimensioneStand;

  const ImpiantoElettricoScreen({super.key, required this.dimensioneStand});

  @override
  State<ImpiantoElettricoScreen> createState() =>
      _ImpiantoElettricoScreenState();
}

class _ImpiantoElettricoScreenState extends State<ImpiantoElettricoScreen> {
  final TextEditingController prezzoMqController = TextEditingController(
    text: '15',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Impianto Elettrico")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Dimensione Stand: ${widget.dimensioneStand} mq"),
            const SizedBox(height: 16),
            TextField(
              controller: prezzoMqController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Prezzo al Mq (€)"),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Aggiungi al Preventivo"),
              onPressed: () {
                final double prezzoMq =
                    double.tryParse(prezzoMqController.text) ?? 0;
                final double totale = prezzoMq * widget.dimensioneStand;

                Navigator.pop(context, {
                  'tipo': 'Impianto Elettrico',
                  'descrizione': 'Impianto su ${widget.dimensioneStand} mq',
                  'quantita': 1,
                  'prezzo': totale,
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

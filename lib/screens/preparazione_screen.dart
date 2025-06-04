import 'package:flutter/material.dart';

class PreparazioneScreen extends StatefulWidget {
  const PreparazioneScreen({super.key});

  @override
  State<PreparazioneScreen> createState() => _PreparazioneScreenState();
}

class _PreparazioneScreenState extends State<PreparazioneScreen> {
  final TextEditingController oreController = TextEditingController(text: '1');
  final TextEditingController prezzoController = TextEditingController(
    text: '25',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preparazione")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: oreController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Ore totali per la preparazione",
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: prezzoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Prezzo per ora (€)",
              ),
            ),
            const Spacer(),


            
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Aggiungi al Preventivo"),
              onPressed: () {
                final int ore = int.tryParse(oreController.text) ?? 0;
                final double prezzo =
                    double.tryParse(prezzoController.text) ?? 0;
                final totale = ore * prezzo;

                Navigator.pop(context, {
                  'tipo': 'Preparazione',
                  'descrizione': '$ore ore x ${prezzo.toStringAsFixed(2)}€',
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

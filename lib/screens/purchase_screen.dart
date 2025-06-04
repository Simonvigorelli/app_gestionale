import 'package:flutter/material.dart';

class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Piani disponibili')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Acquisto una tantum'),
                subtitle: const Text('Accesso illimitato all’app'),
                trailing: ElevatedButton(
                  onPressed: () {
                    // chiamata a in-app purchase per acquisto una tantum
                  },
                  child: const Text('Acquista'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                title: const Text('Abbonamento Mensile'),
                subtitle: const Text('Accesso completo, rinnovo mensile'),
                trailing: ElevatedButton(
                  onPressed: () {
                    // chiamata a in-app purchase per abbonamento
                  },
                  child: const Text('Abbonati'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Puoi scegliere se acquistare l’app una sola volta o abbonarti mensilmente.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

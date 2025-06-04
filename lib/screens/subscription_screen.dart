import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sblocca l\'App')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Scegli un piano per continuare a usare l\'app dopo la prova gratuita di 7 giorni.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Acquisto una tantum
            Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Acquisto una tantum'),
                subtitle: const Text('Accesso completo per sempre'),
                trailing: ElevatedButton(
                  onPressed: () {
                    // TODO: integra acquisto una tantum
                  },
                  child: const Text('Acquista'),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Abbonamento mensile
            Card(
              child: ListTile(
                leading: const Icon(Icons.refresh, color: Colors.blue),
                title: const Text('Abbonamento mensile'),
                subtitle: const Text(
                  'Accesso completo, disdici in qualsiasi momento',
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    // TODO: integra abbonamento
                  },
                  child: const Text('Abbonati'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

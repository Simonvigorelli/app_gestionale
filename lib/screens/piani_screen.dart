// screens/piani_screen.dart
import 'package:flutter/material.dart';

class PianiScreen extends StatelessWidget {
  const PianiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sblocca tutte le funzionalità")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPlanCard(
              context,
              title: "Abbonamento Mensile",
              price: "€2,99/mese",
              description: "Accesso illimitato a tutte le funzioni.",
              onPressed: () {
                // TODO: Avvia acquisto abbonamento mensile
              },
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              context,
              title: "Abbonamento Annuale",
              price: "€29,99/anno",
              description: "Risparmia oltre il 15% rispetto al mensile.",
              onPressed: () {
                // TODO: Avvia acquisto abbonamento annuale
              },
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              context,
              title: "Acquisto Una Tantum",
              price: "€49,99",
              description: "Paghi una sola volta, accesso a vita.",
              onPressed: () {
                // TODO: Avvia acquisto una tantum
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String description,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              price,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onPressed, child: const Text("Sblocca")),
          ],
        ),
      ),
    );
  }
}

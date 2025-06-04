// screens/purchase_plans_screen.dart
import 'package:flutter/material.dart';

class PurchasePlansScreen extends StatelessWidget {
  final VoidCallback onBuyOnce;
  final VoidCallback onSubscribe;

  const PurchasePlansScreen({
    super.key,
    required this.onBuyOnce,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sblocca StandApp")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Scegli il piano che preferisci per continuare a usare l'app dopo il periodo di prova.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
              child: ListTile(
                title: const Text("💳 Acquisto una tantum"),
                subtitle: const Text(
                  "Pagamento singolo per accesso illimitato all'app.",
                ),
                trailing: const Text("€19.99"),
                onTap: onBuyOnce,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
              child: ListTile(
                title: const Text("📆 Abbonamento mensile"),
                subtitle: const Text(
                  "Paghi solo €2.99/mese, puoi annullare in qualsiasi momento.",
                ),
                trailing: const Text("€2.99/mese"),
                onTap: onSubscribe,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

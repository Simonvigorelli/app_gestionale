import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'menu_screen.dart'; // Schermata principale della tua app
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Benvenuto su StandApp!",
          body:
              "Gestisci i tuoi prodotti, movimenti e preventivi in modo semplice.",
          image: const Icon(Icons.warehouse, size: 100),
        ),
        PageViewModel(
          title: "Magazzino",
          body: "Aggiungi, modifica o elimina prodotti e gestisci i movimenti.",
          image: const Icon(Icons.inventory_2, size: 100),
        ),
        PageViewModel(
          title: "Inizia ora!",
          body: "Tutto pronto per utilizzare l'app!",
          image: const Icon(Icons.check_circle, size: 100),
        ),
      ],
      onDone: () async {
        // Salva che l'onboarding è stato visto
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('seenOnboarding', true);

        // Vai alla schermata principale
        // Non c'è più bisogno di passare i parametri isDarkMode e onToggleTheme
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MenuScreen()),
        );
      },
      showSkipButton: true,
      skip: const Text("Salta"),
      next: const Icon(Icons.arrow_forward),
      done: const Text("Inizia", style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

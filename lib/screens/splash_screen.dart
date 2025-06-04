import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'menu_screen.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'payment_screen.dart';

import '../services/trial_service.dart';
import '../services/premium_service.dart';

class SplashScreen extends StatefulWidget {
  // Rimuovi questi parametri, non sono più necessari per la gestione automatica del tema
  // final bool isDarkMode;
  // final VoidCallback onToggleTheme;

  const SplashScreen({
    super.key,
    // Anche qui, rimuovi i 'required' per i parametri non più esistenti
    // required this.isDarkMode,
    // required this.onToggleTheme,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadInitialScreen();
  }

  Future<void> _loadInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    final aziendaId = prefs.getString('aziendaId');
    final offlineMode = prefs.getBool('offlineMode') ?? false;

    // 🔐 Controllo prova gratuita e acquisto premium
    final isTrial = await TrialService.isTrialActive();
    final isPremium = await PremiumService.isPremium();

    await Future.delayed(
      const Duration(milliseconds: 800),
    ); // animazione o caricamento breve

    if (!mounted) return;

    if (!isTrial && !isPremium) {
      // Prova scaduta e non è premium → reindirizza alla schermata pagamento
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PaymentScreen()),
      );
      return;
    }

    // Logica di navigazione normale
    Widget nextScreen;

    if (!seenOnboarding) {
      nextScreen = const OnboardingScreen();
    } else if (offlineMode ||
        (aziendaId != null && aziendaId.trim().isNotEmpty)) {
      // Non c'è più bisogno di passare i parametri isDarkMode e onToggleTheme
      nextScreen = const MenuScreen();
    } else {
      nextScreen = const LoginScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

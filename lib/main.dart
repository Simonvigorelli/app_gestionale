import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'models/product_model.dart';
import 'models/movement_model.dart';
import 'models/azienda_model.dart';
import 'models/cliente_model.dart';
import 'models/grafica_model.dart';
import 'models/preventivo_model.dart';

import 'screens/menu_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/payment_screen.dart';
import 'services/trial_service.dart';
import 'services/premium_service.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();

  Hive.registerAdapter(ProductModelAdapter());
  Hive.registerAdapter(MovementModelAdapter());
  Hive.registerAdapter(AziendaModelAdapter());
  Hive.registerAdapter(ClienteModelAdapter());
  Hive.registerAdapter(GraficaModelAdapter());
  Hive.registerAdapter(PreventivoModelAdapter());

  await Hive.openBox<ProductModel>('products');
  await Hive.openBox<MovementModel>('movements');
  await Hive.openBox<AziendaModel>('aziende');
  await Hive.openBox<ClienteModel>('clienti');
  await Hive.openBox<GraficaModel>('grafiche');
  await Hive.openBox<PreventivoModel>('preventivi');

  await TrialService.initializeTrial();

  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  final aziendaId = prefs.getString('aziendaId');
  final offlineMode = prefs.getBool('offlineMode') ?? false;

  final isTrialActive = await TrialService.isTrialActive();
  final isPremium = await PremiumService.isPremium();

  runApp(
    MyApp(
      showOnboarding: !seenOnboarding,
      aziendaId: aziendaId,
      offlineMode: offlineMode,
      isTrialActive: isTrialActive,
      isPremium: isPremium,
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool showOnboarding;
  final String? aziendaId;
  final bool offlineMode;
  final bool isTrialActive;
  final bool isPremium;

  const MyApp({
    super.key,
    required this.showOnboarding,
    required this.aziendaId,
    required this.offlineMode,
    required this.isTrialActive,
    required this.isPremium,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // homeScreen non è più late, ma verrà inizializzata nel build
  // o gestita tramite un widget iniziale che si occupa del routing
  // in base alle condizioni.

  @override
  void initState() {
    super.initState();
    // La logica di navigazione e showDialog va spostata in un punto
    // dove il contesto (BuildContext) è valido e ha un MaterialApp come antenato.
    // useremo un `Builder` nel `home` del MaterialApp.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StandApp',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      // Usiamo un Builder come home per avere un BuildContext che contiene MaterialApp
      home: Builder(
        builder: (context) {
          // La logica per decidere la schermata iniziale
          Widget initialScreen;
          if (widget.showOnboarding) {
            initialScreen = const OnboardingScreen();
          } else if (widget.aziendaId != null && widget.aziendaId!.isNotEmpty) {
            initialScreen = MenuScreen();
          } else if (widget.offlineMode) {
            initialScreen = MenuScreen();
          } else {
            initialScreen = const LoginScreen();
          }

          // Esegui la logica di showDialog/navigazione dopo il rendering iniziale
          // Questo è il modo corretto per farlo dopo che il widget è stato costruito.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.isTrialActive && !widget.isPremium) {
              TrialService.getTrialExpirationDate().then((expiration) {
                if (mounted) {
                  showDialog(
                    context: context, // Ora il context è valido!
                    barrierDismissible: false,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text("Prova gratuita attiva"),
                      content: Text(
                        "Hai una prova gratuita attiva fino al $expiration. "
                        "Dopo sarà necessario acquistare per continuare a usare l'app.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text("Chiudi"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            Navigator.push(
                              context, // Ora il context è valido!
                              MaterialPageRoute(
                                builder: (_) => const PaymentScreen(),
                              ),
                            );
                          },
                          child: const Text("Acquista ora"),
                        ),
                      ],
                    ),
                  );
                }
              });
            } else if (!widget.isTrialActive && !widget.isPremium) {
              if (mounted) {
                // Controllo se non siamo già sulla PaymentScreen per evitare loop infiniti
                if (ModalRoute.of(context)?.settings.name != '/payment') {
                   Navigator.pushAndRemoveUntil(
                    context, // Ora il context è valido!
                    MaterialPageRoute(
                        builder: (_) => const PaymentScreen(),
                        settings: const RouteSettings(name: '/payment')), // Aggiungi un nome alla rotta
                    (_) => false,
                  );
                }
              }
            }
          });

          return initialScreen;
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'products_screen.dart';
import 'movement_screen.dart'; // Assicurati che questo sia il tuo file per la schermata Movimenti
import 'preventivi_screen.dart';
import 'calcolo_assorbimento_screen.dart';
import 'package:app_gestionale/calcolo_assorbimento/transformer_list_screen.dart';
import 'login_screen.dart';
import 'package:app_gestionale/services/trial_service.dart';
import 'package:app_gestionale/services/premium_service.dart';

class MenuScreen extends StatefulWidget {
  // Rimuovi i parametri, non sono più necessari
  const MenuScreen({
    super.key,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool offlineMode = false;
  String? aziendaId;
  String? nomeAzienda;
  bool showPreventivi = false;
  bool isTrialActive = false;
  bool isPremium = false;
  int giorniRimanenti = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    offlineMode = prefs.getBool('offlineMode') ?? false;
    aziendaId = prefs.getString('aziendaId');
    showPreventivi = prefs.getBool('showPreventivi') ?? false;

    isTrialActive = await TrialService.isTrialActive();
    isPremium = await PremiumService.isPremium();

    if (isTrialActive && !isPremium) {
      final expirationStr = await TrialService.getTrialExpirationDate();
      final expiration = DateTime.tryParse(expirationStr) ?? DateTime.now();
      final now = DateTime.now();
      giorniRimanenti = expiration.difference(now).inDays;
      if (giorniRimanenti < 0) giorniRimanenti = 0;
    }

    if (!offlineMode && aziendaId != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('aziende')
            .doc(aziendaId)
            .get();
        if (mounted) {
          setState(() {
            nomeAzienda = doc.data()?['nomeAzienda'] ?? 'Azienda';
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            nomeAzienda = 'Errore caricamento azienda'; // Gestione errore
          });
        }
        print("Errore nel caricamento del nome azienda: $e");
      }
    } else {
      if (mounted) {
        setState(() {
          nomeAzienda = 'Modalità offline';
        });
      }
    }
    // Assicurati che la UI si aggiorni dopo il caricamento di tutte le impostazioni
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('aziendaId');
    await prefs.setBool('offlineMode', false);

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _apriImpostazioni() async {
    final prefs = await SharedPreferences.getInstance();
    bool nuovoValorePreventivi = showPreventivi;

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog( // Usa dialogContext per il Navigator.pop
        title: const Text('Impostazioni'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Mostra sezione Preventivi'),
                  value: nuovoValorePreventivi,
                  onChanged: (val) => setState(() => nuovoValorePreventivi = val),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            child: const Text('Annulla'),
            onPressed: () => Navigator.pop(dialogContext), // Usa dialogContext
          ),
          ElevatedButton(
            child: const Text('Salva'),
            onPressed: () async {
              await prefs.setBool('showPreventivi', nuovoValorePreventivi);
              if (mounted) {
                setState(() {
                  showPreventivi = nuovoValorePreventivi;
                });
              }
              Navigator.pop(dialogContext); // Usa dialogContext
            },
          ),
        ],
      ),
    );
  }

  // Funzione helper per creare i pulsanti con icone consistenti
  Widget _buildMenuButton(IconData icon, String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: ElevatedButton.icon(
          icon: Icon(icon, size: 28), // Dimensione maggiore per le icone principali
          label: Text(label, style: const TextStyle(fontSize: 18)),
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: const Size(250, 70), // Dimensione fissa per i pulsanti
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Bordi arrotondati
            ),
            elevation: 5, // Ombra leggera
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'STAND-APP',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (nomeAzienda != null)
              Text(nomeAzienda!, style: const TextStyle(fontSize: 14)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), // Icona per le impostazioni
            tooltip: 'Impostazioni',
            onPressed: _apriImpostazioni,
          ),
          IconButton(
            icon: const Icon(Icons.logout), // Icona per il logout
            tooltip: 'Logout / Cambia azienda',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildMenuButton(Icons.inventory_2, 'Archivio Prodotti', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductsScreen()),
              );
            }),
            _buildMenuButton(Icons.electrical_services, 'Calcolo Assorbimento', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CalcoloAssorbimentoScreen(),
                ),
              );
            }),
            _buildMenuButton(Icons.settings_input_component, 'Gestione Trasformatori', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TransformerListScreen()),
              );
            }),
            _buildMenuButton(Icons.warehouse, 'Movimenti Magazzino', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MovementsScreen()),
              );
            }),
            if (showPreventivi)
              _buildMenuButton(Icons.receipt_long, 'Preventivi', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PreventiviScreen()),
                );
              }),
            const SizedBox(height: 30),
            if (isTrialActive && !isPremium)
              Text(
                'Giorni rimanenti di prova: $giorniRimanenti',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.redAccent,
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
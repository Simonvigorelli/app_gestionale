import 'package:app_gestionale/screens/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _aziendaController = TextEditingController();
  final TextEditingController _codiceController = TextEditingController();
  final TextEditingController _passwordAdminController =
      TextEditingController();
  bool isCreatingNew = false;

  Future<void> _loginOrRegister() async {
    final azienda = _aziendaController.text.trim();
    final codice = _codiceController.text.trim();

    if (azienda.isEmpty || codice.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inserisci nome azienda e codice di 6 cifre'),
        ),
      );
      return;
    }

    try {
      final aziendaRef = FirebaseFirestore.instance
          .collection('aziende')
          .doc(codice);
      final doc = await aziendaRef.get();

      if (isCreatingNew) {
        if (doc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Codice già esistente. Usa un altro codice.'),
            ),
          );
          return;
        }

        await aziendaRef.set({
          'nomeAzienda': azienda,
          'passwordAmministratore': _passwordAdminController.text.trim(),
        });

        await _saveAziendaId(codice);

        // Non c'è più bisogno di passare i parametri isDarkMode e onToggleTheme
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MenuScreen()),
          );
        }
      } else {
        if (!doc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Azienda non trovata. Verifica nome e codice.'),
            ),
          );
          return;
        }

        await _saveAziendaId(codice);

        // Non c'è più bisogno di passare i parametri isDarkMode e onToggleTheme
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MenuScreen()),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Errore di connessione o configurazione: ${e.toString()}',
          ),
        ),
      );
    }
  }

  Future<void> _saveAziendaId(String aziendaId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('aziendaId', aziendaId);
    await prefs.setBool('offlineMode', false);
  }

  Future<void> _usaSoloLocale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('aziendaId');
    await prefs.setBool('offlineMode', true);

    // Non c'è più bisogno di passare i parametri isDarkMode e onToggleTheme
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MenuScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isCreatingNew ? 'Crea Nuova Azienda' : 'Login Azienda'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          tooltip: 'Torna alla home',
          onPressed: () {
            // Non c'è più bisogno di passare i parametri isDarkMode e onToggleTheme
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MenuScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _aziendaController,
              decoration: const InputDecoration(labelText: 'Nome Azienda'),
            ),
            TextField(
              controller: _codiceController,
              decoration: const InputDecoration(
                labelText: 'Codice Azienda (6 cifre)',
              ),
              keyboardType: TextInputType.number,
            ),
            if (isCreatingNew)
              TextField(
                controller: _passwordAdminController,
                decoration: const InputDecoration(
                  labelText: 'Password Amministratore',
                ),
                obscureText: true,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginOrRegister,
              child: Text(isCreatingNew ? 'Crea Azienda' : 'Accedi'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                setState(() {
                  isCreatingNew = !isCreatingNew;
                });
              },
              child: Text(
                isCreatingNew
                    ? 'Hai già un\'azienda? Torna al Login'
                    : 'Crea una nuova azienda',
              ),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text('Usa solo in locale (senza registrazione)'),
              onPressed: _usaSoloLocale,
            ),
          ],
        ),
      ),
    );
  }
}

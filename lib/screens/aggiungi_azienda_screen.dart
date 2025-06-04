import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/azienda_model.dart';

class AggiungiAziendaScreen extends StatefulWidget {
  const AggiungiAziendaScreen({super.key});

  @override
  State<AggiungiAziendaScreen> createState() => _AggiungiAziendaScreenState();
}

class _AggiungiAziendaScreenState extends State<AggiungiAziendaScreen> {
  final nomeController = TextEditingController();
  final indirizzoController = TextEditingController();
  final telefonoController = TextEditingController();
  final emailController = TextEditingController();
  final pivaController = TextEditingController();
  final ibanController = TextEditingController();
  final codiceUnivocoController = TextEditingController();

  String? logoPath;
  String? firmaPath;

  late Box<AziendaModel> aziendaBox;

  @override
  void initState() {
    super.initState();
    aziendaBox = Hive.box<AziendaModel>('aziende');
  }

  Future<void> pickLogo() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => logoPath = image.path);
    }
  }

  Future<void> pickFirma() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => firmaPath = image.path);
    }
  }

  void _salvaAzienda() {
    if (logoPath == null || firmaPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Carica sia logo che firma")),
      );
      return;
    }

    final nuovaAzienda = AziendaModel(
      nome: nomeController.text,
      indirizzo: indirizzoController.text,
      telefono: telefonoController.text,
      email: emailController.text,
      piva: pivaController.text,
      iban: ibanController.text,
      codiceUnivoco: codiceUnivocoController.text,
      logoPath: logoPath!,
      firmaPath: firmaPath!,
    );

    aziendaBox.add(nuovaAzienda);
    setState(() {});
    Navigator.pop(context);
  }

  void _eliminaAzienda(int index) {
    aziendaBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final aziende = aziendaBox.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Nuova Azienda')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: indirizzoController,
              decoration: const InputDecoration(labelText: 'Indirizzo'),
            ),
            TextField(
              controller: telefonoController,
              decoration: const InputDecoration(labelText: 'Telefono'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: pivaController,
              decoration: const InputDecoration(labelText: 'P. IVA'),
            ),
            TextField(
              controller: ibanController,
              decoration: const InputDecoration(labelText: 'IBAN'),
            ),
            TextField(
              controller: codiceUnivocoController,
              decoration: const InputDecoration(labelText: 'Codice Univoco'),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text("Carica Logo"),
              onPressed: pickLogo,
            ),
            if (logoPath != null)
              Column(
                children: [
                  const SizedBox(height: 8),
                  const Text("Logo selezionato:"),
                  Image.file(File(logoPath!), height: 100),
                ],
              ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text("Carica Firma"),
              onPressed: pickFirma,
            ),
            if (firmaPath != null)
              Column(
                children: [
                  const SizedBox(height: 8),
                  const Text("Firma selezionata:"),
                  Image.file(File(firmaPath!), height: 80),
                ],
              ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _salvaAzienda,
              child: const Text('Salva'),
            ),

            const Divider(height: 40),
            const Text(
              "Aziende salvate",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ...List.generate(aziende.length, (index) {
              final azienda = aziende[index];
              return Card(
                child: ListTile(
                  title: Text(azienda.nome),
                  subtitle: Text('${azienda.indirizzo} • ${azienda.email}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _eliminaAzienda(index),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

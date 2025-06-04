import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';

class ArchivioProdottiScreen extends StatefulWidget {
  const ArchivioProdottiScreen({super.key});

  @override
  State<ArchivioProdottiScreen> createState() => _ArchivioProdottiScreenState();
}

class _ArchivioProdottiScreenState extends State<ArchivioProdottiScreen> {
  final codeController = TextEditingController();
  final descriptionController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  Future<void> aggiungiProdotto() async {
    final box = Hive.box<ProductModel>('products');
    final codice = codeController.text.trim();

    final esiste = box.values.any((p) => p.code == codice);
    if (esiste) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Codice già esistente!")));
      return;
    }

    final nuovo = ProductModel(
      code: codice,
      description: descriptionController.text.trim(),
      quantity: int.tryParse(quantityController.text) ?? 0,
      price: double.tryParse(priceController.text) ?? 0,
      qrCode: const Uuid().v4(), // ✅ aggiunto
    );

    await box.add(nuovo);
    setState(() {});
  }

  Future<void> esportaCSV() async {
    final box = Hive.box<ProductModel>('products');
    final prodotti = box.values.toList();

    List<List<dynamic>> rows = [
      ['Codice', 'Descrizione', 'Quantità', 'Prezzo'],
      ...prodotti.map((p) => [p.code, p.description, p.quantity, p.price]),
    ];

    String csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/prodotti_export.csv');
    await file.writeAsString(csv);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("✅ Esportato: ${file.path}")));
  }

  Future<void> importaCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      final input = File(result.files.single.path!).readAsStringSync();
      final rows = const CsvToListConverter().convert(input, eol: '\n');

      if (rows.first.join(',') != "Codice,Descrizione,Quantità,Prezzo") {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text("Formato non valido"),
                content: const Text(
                  "Il file CSV deve avere queste intestazioni:\n"
                  "Codice,Descrizione,Quantità,Prezzo\n"
                  "Esempio: P001,Prodotto 1,10,5.99",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
        return;
      }

      final box = Hive.box<ProductModel>('products');
      for (var i = 1; i < rows.length; i++) {
        final r = rows[i];
        final codice = r[0].toString();
        if (box.values.any((p) => p.code == codice)) continue;

        box.add(
          ProductModel(
            code: codice,
            description: r[1].toString(),
            quantity: int.tryParse(r[2].toString()) ?? 0,
            price: double.tryParse(r[3].toString()) ?? 0.0,
            qrCode: const Uuid().v4(), // ✅ aggiunto
          ),
        );
      }

      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Prodotti importati correttamente")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Archivio Prodotti"),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: "Importa CSV",
            onPressed: importaCSV,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: "Esporta CSV",
            onPressed: esportaCSV,
          ),
        ],
      ),
      // Resto della UI...
    );
  }
}

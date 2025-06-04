import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models.dart';

class TransformerListScreen extends StatefulWidget {
  const TransformerListScreen({super.key});

  @override
  _TransformerListScreenState createState() => _TransformerListScreenState();
}

class _TransformerListScreenState extends State<TransformerListScreen> {
  List<TransformerModel> transformers = [];

  @override
  void initState() {
    super.initState();
    _loadTransformers();
  }

  Future<void> _loadTransformers() async {
    final prefs = await SharedPreferences.getInstance();
    final transStr = prefs.getString('transformers_data');
    if (transStr != null) {
      final decodeTransf = jsonDecode(transStr) as List;
      setState(() {
        transformers =
            decodeTransf.map((m) => TransformerModel.fromJson(m)).toList();
      });
    }
  }

  Future<void> _saveTransformers() async {
    final prefs = await SharedPreferences.getInstance();
    final transfJson = jsonEncode(transformers.map((t) => t.toJson()).toList());
    await prefs.setString('transformers_data', transfJson);
  }

  void _addTransformerDialog() {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController inputVoltageCtrl = TextEditingController();
    TextEditingController inputCurrentCtrl = TextEditingController();
    TextEditingController frequencyCtrl = TextEditingController();
    TextEditingController outputVoltageCtrl = TextEditingController();
    TextEditingController outputCurrentCtrl = TextEditingController();
    TextEditingController outputPowerCtrl = TextEditingController();
    TextEditingController efficiencyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Nuovo Trasformatore"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: "Nome Trasformatore"),
                ),
                TextField(
                  controller: inputVoltageCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: "Tensione di Ingresso (V AC)",
                  ),
                ),
                TextField(
                  controller: inputCurrentCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: "Corrente di Ingresso (A)",
                  ),
                ),
                TextField(
                  controller: frequencyCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: "Frequenza (Hz)"),
                ),
                TextField(
                  controller: outputVoltageCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: "Tensione di Uscita (V DC)",
                  ),
                ),
                TextField(
                  controller: outputCurrentCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: "Corrente di Uscita (A)",
                  ),
                ),
                TextField(
                  controller: outputPowerCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: "Potenza di Uscita (W)",
                  ),
                ),
                TextField(
                  controller: efficiencyCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: "Efficienza (%)"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Annulla"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Aggiungi"),
              onPressed: () {
                if (nameCtrl.text.isNotEmpty &&
                    inputVoltageCtrl.text.isNotEmpty &&
                    inputCurrentCtrl.text.isNotEmpty &&
                    frequencyCtrl.text.isNotEmpty &&
                    outputVoltageCtrl.text.isNotEmpty &&
                    outputCurrentCtrl.text.isNotEmpty &&
                    outputPowerCtrl.text.isNotEmpty &&
                    efficiencyCtrl.text.isNotEmpty) {
                  final newTransformer = TransformerModel(
                    name: nameCtrl.text,
                    inputVoltage: inputVoltageCtrl.text,
                    inputCurrent: double.tryParse(inputCurrentCtrl.text) ?? 0,
                    frequency: frequencyCtrl.text,
                    outputVoltage: double.tryParse(outputVoltageCtrl.text) ?? 0,
                    outputCurrent: double.tryParse(outputCurrentCtrl.text) ?? 0,
                    outputPower: double.tryParse(outputPowerCtrl.text) ?? 0,
                    efficiency: double.tryParse(efficiencyCtrl.text) ?? 0,
                  );

                  setState(() {
                    transformers.add(newTransformer);
                  });

                  _saveTransformers().then((_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransformerListScreen(),
                      ),
                    );
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _removeTransformer(int index) {
    setState(() {
      transformers.removeAt(index);
      _saveTransformers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestione Trasformatori")),
      body:
          transformers.isEmpty
              ? Center(child: Text("Nessun trasformatore presente."))
              : ListView.builder(
                itemCount: transformers.length,
                itemBuilder: (ctx, i) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      title: Text(transformers[i].name),
                      subtitle: Text(
                        "Potenza: ${transformers[i].outputPower}W - Supporta: ${transformers[i].maxMeters.toStringAsFixed(1)} metri LED",
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeTransformer(i),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_transformer", // ✅ aggiunto tag univoco
        onPressed: _addTransformerDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

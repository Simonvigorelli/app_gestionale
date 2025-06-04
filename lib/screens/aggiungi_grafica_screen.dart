import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/grafica_model.dart';

class AggiungiGraficaScreen extends StatefulWidget {
  const AggiungiGraficaScreen({super.key});

  @override
  State<AggiungiGraficaScreen> createState() => _AggiungiGraficaScreenState();
}

class _AggiungiGraficaScreenState extends State<AggiungiGraficaScreen> {
  final codiceController = TextEditingController();
  final descrizioneController = TextEditingController();
  final prezzoController = TextEditingController();
  bool alMq = true;

  Box<GraficaModel> get graficaBox => Hive.box<GraficaModel>('grafiche');

  void _salvaGrafica() {
    if (codiceController.text.isNotEmpty && prezzoController.text.isNotEmpty) {
      final nuova = GraficaModel(
        codice: codiceController.text,
        descrizione: descrizioneController.text,
        prezzo: double.tryParse(prezzoController.text) ?? 0,
        tipoPrezzo: alMq ? 'mq' : 'pezzo',
      );

      graficaBox.add(nuova);
      codiceController.clear();
      descrizioneController.clear();
      prezzoController.clear();
      setState(() {});
    }
  }

  void _eliminaGrafica(int index) {
    graficaBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestione Grafiche')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: codiceController,
              decoration: const InputDecoration(labelText: 'Codice'),
            ),
            TextField(
              controller: descrizioneController,
              decoration: const InputDecoration(labelText: 'Descrizione'),
            ),
            TextField(
              controller: prezzoController,
              decoration: InputDecoration(
                labelText: alMq ? 'Prezzo al mq' : 'Prezzo al pezzo',
                suffixText: alMq ? '€/mq' : '€/cad',
              ),
              keyboardType: TextInputType.number,
            ),
            SwitchListTile(
              title: const Text("Prezzo al metro quadro"),
              value: alMq,
              onChanged: (v) => setState(() => alMq = v),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _salvaGrafica,
              child: const Text('Salva'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const Text(
              "Grafiche Salvate",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: graficaBox.listenable(),
                builder: (context, Box<GraficaModel> box, _) {
                  final grafiche = box.values.toList();
                  if (grafiche.isEmpty) {
                    return const Text("Nessuna grafica salvata");
                  }

                  return ListView.builder(
                    itemCount: grafiche.length,
                    itemBuilder: (context, index) {
                      final g = grafiche[index];
                      return ListTile(
                        title: Text('${g.codice} - ${g.descrizione}'),
                        subtitle: Text(
                          'Prezzo: € ${g.prezzo.toStringAsFixed(2)} (${g.tipoPrezzo})',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminaGrafica(index),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

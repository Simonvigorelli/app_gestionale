import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/grafica_model.dart';
import 'aggiungi_grafica_screen.dart';

class GraficaScreen extends StatefulWidget {
  const GraficaScreen({super.key});

  @override
  State<GraficaScreen> createState() => _GraficaScreenState();
}

class _GraficaScreenState extends State<GraficaScreen> {
  GraficaModel? graficaSelezionata;

  final quantitaController = TextEditingController(text: '1');
  final larghezzaController = TextEditingController();
  final altezzaController = TextEditingController();

  double calcolaPrezzoTotale() {
    if (graficaSelezionata == null) return 0;

    final prezzo = graficaSelezionata!.prezzo;
    final tipo = graficaSelezionata!.tipoPrezzo;

    if (tipo == 'mq') {
      final larghezza = double.tryParse(larghezzaController.text) ?? 0;
      final altezza = double.tryParse(altezzaController.text) ?? 0;
      return larghezza * altezza * prezzo;
    } else {
      final quantita = int.tryParse(quantitaController.text) ?? 1;
      return quantita * prezzo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<GraficaModel>('grafiche');

    return Scaffold(
      appBar: AppBar(title: const Text('Grafica')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: box.listenable(),
                    builder: (context, Box<GraficaModel> box, _) {
                      final lista = box.values.toList();
                      return DropdownButtonFormField<GraficaModel>(
                        isExpanded: true,
                        hint: const Text('Tipo di Grafica'),
                        value: graficaSelezionata,
                        onChanged: (val) {
                          setState(() {
                            graficaSelezionata = val;
                          });
                        },
                        items:
                            lista.map((g) {
                              return DropdownMenuItem(
                                value: g,
                                child: Text(g.codice),
                              );
                            }).toList(),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AggiungiGraficaScreen(),
                      ),
                    );
                    setState(() {});
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (graficaSelezionata != null &&
                graficaSelezionata!.tipoPrezzo == 'mq') ...[
              TextField(
                controller: larghezzaController,
                decoration: const InputDecoration(labelText: 'Larghezza (m)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: altezzaController,
                decoration: const InputDecoration(labelText: 'Altezza (m)'),
                keyboardType: TextInputType.number,
              ),
            ] else if (graficaSelezionata != null &&
                graficaSelezionata!.tipoPrezzo == 'pezzo') ...[
              TextField(
                controller: quantitaController,
                decoration: const InputDecoration(labelText: 'Quantità'),
                keyboardType: TextInputType.number,
              ),
            ],

            const SizedBox(height: 24),
            Text(
              "Totale: € ${calcolaPrezzoTotale().toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18),
            ),

            const Spacer(),

            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Aggiungi al Preventivo"),
              onPressed: () {
                if (graficaSelezionata == null) return;

                int quantita =
                    graficaSelezionata!.tipoPrezzo == 'pezzo'
                        ? int.tryParse(quantitaController.text) ?? 1
                        : 1;

                final servizio = {
                  'tipo': graficaSelezionata!.codice,
                  'descrizione': graficaSelezionata!.descrizione,
                  'quantita': quantita,
                  'prezzo': calcolaPrezzoTotale(),
                };

                Navigator.pop(context, servizio);
              },
            ),
          ],
        ),
      ),
    );
  }
}

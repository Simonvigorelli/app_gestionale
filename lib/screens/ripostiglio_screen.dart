import 'package:flutter/material.dart';

class RipostiglioScreen extends StatefulWidget {
  const RipostiglioScreen({super.key});

  @override
  State<RipostiglioScreen> createState() => _RipostiglioScreenState();
}

class _RipostiglioScreenState extends State<RipostiglioScreen> {
  final prezzoMqController = TextEditingController(text: '35');
  final lunghezzaController = TextEditingController();
  final larghezzaController = TextEditingController();

  bool frigo = false;
  bool ripiani = false;
  bool cestini = false;
  bool appendiabiti = false;
  bool altro = false;

  final frigoPrezzoController = TextEditingController();
  final ripianiPrezzoController = TextEditingController();
  final cestiniPrezzoController = TextEditingController();
  final appendiabitiPrezzoController = TextEditingController();
  final altroPrezzoController = TextEditingController();
  final altroDescrizioneController = TextEditingController();

  double calcolaMq() {
    final lunghezza = double.tryParse(lunghezzaController.text) ?? 0;
    final larghezza = double.tryParse(larghezzaController.text) ?? 0;
    return lunghezza * larghezza;
  }

  double calcolaTotale() {
    double mq = calcolaMq();
    double prezzoBase = mq * (double.tryParse(prezzoMqController.text) ?? 0);

    double extra = 0;
    if (frigo) extra += double.tryParse(frigoPrezzoController.text) ?? 0;
    if (ripiani) extra += double.tryParse(ripianiPrezzoController.text) ?? 0;
    if (cestini) extra += double.tryParse(cestiniPrezzoController.text) ?? 0;
    if (appendiabiti) {
      extra += double.tryParse(appendiabitiPrezzoController.text) ?? 0;
    }
    if (altro) extra += double.tryParse(altroPrezzoController.text) ?? 0;

    return prezzoBase + extra;
  }

  @override
  Widget build(BuildContext context) {
    double mq = calcolaMq();

    return Scaffold(
      appBar: AppBar(title: const Text("Ripostiglio")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Prezzo del ripostiglio al mq:"),
            TextField(
              controller: prezzoMqController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(suffixText: "€/mq"),
            ),
            const SizedBox(height: 12),
            const Text("Dimensione ripostiglio:"),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: lunghezzaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Lunghezza (m)",
                      suffixText: "m",
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: larghezzaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Larghezza (m)",
                      suffixText: "m",
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text("Mq calcolati: ${mq.toStringAsFixed(2)}"),
            const Divider(height: 32),

            // Checkbox e prezzi extra
            CheckboxListTile(
              value: frigo,
              onChanged: (v) => setState(() => frigo = v ?? false),
              title: const Text("Frigo"),
              secondary: SizedBox(
                width: 100,
                child: TextField(
                  controller: frigoPrezzoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(suffixText: "€"),
                ),
              ),
            ),
            CheckboxListTile(
              value: ripiani,
              onChanged: (v) => setState(() => ripiani = v ?? false),
              title: const Text("Ripiani"),
              secondary: SizedBox(
                width: 100,
                child: TextField(
                  controller: ripianiPrezzoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(suffixText: "€"),
                ),
              ),
            ),
            CheckboxListTile(
              value: cestini,
              onChanged: (v) => setState(() => cestini = v ?? false),
              title: const Text("Cestini"),
              secondary: SizedBox(
                width: 100,
                child: TextField(
                  controller: cestiniPrezzoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(suffixText: "€"),
                ),
              ),
            ),
            CheckboxListTile(
              value: appendiabiti,
              onChanged: (v) => setState(() => appendiabiti = v ?? false),
              title: const Text("Appendiabiti"),
              secondary: SizedBox(
                width: 100,
                child: TextField(
                  controller: appendiabitiPrezzoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(suffixText: "€"),
                ),
              ),
            ),
            CheckboxListTile(
              value: altro,
              onChanged: (v) => setState(() => altro = v ?? false),
              title: Row(
                children: [
                  const Text("Altro:"),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: altroDescrizioneController,
                      decoration: const InputDecoration(
                        hintText: "Descrizione",
                      ),
                    ),
                  ),
                ],
              ),
              secondary: SizedBox(
                width: 100,
                child: TextField(
                  controller: altroPrezzoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(suffixText: "€"),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              "Totale: € ${calcolaTotale().toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("AGGIUNGI"),
              onPressed: () {
                double mq = calcolaMq();
                double prezzoMq = double.tryParse(prezzoMqController.text) ?? 0;
                double totale = calcolaTotale();

                List<String> descrizioni = [];
                if (frigo) descrizioni.add("Frigo");
                if (ripiani) descrizioni.add("Ripiani");
                if (cestini) descrizioni.add("Cestini");
                if (appendiabiti) descrizioni.add("Appendiabiti");
                if (altro) {
                  final d = altroDescrizioneController.text.trim();
                  if (d.isNotEmpty) descrizioni.add(d);
                }

                String descrizione =
                    descrizioni.isEmpty
                        ? "Ripostiglio ${mq.toStringAsFixed(2)} mq"
                        : "Ripostiglio ${mq.toStringAsFixed(2)} mq con ${descrizioni.join(", ")}";

                Navigator.pop(context, {
                  'tipo': 'Ripostiglio',
                  'descrizione': descrizione,
                  'quantita': 1,
                  'prezzo': totale,
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

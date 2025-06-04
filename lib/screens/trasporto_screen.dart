import 'package:flutter/material.dart';

class TrasportoScreen extends StatefulWidget {
  const TrasportoScreen({super.key});

  @override
  State<TrasportoScreen> createState() => _TrasportoScreenState();
}

class _TrasportoScreenState extends State<TrasportoScreen> {
  final TextEditingController nomeCorriereController = TextEditingController();
  final TextEditingController daLocalitaController = TextEditingController();
  final TextEditingController aLocalitaController = TextEditingController();
  final TextEditingController prezzoTrasportoController =
      TextEditingController();
  final TextEditingController prezzoScaricoController = TextEditingController();
  final TextEditingController prezzoRicaricoController =
      TextEditingController();

  bool andataRitorno = false;
  bool caricoMano = false;

  void salvaEDisponi() {
    double trasporto = double.tryParse(prezzoTrasportoController.text) ?? 0;
    double scarico = double.tryParse(prezzoScaricoController.text) ?? 0;
    double ricarico = double.tryParse(prezzoRicaricoController.text) ?? 0;

    if (andataRitorno) trasporto *= 2;
    if (caricoMano) {
      scarico = 0;
      ricarico = 0;
    }

    double totale = trasporto + scarico + ricarico;

    String descrizione = "Trasporto: ${nomeCorriereController.text}";
    descrizione +=
        "\nDa: ${daLocalitaController.text} → ${aLocalitaController.text}";

    if (caricoMano) {
      descrizione += "\nScarico e Ricarico a mano";
    } else {
      descrizione += "\nScarico e Ricarico con carrello";
    }

    final servizio = {
      'tipo': 'Trasporto',
      'descrizione': descrizione,
      'quantita': 1,
      'prezzo': totale,
    };

    Navigator.pop(context, servizio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trasporto e Muletto")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "TRASPORTO:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: nomeCorriereController,
                decoration: const InputDecoration(labelText: "Trasportatore"),
              ),
              TextField(
                controller: daLocalitaController,
                decoration: const InputDecoration(labelText: "Da località"),
              ),
              TextField(
                controller: aLocalitaController,
                decoration: const InputDecoration(labelText: "A località"),
              ),
              Row(
                children: [
                  Checkbox(
                    value: andataRitorno,
                    onChanged:
                        (value) =>
                            setState(() => andataRitorno = value ?? false),
                  ),
                  const Text("Andata e Ritorno"),
                ],
              ),
              TextField(
                controller: prezzoTrasportoController,
                decoration: const InputDecoration(
                  labelText: "Prezzo Trasporto (€)",
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text(
                "CARRELLO ELEVATORE:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: prezzoScaricoController,
                decoration: const InputDecoration(
                  labelText: "Prezzo Scarico (€)",
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: prezzoRicaricoController,
                decoration: const InputDecoration(
                  labelText: "Prezzo Ricarico (€)",
                ),
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Checkbox(
                    value: caricoMano,
                    onChanged:
                        (value) => setState(() => caricoMano = value ?? false),
                  ),
                  const Text("Scarico e Carico a mano"),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Annulla"),
                  ),
                  ElevatedButton(
                    onPressed: salvaEDisponi,
                    child: const Text("Aggiungi"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

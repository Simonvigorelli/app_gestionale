import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart'; // Import for generating unique IDs

import '../models/product_model.dart';
import '../models/azienda_model.dart';
import '../models/cliente_model.dart';
import '../models/preventivo_model.dart';
import 'aggiungi_azienda_screen.dart';
import 'aggiungi_cliente_screen.dart';
import 'visualizza_preventivo_screen.dart';
import 'montaggio_screen.dart';
import 'grafica_screen.dart';
import 'ripostiglio_screen.dart';
import 'impianto_elettrico_screen.dart';
import 'trasporto_screen.dart';
import 'preparazione_screen.dart';

class PreventiviScreen extends StatefulWidget {
  const PreventiviScreen({super.key});

  @override
  State<PreventiviScreen> createState() => _PreventiviScreenState();
}

class _PreventiviScreenState extends State<PreventiviScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  void _aggiungiProdottoPersonalizzato() {
    final nomeCtrl = TextEditingController();
    final descrizioneCtrl = TextEditingController();
    final quantitaCtrl = TextEditingController();
    final prezzoCtrl = TextEditingController();
    String tipo = "pezzi"; // Initialize type

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder( // Use StatefulBuilder for dialog-specific state
          builder: (BuildContext context, StateSetter dialogSetState) {
            return AlertDialog(
              title: const Text("Nuovo Prodotto Personalizzato"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nomeCtrl,
                      decoration: const InputDecoration(labelText: "Nome prodotto"),
                    ),
                    TextField(
                      controller: descrizioneCtrl,
                      decoration: const InputDecoration(labelText: "Descrizione"),
                    ),
                    TextField(
                      controller: quantitaCtrl,
                      decoration: const InputDecoration(labelText: "Quantità"),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<String>(
                      value: tipo,
                      onChanged: (val) {
                        if (val != null) {
                          dialogSetState(() { // Use dialogSetState to update dropdown
                            tipo = val;
                          });
                        }
                      },
                      items: const ["pezzi", "mq"]
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.toUpperCase()),
                              ))
                          .toList(),
                      decoration: const InputDecoration(labelText: "Tipo quantità"),
                    ),
                    TextField(
                      controller: prezzoCtrl,
                      decoration: const InputDecoration(labelText: "Prezzo unitario (€)"),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Annulla"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text("Aggiungi"),
                  onPressed: () {
                    final nome = nomeCtrl.text.trim();
                    final descrizione = descrizioneCtrl.text.trim();
                    final quantita = int.tryParse(quantitaCtrl.text) ?? 0;
                    final prezzo = double.tryParse(prezzoCtrl.text) ?? 0.0;

                    if (nome.isNotEmpty && quantita > 0 && prezzo > 0) {
                      setState(() {
                        // Use a unique code for custom products
                        final customProductCode = "PERS-${const Uuid().v4().substring(0, 8).toUpperCase()}";
                        prodottiPreventivo.add({
                          "codice": customProductCode,
                          "descrizione": nome,
                          "quantita": quantita,
                          "prezzo": prezzo,
                          "tipo": tipo,
                        });
                      });
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Compila tutti i campi correttamente"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  AziendaModel? aziendaSelezionata;
  ClienteModel? clienteSelezionato;

  final TextEditingController numeroController = TextEditingController();
  final TextEditingController dataController = TextEditingController();
  final TextEditingController nomeStandController = TextEditingController();
  final TextEditingController dimensioneStandController =
      TextEditingController();
  final TextEditingController nomeManifestazioneController =
      TextEditingController();
  final TextEditingController dataManifestazioneController =
      TextEditingController();
  final TextEditingController cittaManifestazioneController =
      TextEditingController();
  final TextEditingController ivaController = TextEditingController(text: '22');
  final TextEditingController rincaroController = TextEditingController(
    text: '0',
  );
  final TextEditingController accontoController = TextEditingController(
    text: '0',
  );
  final TextEditingController scontoController = TextEditingController(
    text: '0',
  );

  bool estero = false;

  List<Map<String, dynamic>> prodottiPreventivo = [];
  List<Map<String, dynamic>> serviziPreventivo = [];

  Future<void> mostraDialogoEliminazione(String tipo) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Voce già presente"),
        content: Text(
          "La voce '$tipo' è già stata aggiunta al preventivo.\nVuoi eliminarla per inserirne una nuova?",
        ),
        actions: [
          TextButton(
            child: const Text("Annulla"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("Elimina"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        serviziPreventivo.removeWhere((s) => s['tipo'] == tipo);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final box = Hive.box<PreventivoModel>('preventivi');
    if (box.isNotEmpty) {
      final ultimo = box.values.last;
      numeroController.text = (ultimo.numero + 1).toString();
    } else {
      numeroController.text = '1';
    }

    _tabController = TabController(length: 3, vsync: this);
    dataController.text = DateTime.now().toString().substring(0, 10);
  }

  bool vocePresente(String tipo) {
    return serviziPreventivo.any((s) => s['tipo'] == tipo);
  }

  Future<void> selezionaProdottoDaMagazzino() async {
    final box = Hive.box<ProductModel>('products');
    final prodotti = box.values.toList();

    if (prodotti.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nessun prodotto disponibile nell\'archivio')),
      );
      return;
    }

    TextEditingController searchController = TextEditingController();
    List<ProductModel> risultati = List.from(prodotti);
    ProductModel? prodottoSelezionato;

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Seleziona Prodotto'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Cerca per codice o descrizione',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          final query = value.toLowerCase();
                          risultati = prodotti.where((prodotto) {
                            return prodotto.code.toLowerCase().contains(query) ||
                                prodotto.description.toLowerCase().contains(query);
                          }).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: risultati.isEmpty
                          ? const Center(child: Text("Nessun prodotto trovato"))
                          : ListView.builder(
                              itemCount: risultati.length,
                              itemBuilder: (context, index) {
                                final prodotto = risultati[index];
                                return ListTile(
                                  title: Text('${prodotto.code} - ${prodotto.description}'),
                                  subtitle: Text('Prezzo: € ${prodotto.price.toStringAsFixed(2)}'),
                                  onTap: () {
                                    prodottoSelezionato = prodotto;
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (prodottoSelezionato != null) {
      setState(() {
        prodottiPreventivo.add({
          'codice': prodottoSelezionato!.code,
          'descrizione': prodottoSelezionato!.description,
          'quantita': 1,
          'prezzo': prodottoSelezionato!.price,
        });
      });
    }
  }

  double calcolaTotale() {
    double totale = 0;
    for (var p in [...prodottiPreventivo, ...serviziPreventivo]) {
      final quantita = (p['quantita'] is int || p['quantita'] is double) ? p['quantita'].toDouble() : 0.0;
      final prezzo = (p['prezzo'] is int || p['prezzo'] is double) ? p['prezzo'].toDouble() : 0.0;
      totale += quantita * prezzo;
    }

    double iva = double.tryParse(ivaController.text) ?? 0;
    double sconto = double.tryParse(scontoController.text) ?? 0;
    double acconto = double.tryParse(accontoController.text) ?? 0;
    double rincaroPercentuale = double.tryParse(rincaroController.text) ?? 0;

    double totaleConRincaro = totale + (totale * rincaroPercentuale / 100);
    double totaleConIvaERincaro = totaleConRincaro + (totaleConRincaro * iva / 100);

    // Apply discount percentage
    double totaleDopoSconto = totaleConIvaERincaro * (1 - (sconto / 100));

    return totaleDopoSconto - acconto;
  }

  void salvaPreventivo() async {
    if (aziendaSelezionata == null || clienteSelezionato == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona un\'azienda e un cliente')),
      );
      return;
    }

    final box = Hive.box<PreventivoModel>('preventivi');
    final newId = const Uuid().v4();

    final nuovo = PreventivoModel(
      id: newId,
      numero: int.tryParse(numeroController.text) ?? 0,
      data: dataController.text,
      azienda: aziendaSelezionata!,
      cliente: clienteSelezionato!,
      nomeStand: nomeStandController.text,
      dimensioneStand: double.tryParse(dimensioneStandController.text) ?? 0,
      nomeManifestazione: nomeManifestazioneController.text,
      dataManifestazione: dataManifestazioneController.text,
      cittaManifestazione: cittaManifestazioneController.text,
      estero: estero,
      prodotti: prodottiPreventivo,
      servizi: serviziPreventivo,
      iva: double.tryParse(ivaController.text) ?? 0,
      rincaro: double.tryParse(rincaroController.text) ?? 0,
      acconto: double.tryParse(accontoController.text) ?? 0,
      sconto: double.tryParse(scontoController.text) ?? 0,
      totale: calcolaTotale(), // Ensure this matches PreventivoModel's structure
    );
    await box.put(newId, nuovo);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VisualizzaPreventivoScreen(preventivo: nuovo),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preventivi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dati Generali'),
            Tab(text: 'Prodotti'),
            Tab(text: 'Servizi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDatiGeneraliTab(),
          _buildProdottiTab(),
          _buildServiziTab(),
        ],
      ),
    );
  }

  Widget _buildDatiGeneraliTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: numeroController,
            decoration: const InputDecoration(labelText: 'Numero Preventivo'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: dataController,
            decoration: const InputDecoration(labelText: 'Data'),
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                setState(() {
                  dataController.text = pickedDate.toString().substring(0, 10);
                });
              }
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable:
                      Hive.box<AziendaModel>('aziende').listenable(),
                  builder: (context, Box<AziendaModel> box, _) {
                    final aziende = box.values.toList();
                    return DropdownButtonFormField<AziendaModel>(
                      isExpanded: true,
                      hint: const Text("Seleziona Azienda"),
                      value: aziendaSelezionata,
                      onChanged:
                          (val) => setState(() => aziendaSelezionata = val),
                      items: aziende
                          .map(
                            (a) => DropdownMenuItem(
                              value: a,
                              child: Text(a.nome),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AggiungiAziendaScreen()),
                  );
                  setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable:
                      Hive.box<ClienteModel>('clienti').listenable(),
                  builder: (context, Box<ClienteModel> box, _) {
                    final clienti = box.values.toList();
                    return DropdownButtonFormField<ClienteModel>(
                      isExpanded: true,
                      hint: const Text("Seleziona Cliente"),
                      value: clienteSelezionato,
                      onChanged:
                          (val) => setState(() => clienteSelezionato = val),
                      items: clienti
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.nome),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AggiungiClienteScreen()),
                  );
                  setState(() {});
                },
              ),
            ],
          ),
          TextField(
            controller: nomeStandController,
            decoration: const InputDecoration(labelText: 'Nome Stand'),
          ),
          TextField(
            controller: dimensioneStandController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Dimensione Stand (mq)',
            ),
          ),
          TextField(
            controller: nomeManifestazioneController,
            decoration: const InputDecoration(labelText: 'Nome Manifestazione'),
          ),
          TextField(
            controller: dataManifestazioneController,
            decoration: const InputDecoration(labelText: 'Data Manifestazione'),
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                setState(() {
                  dataManifestazioneController.text = pickedDate.toString().substring(0, 10);
                });
              }
            },
          ),
          TextField(
            controller: cittaManifestazioneController,
            decoration: const InputDecoration(labelText: 'Città'),
          ),
          Row(
            children: [
              const Text('Estero'),
              Checkbox(
                value: estero,
                onChanged: (val) => setState(() => estero = val ?? false),
              ),
            ],
          ),
          const Divider(height: 24),
          TextField(
            controller: ivaController,
            decoration: const InputDecoration(labelText: 'IVA (%)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: rincaroController,
            decoration: const InputDecoration(labelText: 'Rincaro (%)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: accontoController,
            decoration: const InputDecoration(labelText: 'Acconto (€)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: scontoController,
            decoration: const InputDecoration(labelText: 'Sconto (%)'),
            keyboardType: TextInputType.number,
          ),

          const Divider(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text("Cerca e carica un preventivo salvato"),
            onPressed: _caricaPreventivoEsistente,
          ),
        ],
      ),
    );
  }

  void _caricaPreventivoEsistente() async {
    final box = Hive.box<PreventivoModel>('preventivi');
    final lista = box.values.toList();

    PreventivoModel? selezionato;

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Seleziona un Preventivo salvato"),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: lista.length,
              itemBuilder: (context, index) {
                final p = lista[index];
                return ListTile(
                  title: Text("Preventivo #${p.numero} - ${p.cliente.nome}"),
                  subtitle: Text("${p.data} - ${p.nomeStand}"),
                  onTap: () {
                    selezionato = p;
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selezionato != null) {
      setState(() {
        numeroController.text = selezionato!.numero.toString();
        dataController.text = selezionato!.data;
        aziendaSelezionata = selezionato!.azienda;
        clienteSelezionato = selezionato!.cliente;
        nomeStandController.text = selezionato!.nomeStand;
        dimensioneStandController.text = selezionato!.dimensioneStand.toString();
        nomeManifestazioneController.text = selezionato!.nomeManifestazione;
        dataManifestazioneController.text = selezionato!.dataManifestazione;
        cittaManifestazioneController.text = selezionato!.cittaManifestazione;
        estero = selezionato!.estero;
        ivaController.text = selezionato!.iva.toString();
        rincaroController.text = selezionato!.rincaro.toString();
        accontoController.text = selezionato!.acconto.toString();
        scontoController.text = selezionato!.sconto.toString();
        prodottiPreventivo = List<Map<String, dynamic>>.from(selezionato!.prodotti);
        serviziPreventivo = List<Map<String, dynamic>>.from(selezionato!.servizi);
      });
    }
  }

  Widget _buildProdottiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add_circle_outline),
            label: const Text("Aggiungi Prodotto Personalizzato"),
            onPressed: _aggiungiProdottoPersonalizzato,
          ),
          ElevatedButton.icon(
            onPressed: selezionaProdottoDaMagazzino,
            icon: const Icon(Icons.add),
            label: const Text("Aggiungi Prodotto da Magazzino"),
          ),
          const SizedBox(height: 10),

          ...prodottiPreventivo
              .where((p) => p['tipo'] != 'Grafica')
              .toList()
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key;
                final p = entry.value;
                return Card(
                  child: ListTile(
                    title: Text('${p['codice']} - ${p['descrizione']}'),
                    subtitle: Row(
                      children: [
                        const Text('Quantità: '),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (p['quantita'] > 1) p['quantita']--;
                            });
                          },
                        ),
                        Text('${p['quantita']}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              p['quantita']++;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Totale: € ${(p['quantita'] * p['prezzo']).toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          prodottiPreventivo.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              }),

          const Divider(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Grafica"),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Aggiungi"),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GraficaScreen()),
                  );
                  if (result != null) {
                    setState(() => prodottiPreventivo.add(result));
                  }
                },
              ),
            ],
          ),

          ...prodottiPreventivo
              .where((p) => p['tipo'] == 'Grafica')
              .toList()
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key;
                final p = entry.value;
                return Card(
                  child: ListTile(
                    title: Text('${p['descrizione']}'),
                    subtitle: Row(
                      children: [
                        const Text('Quantità: '),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (p['quantita'] > 1) p['quantita']--;
                            });
                          },
                        ),
                        Text('${p['quantita']}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              p['quantita']++;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Totale: € ${(p['quantita'] * p['prezzo']).toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          prodottiPreventivo.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              }),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text("Salva e Visualizza Preventivo"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: salvaPreventivo,
          ),
        ],
      ),
    );
  }

  Widget _buildServiziTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      vocePresente('Montaggio') ? Colors.green : null,
                ),
                onPressed: () async {
                  if (vocePresente('Montaggio')) {
                    await mostraDialogoEliminazione('Montaggio');
                    return;
                  }

                  final double mq =
                      double.tryParse(dimensioneStandController.text) ?? 0;
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MontaggioScreen(metriQuadri: mq),
                    ),
                  );
                  if (result != null) {
                    setState(() => serviziPreventivo.add(result));
                  }
                },
                child: const Text("Montaggio"),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      vocePresente('Trasporto') ? Colors.green : null,
                ),
                onPressed: () async {
                  if (vocePresente('Trasporto')) {
                    await mostraDialogoEliminazione('Trasporto');
                    return;
                  }

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TrasportoScreen()),
                  );
                  if (result != null) {
                    setState(() => serviziPreventivo.add(result));
                  }
                },
                child: const Text("Trasporto"),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      vocePresente('Ripostiglio') ? Colors.green : null,
                ),
                onPressed: () async {
                  if (vocePresente('Ripostiglio')) {
                    await mostraDialogoEliminazione('Ripostiglio');
                    return;
                  }

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RipostiglioScreen(),
                    ),
                  );
                  if (result != null) {
                    setState(() => serviziPreventivo.add(result));
                  }
                },
                child: const Text("Ripostiglio"),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      vocePresente('Impianto Elettrico') ? Colors.green : null,
                ),
                onPressed: () async {
                  if (vocePresente('Impianto Elettrico')) {
                    await mostraDialogoEliminazione('Impianto Elettrico');
                    return;
                  }

                  final double mq =
                      double.tryParse(dimensioneStandController.text) ?? 0;
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ImpiantoElettricoScreen(dimensioneStand: mq),
                    ),
                  );
                  if (result != null) {
                    setState(() => serviziPreventivo.add(result));
                  }
                },
                child: const Text("Impianto Elettrico"),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      vocePresente('Preparazione') ? Colors.green : null,
                ),
                onPressed: () async {
                  if (vocePresente('Preparazione')) {
                    await mostraDialogoEliminazione('Preparazione');
                    return;
                  }

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PreparazioneScreen(),
                    ),
                  );
                  if (result != null) {
                    setState(() => serviziPreventivo.add(result));
                  }
                },
                child: const Text("Preparazione"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
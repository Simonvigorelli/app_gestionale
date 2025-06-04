import 'package:flutter/material.dart';
import 'models.dart' as models;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'transformer_list_screen.dart'; 
import 'package:flutter/services.dart'; // Assicurati che questo import ci sia in cima al file


class StandDetailScreen extends StatefulWidget {
  const StandDetailScreen({
    super.key,
    required this.stand,
    required this.standIndex,
    required this.onUpdate,
  });

  final models.Stand stand;
  final int standIndex;
  final ValueChanged<models.Stand> onUpdate;

  @override
  StandDetailScreenState createState() => StandDetailScreenState();
}

class StandDetailScreenState extends State<StandDetailScreen> {
  late models.Stand stand;


@override
void initState() {
  super.initState();
  stand = widget.stand;
  _loadSavedDevices(); // 👈 aggiungi questa riga
}

Future<void> _loadSavedDevices() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('stand_${stand.name}');
  if (jsonString != null) {
    final data = jsonDecode(jsonString);
    final loadedStand = models.Stand.fromJson(data);
    setState(() {
      stand.devices = loadedStand.devices;
    });
  }
}


  Future<void> saveDataToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(stand.toJson());
    await prefs.setString('stand_${stand.name}', jsonData);
  }

  double _calculateTotalPower() {
    return stand.devices.fold(0.0, (sum, d) => sum + (d.power * d.quantity));
  }

  void _addDeviceDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Aggiungi Dispositivo"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDeviceOption("Quadro Elettrico", 0.5),
                _buildDeviceOption("Faro LED 20W", 0.02),
                _buildDeviceOption("Faro LED 50W", 0.05),
                _buildDeviceOption("Faro LED 100W", 0.1),
                _buildDeviceOption("Frigo 100 lt", 0.25),
                _buildDeviceOption("Macchina del Caffè", 1.3),
                _buildDeviceOption("Tv 50", 0.08),
                _buildDeviceOption("Tv 55", 0.10),
                _buildDeviceOption("Tv 65", 0.13),
                _buildDeviceOption("Tv 85", 0.20),
                _buildDeviceOption("Dicroiche LED 12V", 0.005),
                _buildPresaTile(),
                _createBarraTile(),
                _buildCustomProductTile(),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Chiudi"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPresaTile() {
    return ListTile(
      title: Text("Presa Elettrica"),
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text("Seleziona il tipo di presa"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDeviceOption("Presa Multifunzione", 0.05),
                  _buildDeviceOption("Presa Singola", 0.05),
                  _buildDeviceOption("Presa ad Incasso", 0.05),
                  _buildDeviceOption("Presa Schuko", 0.05),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("Chiudi"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDeviceOption(String label, double power) {
    return ListTile(
      title: Text(label),
      onTap: () {
        setState(() {
          stand.devices.add(
            models.Device(name: label, quantity: 1, power: power),
          );
        });
        saveDataToPrefs();
        Navigator.pop(context);
      },
    );
  }

  Widget _createBarraTile() {
    return ListTile(
      title: Text("Barra LED (lunghezza personalizzabile)"),
      onTap: () {
        TextEditingController lengthCtrl = TextEditingController();
        showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text("Lunghezza Barra LED"),
              content: TextField(
                controller: lengthCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Lunghezza in cm"),
              ),
              actions: [
                TextButton(
                  child: Text("Annulla"),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text("Aggiungi"),
                  onPressed: () {
                    int len = int.tryParse(lengthCtrl.text) ?? 0;
                    if (len > 0) {
                      setState(() {
                        stand.devices.add(
                          models.Device(
                            name: "Barra LED",
                            quantity: 1,
                            power: 0.01,
                            length: len,
                          ),
                        );
                      });
                      saveDataToPrefs();
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

void _createCustomProductTile() {
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController voltageCtrl = TextEditingController();
  TextEditingController currentCtrl = TextEditingController();
  TextEditingController powerCtrl = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text("Nuovo Prodotto Personalizzato"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: "Nome del Prodotto"),
              ),
              TextField(
                controller: voltageCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return newValue.copyWith(
                      text: newValue.text.replaceAll(',', '.'),
                    );
                  }),
                ],
                decoration: InputDecoration(labelText: "Tensione (V)"),
              ),
              TextField(
                controller: currentCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return newValue.copyWith(
                      text: newValue.text.replaceAll(',', '.'),
                    );
                  }),
                ],
                decoration: InputDecoration(labelText: "Corrente (A)"),
              ),
              TextField(
                controller: powerCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return newValue.copyWith(
                      text: newValue.text.replaceAll(',', '.'),
                    );
                  }),
                ],
                decoration: InputDecoration(
                  labelText: "Potenza in kW (se disponibile)",
                ),
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
              String name = nameCtrl.text.trim();
              double? voltage = double.tryParse(voltageCtrl.text);
              double? current = double.tryParse(currentCtrl.text);
              double? power = double.tryParse(powerCtrl.text);

              if (power == null || power <= 0) {
                if (voltage != null && current != null) {
                  power = (voltage * current) / 1000; // Conversione in kW
                } else {
                  power = 0;
                }
              }

              if (name.isNotEmpty && power > 0) {
                setState(() {
stand.devices.add(
  models.Device(name: name, quantity: 1, power: power!),
);

                });
                saveDataToPrefs();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Inserisci un nome valido e almeno V e A per calcolare il consumo.",
                    ),
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
}


void _shareStandInfo() {
  final StringBuffer buffer = StringBuffer();
  buffer.writeln("🧾 Lista prodotti dello stand: ${stand.name}\n");

  for (var device in stand.devices) {
    buffer.writeln(
      "- ${device.name} (${device.quantity}x): ${(device.power * device.quantity).toStringAsFixed(2)} kW${device.length != null
              ? " (${(device.length! * device.quantity / 100).toStringAsFixed(2)} m)"
              : ""}",
    );
  }

  buffer.writeln(
    "\n⚡ Assorbimento totale: ${_calculateTotalPower().toStringAsFixed(2)} kW",
  );
  buffer.writeln(
    "💡 Totale metri di barre LED: ${_calculateTotalLedMeters().toStringAsFixed(2)} m",
  );

  Share.share(buffer.toString(), subject: "Dettagli Stand ${stand.name}");
}


  Widget _buildCustomProductTile() {
    return ListTile(
      leading: Icon(Icons.add_circle, color: Colors.orange),
      title: Text("Aggiungi Prodotto Personalizzato"),
      onTap: _createCustomProductTile,
    );
  }

  double _calculateTotalLedMeters() {
    return stand.devices
        .where((d) => d.name.contains("Barra LED"))
        .fold(0.0, (sum, d) => sum + (d.length ?? 0) * d.quantity / 100);
  }

  void _showProductList() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Lista Prodotti nello Stand"),
          content: SingleChildScrollView(
            child: DataTable(
              columns: [
                DataColumn(label: Text("Nome")),
                DataColumn(label: Text("Quantità")),
                DataColumn(label: Text("Assorbimento (kW)")),
                DataColumn(label: Text("Lunghezza LED (m)")),
              ],
              rows:
                  stand.devices.map((device) {
                    return DataRow(
                      cells: [
                        DataCell(Text(device.name)),
                        DataCell(Text(device.quantity.toString())),
                        DataCell(
                          Text(
                            (device.power * device.quantity).toStringAsFixed(2),
                          ),
                        ),
                        DataCell(
                          Text(
                            device.length != null
                                ? "${(device.length! * device.quantity / 100).toStringAsFixed(2)} m"
                                : "-",
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Chiudi"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _showTransformerCalculation() async {
    double totalLedMeters = _calculateTotalLedMeters();

    if (totalLedMeters == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Nessuna barra LED presente nello stand."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Padding(
  padding: const EdgeInsets.all(8.0),
  child: Center(
    child: Text(
      "⬇️ Scorri per vedere tutti i dispositivi ⬇️",
      style: TextStyle(color: Colors.grey),
    ),
  ),
);


    Column(
  children: stand.devices.map((device) {
  return ListTile(
    leading: Icon(Icons.electrical_services, color: Colors.blue),
    title: Text("${device.name} (${device.quantity}x)${device.length != null ? " - ${device.length} cm" : ""}"),
    subtitle: Text(
      "Consumo: ${(device.power * device.quantity).toStringAsFixed(2)} kW",
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove, color: Colors.red),
          onPressed: () {
            setState(() {
              if (device.quantity > 1) {
                device.quantity--;
              } else {
                stand.devices.remove(device);
              }
              saveDataToPrefs();
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.add, color: Colors.green),
          onPressed: () {
            setState(() {
              device.quantity++;
              saveDataToPrefs();
            });
          },
        ),
      ],
    ),
  );
}).toList(),);

    // Recupera i trasformatori salvati
    final prefs = await SharedPreferences.getInstance();
    final transStr = prefs.getString('transformers_data');
    List<models.TransformerModel> transformers = [];

    if (transStr != null) {
      final decodedList = jsonDecode(transStr) as List;
      transformers =
          decodedList.map((e) => models.TransformerModel.fromJson(e)).toList();
    }

    // Ordina i trasformatori dal più potente al meno potente
    transformers.sort((a, b) => b.maxMeters.compareTo(a.maxMeters));

    // Trova le migliori combinazioni di trasformatori
    List<Map<String, dynamic>> recommended =
        _calculateBestTransformerCombination(totalLedMeters, transformers);

    // Mostra la finestra di dialogo con i trasformatori consigliati
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Trasformatori Consigliati"),
          content: SingleChildScrollView(
            child:
                recommended.isEmpty
                    ? Text(
                      "Nessun trasformatore disponibile per coprire ${totalLedMeters.toStringAsFixed(2)} metri LED.",
                    )
                    : DataTable(
                      columns: [
                        DataColumn(label: Text("Nome")),
                        DataColumn(label: Text("Quantità")),
                      ],
                      rows:
                          recommended.map((tr) {
                            return DataRow(
                              cells: [
                                DataCell(Text(tr['name'])),
                                DataCell(Text(tr['quantity'].toString())),
                              ],
                            );
                          }).toList(),
                    ),
          ),
          actions: [
            TextButton(
              child: Text("Chiudi"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _calculateBestTransformerCombination(
    double totalMeters,
    List<models.TransformerModel> transformers,
  ) {
    List<Map<String, dynamic>> result = [];

    if (transformers.isEmpty) {
      return result;
    }

    for (var t in transformers) {
      int count = (totalMeters / t.maxMeters).ceil();
      result.add({'name': t.name, 'quantity': count});
    }

    return result;
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(stand.name),
      actions: [
        IconButton(
          icon: Icon(Icons.ios_share),
          onPressed: _shareStandInfo,
        ),
      ],
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Assorbimento totale: ${_calculateTotalPower().toStringAsFixed(2)} kW",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.list),
                    label: Text("Lista Prodotti"),
                    onPressed: _showProductList,
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text("Aggiungi Dispositivo"),
                    onPressed: _addDeviceDialog,
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.electrical_services),
                    label: Text("Gestione Trasformatori"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => TransformerListScreen()),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.calculate),
                    label: Text("Calcola Trasformatori"),
                    onPressed: _showTransformerCalculation,
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView(
            children: stand.devices.map(
              (device) => ListTile(
                leading: Icon(Icons.electrical_services, color: Colors.blue),
                title: Text("${device.name} (${device.quantity}x)${device.length != null ? " - ${device.length} cm" : ""}"),
                subtitle: Text(
                  "Consumo: ${(device.power * device.quantity).toStringAsFixed(2)} kW",
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          if (device.quantity > 1) {
                            device.quantity--;
                          } else {
                            stand.devices.remove(device);
                          }
                          saveDataToPrefs();
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          device.quantity++;
                          saveDataToPrefs();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ).toList(),
          ),
        ),
      ],
    ),
  );
}
}

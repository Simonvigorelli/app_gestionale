import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'models.dart';
import 'stand_detail_screen.dart';

class StandListScreen extends StatefulWidget {
  final bool isDarkMode;

  const StandListScreen({super.key, this.isDarkMode = false});

  @override
  _StandListScreenState createState() => _StandListScreenState();
}

class _StandListScreenState extends State<StandListScreen> {
  List<Stand> standList = [];

  @override
  void initState() {
    super.initState();
    loadDataFromPrefs();
  }

  Future<void> loadDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final standStr = prefs.getString('stand_data');
    if (standStr != null) {
      final decoded = jsonDecode(standStr) as List;
      setState(() {
        standList = decoded.map((e) => Stand.fromJson(e)).toList();
      });
    }
  }

  Future<void> saveDataToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final standJson = jsonEncode(standList.map((e) => e.toJson()).toList());
    await prefs.setString('stand_data', standJson);
  }

  void _addStand() {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController areaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Nuovo Assorbimento"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Nome nuovo assorbimento",
                ),
              ),
              TextField(
                controller: areaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Metri Quadri"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Annulla"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Aggiungi"),
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && areaCtrl.text.isNotEmpty) {
                  setState(() {
                    standList.add(
                      Stand(
                        name: nameCtrl.text,
                        area: int.tryParse(areaCtrl.text) ?? 0,
                        devices: [],
                      ),
                    );
                  });
                  saveDataToPrefs();
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _openStand(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (ctx) => StandDetailScreen(
              stand: standList[index],
              standIndex: index,
              onUpdate: (updatedStand) {
                setState(() {
                  standList[index] = updatedStand;
                  saveDataToPrefs();
                });
              },
            ),
      ),
    );
  }

  void _removeStand(int index) {
    setState(() {
      standList.removeAt(index);
    });
    saveDataToPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestione Assorbimento Elettrico"),
        actions: [],
      ),
      body:
          standList.isEmpty
              ? const Center(
                child: Text("Nessuno calcolo assorbimento presente"),
              )
              : ListView.builder(
                itemCount: standList.length,
                itemBuilder: (ctx, i) {
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.home_filled,
                        color: Colors.blue,
                      ),
                      title: Text(
                        standList[i].name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Area: ${standList[i].area} m²"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeStand(i),
                      ),
                      onTap: () => _openStand(i),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Nuovo Calcolo Assorbimento"),
        onPressed: _addStand,
      ),
    );
  }
}

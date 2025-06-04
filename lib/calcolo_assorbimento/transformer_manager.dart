
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models.dart';

class TransformerManager extends StatefulWidget {
  final double totalLedMeters;

  const TransformerManager({super.key, required this.totalLedMeters});

  @override
  _TransformerManagerState createState() => _TransformerManagerState();

  static List<Map<String, dynamic>> calculateRecommendedTransformers(
      double totalLedMeters, List<Transformer> transformers) {
    double remainingMeters = totalLedMeters;
    List<Map<String, dynamic>> recommended = [];

    for (var transformer in transformers) {
      if (remainingMeters <= 0) break;
      int count = (remainingMeters / transformer.capacity).ceil();
      recommended.add({'name': transformer.name, 'quantity': count});
      remainingMeters -= count * transformer.capacity;
    }

    return recommended;
  }
}

class _TransformerManagerState extends State<TransformerManager> {
  List<Transformer> transformers = [];

  @override
  void initState() {
    super.initState();
    _loadTransformers();
  }

  Future<void> _loadTransformers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('transformers');
    if (data != null) {
      try {
        final List<dynamic> decodedList = json.decode(data);
        setState(() {
          transformers = decodedList
              .map((e) => Transformer.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      } catch (e) {
        debugPrint("Errore nel caricamento trasformatori: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

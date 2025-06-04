import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/product_model.dart';
import '../models/movement_model.dart';

class MovementScreen extends StatefulWidget {
  final List<ProductModel> products;
  final String? aziendaId;
  final bool offlineMode;

  const MovementScreen({
    Key? key,
    required this.products,
    this.aziendaId,
    this.offlineMode = false,
  }) : super(key: key);

  @override
  _MovementScreenState createState() => _MovementScreenState();
}

class _MovementScreenState extends State<MovementScreen> {
  late List<MovementModel> _allMovements = [];
  late List<MovementModel> _filteredMovements = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Potresti caricare i movimenti qui da Hive o Firebase
  }

  void _gestisciMovimentoDaQR(String qrCode) async {
    final now = DateTime.now();
    final prodotto = widget.products.firstWhere(
      (p) => p.qrCode == qrCode,
      orElse: () => ProductModel(
        code: '',
        description: '',
        quantity: 0,
        price: 0.0,
        qrCode: '',
      ),
    );

    if (prodotto.qrCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Prodotto non trovato")),
      );
      return;
    }

    final ultimiMovimenti = _allMovements.where((m) => m.productId == prodotto.qrCode).toList();
    final inUscita = ultimiMovimenti.isNotEmpty && ultimiMovimenti.last.tipo == "uscita";

    final nuovoMovimento = MovementModel(
      id: const Uuid().v4(),
      productId: prodotto.qrCode,
      tipo: inUscita ? "entrata" : "uscita",
      quantita: 1,
      data: now,
    );

    setState(() {
      _allMovements.add(nuovoMovimento);
      _filteredMovements = _allMovements;
    });

    if (!widget.offlineMode && widget.aziendaId != null) {
      await FirebaseFirestore.instance
          .collection('aziende')
          .doc(widget.aziendaId)
          .collection('movimenti')
          .doc(nuovoMovimento.id)
          .set(nuovoMovimento.toMap());
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Movimento registrato: ${nuovoMovimento.tipo.toUpperCase()}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qrArg = ModalRoute.of(context)?.settings.arguments;
    if (qrArg != null && qrArg is String) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _gestisciMovimentoDaQR(qrArg);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Movimenti"),
      ),
      body: ListView.builder(
        itemCount: _filteredMovements.length,
        itemBuilder: (context, index) {
          final movimento = _filteredMovements[index];
          return ListTile(
            title: Text("${movimento.tipo} - ${movimento.productId}"),
            subtitle: Text("Data: ${movimento.data}, Quantità: ${movimento.quantita}"),
          );
        },
      ),
    );
  }
}

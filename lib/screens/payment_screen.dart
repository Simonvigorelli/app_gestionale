import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  bool _loading = true;
  String _errorMessage = '';

  final List<String> _productIds = [
    'standapp_singolo_acquisto',
    'standapp_singolo_abbonamento',
    'standapp_azienda_acquisto',
    'standapp_azienda_abbonamento',
  ];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _loading = false;
        _errorMessage = 'Gli acquisti non sono disponibili.';
      });
      return;
    }

    final response = await _inAppPurchase.queryProductDetails(_productIds.toSet());
    if (response.error != null) {
      setState(() {
        _loading = false;
        _errorMessage = 'Errore: ${response.error!.message}';
      });
      return;
    }

    setState(() {
      _products = response.productDetails;
      _loading = false;
    });
  }

  void _buy(ProductDetails product) {
    final purchaseParam = PurchaseParam(productDetails: product);
    if (product.id.contains('abbonamento')) {
      _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(body: Center(child: Text(_errorMessage)));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Sblocca l'app")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Utente singolo", style: TextStyle(fontWeight: FontWeight.bold)),
          ..._products.where((p) => p.id.contains("singolo")).map((product) => ListTile(
                title: Text(product.title),
                subtitle: Text(product.description),
                trailing: Text(product.price),
                onTap: () => _buy(product),
              )),
          const Divider(),
          const Text("Licenza azienda (fino a 5 utenti)", style: TextStyle(fontWeight: FontWeight.bold)),
          ..._products.where((p) => p.id.contains("azienda")).map((product) => ListTile(
                title: Text(product.title),
                subtitle: Text(product.description),
                trailing: Text(product.price),
                onTap: () => _buy(product),
              )),
        ],
      ),
    );
  }
}
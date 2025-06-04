import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // Importa il pacchetto share_plus
import 'package:printing/printing.dart'; // Importa il pacchetto printing
import 'package:pdf/pdf.dart'; // Importa il pacchetto pdf
import 'package:pdf/widgets.dart'
    as pw; // Alias per evitare conflitti con flutter widgets
import '../models/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;
  // Ho rimosso le callback onProductUpdated e onProductDeleted da qui
  // perché questa è una StatelessWidget. Se hai bisogno di a, required Future<void> Function() onProductDeletedggiornare la lista
  // prodotti dopo aver modificato/eliminato, la logica deve essere nella
  // ProductsScreen che naviga qui, e lì puoi chiamare _loadProducts() al ritorno
  // da questa schermata.

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Gestione del caso in cui imagePaths sia null o vuoto.
    final hasImages =
        product.imagePaths != null && product.imagePaths!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text("Dettaglio Prodotto")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImages)
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      product.imagePaths!.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, index) {
                    final path = product.imagePaths![index];
                    return Image.file(
                      File(path),
                      height: 200,
                      width: 200,
                      fit: BoxFit.contain, // Immagine contenuta, non tagliata
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: 200,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                          alignment: Alignment.center,
                        );
                      },
                    );
                  },
                ),
              )
            else
              const Center(
                child: Icon(Icons.inventory, size: 100, color: Colors.grey),
              ),
            const SizedBox(height: 20),
            _buildDetailRow("Codice", product.code),
            _buildDetailRow("Descrizione", product.description),
            _buildDetailRow("Quantità", product.quantity.toString()),
            _buildDetailRow("Prezzo", "${product.price.toStringAsFixed(2)} €"),
            // Potresti aggiungere qui altri dettagli se ne hai
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _shareProductDetails(context, product),
                  icon: const Icon(Icons.share),
                  label: const Text("Condividi"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _printProductDetails(context, product),
                  icon: const Icon(Icons.print),
                  label: const Text("Stampa"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Funzione per condividere i dettagli del prodotto
  Future<void> _shareProductDetails(
    BuildContext context,
    ProductModel product,
  ) async {
    final String textToShare = """
Dettagli Prodotto:
Codice: ${product.code}
Descrizione: ${product.description}
Quantità: ${product.quantity}
Prezzo: ${product.price.toStringAsFixed(2)} €
""";
    try {
      await Share.share(textToShare);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante la condivisione: $e')),
        );
      }
    }
  }

  // Funzione per stampare i dettagli del prodotto
  Future<void> _printProductDetails(
    BuildContext context,
    ProductModel product,
  ) async {
    final doc = pw.Document();

    // Funzione helper per creare righe di testo in PDF
    pw.Widget _buildPdfDetailRow(
      String label,
      String value,
    ) {
      return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "$label: ",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
          ),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontSize: 12))),
        ],
      );
    }

    // Aggiungi immagini al PDF se presenti
    final List<pw.Widget> imageWidgets = [];
    if (product.imagePaths != null && product.imagePaths!.isNotEmpty) {
      for (final path in product.imagePaths!) {
        try {
          final imageFile = File(path);
          if (imageFile.existsSync()) { // Controllo se il file esiste
            final imageBytes = imageFile.readAsBytesSync();
            final pdfImage = pw.MemoryImage(imageBytes);
            imageWidgets.add(
              pw.SizedBox(
                height: 150,
                width: 150,
                child: pw.Image(
                  pdfImage,
                  fit: pw.BoxFit.contain, // Anche qui BoxFit.contain
                ),
              ),
            );
          } else {
            print("Immagine non trovata al percorso: $path");
          }
        } catch (e) {
          print("Errore caricamento immagine '$path' per PDF: $e");
          // Puoi aggiungere un placeholder per l'immagine non caricata nel PDF
          imageWidgets.add(
            pw.SizedBox(
              height: 150,
              width: 150,
              child: pw.Center(
                child: pw.Text(
                  "Immagine non disponibile",
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ),
          );
        }
      }
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Dettaglio Prodotto",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              if (imageWidgets.isNotEmpty) ...[
                pw.Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: imageWidgets,
                ),
                pw.SizedBox(height: 20),
              ],
              _buildPdfDetailRow("Codice", product.code),
              _buildPdfDetailRow("Descrizione", product.description),
              _buildPdfDetailRow("Quantità", product.quantity.toString()),
              _buildPdfDetailRow(
                "Prezzo",
                "${product.price.toStringAsFixed(2)} €",
              ),
              // Aggiungi qui altri dettagli se ne hai
            ],
          );
        },
      ),
    );

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante la stampa: $e')),
        );
      }
    }
  }
}
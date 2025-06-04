import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/preventivo_model.dart';
import '../utils/pdf_generator.dart'; // Make sure this path is correct

class VisualizzaPreventivoScreen extends StatelessWidget {
  final PreventivoModel preventivo;

  const VisualizzaPreventivoScreen({super.key, required this.preventivo});

  @override
  Widget build(BuildContext context) {
    final euro = NumberFormat.currency(locale: 'it_IT', symbol: '€');

    // Combine products and services into a single list of rows
    List<Map<String, dynamic>> righe = [
      ...preventivo.prodotti,
      ...preventivo.servizi,
    ];

    double totaleParziale = righe.fold(
      0.0, // Ensure initial value is a double
      (tot, r) {
        final quantita = (r['quantita'] is num) ? (r['quantita'] as num).toDouble() : 0.0;
        final prezzo = (r['prezzo'] is num) ? (r['prezzo'] as num).toDouble() : 0.0;
        return tot + (quantita * prezzo);
      },
    );

    // Apply rincaro (markup) percentage first, then IVA
    double totaleConRincaro = totaleParziale + (totaleParziale * preventivo.rincaro / 100);
    double totaleConIvaERincaro = totaleConRincaro + (totaleConRincaro * preventivo.iva / 100);

    // Apply discount percentage
    double totaleDopoSconto = totaleConIvaERincaro * (1 - (preventivo.sconto / 100));

    double accontoValore = totaleDopoSconto * (preventivo.acconto / 100);
    double totaleDaPagare = totaleDopoSconto - accontoValore; // This is the final amount after acconto

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preventivo n. ${preventivo.numero}'),
            Text(
              'Data: ${preventivo.data}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Genera PDF",
            onPressed: () => PdfGenerator.generaPDFPreventivo(context, preventivo),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ▶️ Intestazione Azienda
            Text(
              '**Azienda:** ${preventivo.azienda.nome}\n'
              '**Indirizzo:** ${preventivo.azienda.indirizzo}\n'
              '**Telefono:** ${preventivo.azienda.telefono}\n'
              '**Email:** ${preventivo.azienda.email}\n'
              '**P.IVA:** ${preventivo.azienda.piva}\n'
              '**IBAN:** ${preventivo.azienda.iban}\n'
              '**Codice Univoco:** ${preventivo.azienda.codiceUnivoco}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.grey[400]),

            // ▶️ Cliente
            Text(
              '**Cliente:** ${preventivo.cliente.nome}\n'
              '**Indirizzo:** ${preventivo.cliente.indirizzo}\n'
              '**Telefono:** ${preventivo.cliente.telefono}\n'
              '**Email:** ${preventivo.cliente.email}\n'
              '**P.IVA:** ${preventivo.cliente.piva}\n'
              '**Codice Univoco:** ${preventivo.cliente.codiceUnivoco}',
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.grey[400]),

            // ▶️ Dati generali stand
            Text(
              '**Stand:** ${preventivo.nomeStand}\n'
              '**Dimensione:** ${preventivo.dimensioneStand} mq\n'
              '**Manifestazione:** ${preventivo.nomeManifestazione}\n'
              '**Data:** ${preventivo.dataManifestazione}\n'
              '**Città:** ${preventivo.cittaManifestazione}${preventivo.estero ? " (Estero)" : ""}',
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.grey[400]),

            // ▶️ Tabella
            Table(
              border: TableBorder.all(color: Colors.grey[300]!),
              columnWidths: const {
                0: FlexColumnWidth(1.5), // Codice/Tipo
                1: FlexColumnWidth(4), // Descrizione
                2: FlexColumnWidth(1.5), // Quantità
                3: FlexColumnWidth(2), // Prezzo Unitario
                4: FlexColumnWidth(2), // Totale Riga
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(6),
                      child: Text('Tipo/Codice', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(6),
                      child: Text('Descrizione', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(6),
                      child: Text('Q.tà', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(6),
                      child: Text('Prezzo U.', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(6),
                      child: Text('Totale', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ...righe.map((r) {
                  final String displayCode = r['codice'] ?? r['tipo'] ?? ''; // Prefer codice, fallback to tipo
                  final double rigaQuantita = (r['quantita'] is num) ? (r['quantita'] as num).toDouble() : 0.0;
                  final double rigaPrezzo = (r['prezzo'] is num) ? (r['prezzo'] as num).toDouble() : 0.0;
                  final double rigaTotale = rigaQuantita * rigaPrezzo;

                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(displayCode),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(r['descrizione'] ?? ''),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text('${rigaQuantita.toStringAsFixed(0)}'), // Display as integer for quantity
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(euro.format(rigaPrezzo)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(euro.format(rigaTotale)),
                      ),
                    ],
                  );
                }).toList(), // Convert to list to ensure map works
              ],
            ),

            const SizedBox(height: 20),
            Text('Totale Articoli e Servizi: ${euro.format(totaleParziale)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Rincaro (${preventivo.rincaro.toStringAsFixed(0)}%): ${euro.format(totaleConRincaro - totaleParziale)}'),
            Text('Totale con Rincaro: ${euro.format(totaleConRincaro)}'),
            Text('IVA (${preventivo.iva.toStringAsFixed(0)}%): ${euro.format(totaleConIvaERincaro - totaleConRincaro)}'),
            Text('Totale Imponibile: ${euro.format(totaleConIvaERincaro)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            if (preventivo.sconto > 0)
              Text(
                'Sconto (${preventivo.sconto.toStringAsFixed(0)}%): -${euro.format(totaleConIvaERincaro - totaleDopoSconto)}',
                style: const TextStyle(color: Colors.red),
              ),
            Text('**Totale Preventivo:** ${euro.format(totaleDopoSconto)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (preventivo.acconto > 0)
              Text(
                'Acconto (${preventivo.acconto.toStringAsFixed(0)}%): -${euro.format(accontoValore)}',
                style: const TextStyle(color: Colors.blue),
              ),
            if (preventivo.acconto > 0)
              Text(
                '**Importo da saldare:** ${euro.format(totaleDaPagare)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            if (preventivo.acconto > 0)
              Text(
                "Acconto (${preventivo.acconto.toStringAsFixed(0)}%) da pagare alla firma del contratto",
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),

            const SizedBox(height: 40),
            const Text("Firma per accettazione __________________________"),
          ],
        ),
      ),
    );
  }
}
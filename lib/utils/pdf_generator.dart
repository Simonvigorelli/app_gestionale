import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/preventivo_model.dart';

class PdfGenerator {
  static Future<void> generaPDFPreventivo(
    BuildContext context,
    PreventivoModel preventivo,
  ) async {
    final pdf = pw.Document();
    final euro = NumberFormat.currency(locale: 'it_IT', symbol: '€');

    final logoPath = preventivo.azienda.logoPath;
    final imageLogo =
        (logoPath.isNotEmpty && File(logoPath).existsSync())
            ? pw.MemoryImage(File(logoPath).readAsBytesSync())
            : null;

    final righe = [...preventivo.prodotti, ...preventivo.servizi];
    final totaleParziale = righe.fold(
      0.0,
      (tot, r) => tot + (r['quantita'] * r['prezzo']),
    );
    final totaleConIva =
        totaleParziale +
        (totaleParziale * preventivo.iva / 100) +
        preventivo.rincaro -
        preventivo.sconto;
    final valoreAcconto = totaleConIva * preventivo.acconto / 100;

    pdf.addPage(
      pw.MultiPage(
        build:
            (context) => [
              if (imageLogo != null)
                pw.Container(height: 60, child: pw.Image(imageLogo)),
              pw.SizedBox(height: 10),

              // Azienda
              pw.Text(
                preventivo.azienda.nome,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(preventivo.azienda.indirizzo),
              pw.Text(
                'Tel: ${preventivo.azienda.telefono} - Email: ${preventivo.azienda.email}',
              ),
              pw.Text(
                'P.IVA: ${preventivo.azienda.piva} - IBAN: ${preventivo.azienda.iban}',
              ),
              pw.Text('Codice Univoco: ${preventivo.azienda.codiceUnivoco}'),
              pw.SizedBox(height: 10),
              pw.Divider(),

              // Cliente
              pw.Text(
                "Cliente: ${preventivo.cliente.nome}",
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(preventivo.cliente.indirizzo),
              pw.Text(
                'Tel: ${preventivo.cliente.telefono} - Email: ${preventivo.cliente.email}',
              ),
              pw.Text(
                'P.IVA: ${preventivo.cliente.piva} - Cod. Univoco: ${preventivo.cliente.codiceUnivoco}',
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),

              // Dati generali
              pw.Text('Stand: ${preventivo.nomeStand}'),
              pw.Text('Dimensione: ${preventivo.dimensioneStand} mq'),
              pw.Text('Manifestazione: ${preventivo.nomeManifestazione}'),
              pw.Text('Data: ${preventivo.dataManifestazione}'),
              pw.Text(
                'Città: ${preventivo.cittaManifestazione}${preventivo.estero ? " (Estero)" : ""}',
              ),
              pw.SizedBox(height: 12),

              // Tabella
              pw.TableHelper.fromTextArray(
                border: null,
                cellPadding: const pw.EdgeInsets.all(4),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                headers: [
                  'Codice',
                  'Descrizione',
                  'Quantità',
                  'Prezzo',
                  'Totale',
                ],
                data:
                    righe.map((r) {
                      return [
                        r['tipo'] ?? r['codice'],
                        r['descrizione'],
                        '${r['quantita']}',
                        euro.format(r['prezzo']),
                        euro.format(r['quantita'] * r['prezzo']),
                      ];
                    }).toList(),
              ),
              pw.SizedBox(height: 16),

              // Sconto
              if (preventivo.sconto > 0)
                pw.Text("Sconto: -${euro.format(preventivo.sconto)}"),

              // Totali
              pw.Text("Totale parziale: ${euro.format(totaleParziale)}"),
              pw.Text("Totale con IVA: ${euro.format(totaleConIva)}"),
              if (preventivo.acconto > 0)
                pw.Text(
                  "Acconto (${preventivo.acconto.toStringAsFixed(0)}%): ${euro.format(valoreAcconto)}",
                ),
              pw.SizedBox(height: 40),

              if (preventivo.acconto > 0)
                pw.Text(
                  "Acconto (${preventivo.acconto.toStringAsFixed(0)}%) da pagare alla firma del contratto",
                  style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                ),

              pw.SizedBox(height: 40),
              pw.Text("Firma per accettazione ____________________________"),
            ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/preventivo_${preventivo.numero}.pdf");
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([
      XFile(file.path),
    ], text: "Preventivo n. ${preventivo.numero}");
  }

  static Future<void> generaPDFContratto(
    BuildContext context,
    PreventivoModel preventivo,
  ) async {
    final pdf = pw.Document();
    final euro = NumberFormat.currency(locale: 'it_IT', symbol: '€');

    final logoPath = preventivo.azienda.logoPath;
    final imageLogo =
        (logoPath.isNotEmpty && File(logoPath).existsSync())
            ? pw.MemoryImage(File(logoPath).readAsBytesSync())
            : null;

    final totaleParziale = preventivo.prodotti.fold(
      0.0,
      (tot, r) => tot + (r['quantita'] * r['prezzo']),
    );
    final totaleConIva =
        totaleParziale +
        (totaleParziale * preventivo.iva / 100) +
        preventivo.rincaro -
        preventivo.sconto;
    final valoreAcconto = totaleConIva * preventivo.acconto / 100;

    pdf.addPage(
      pw.MultiPage(
        build:
            (context) => [
              if (imageLogo != null)
                pw.Container(height: 60, child: pw.Image(imageLogo)),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  "CONTRATTO",
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),

              pw.Text("Azienda: ${preventivo.azienda.nome}"),
              pw.Text("Cliente: ${preventivo.cliente.nome}"),
              pw.Text(
                "Stand: ${preventivo.nomeStand} - ${preventivo.dimensioneStand} mq",
              ),
              pw.Text(
                "Manifestazione: ${preventivo.nomeManifestazione}, ${preventivo.dataManifestazione}, ${preventivo.cittaManifestazione}",
              ),
              pw.SizedBox(height: 12),

              pw.Text("Totale preventivo: ${euro.format(totaleConIva)}"),
              if (preventivo.acconto > 0)
                pw.Text(
                  "Acconto: ${preventivo.acconto.toStringAsFixed(0)}% - ${euro.format(valoreAcconto)}",
                ),

              pw.SizedBox(height: 30),
              pw.Text("Firma cliente: _____________________________"),
            ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/contratto_${preventivo.numero}.pdf");
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([
      XFile(file.path),
    ], text: "Contratto n. ${preventivo.numero}");
  }
}

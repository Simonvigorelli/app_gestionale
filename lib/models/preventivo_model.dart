import 'package:hive/hive.dart';
import 'azienda_model.dart'; // Ensure correct import paths
import 'cliente_model.dart'; // Ensure correct import paths

part 'preventivo_model.g.dart';

@HiveType(typeId: 3) // Make sure this is unique
class PreventivoModel extends HiveObject {
  @HiveField(0)
  final String id; // Added to match your save logic with Uuid

  @HiveField(1)
  int numero;

  @HiveField(2)
  String data;

  @HiveField(3)
  AziendaModel azienda;

  @HiveField(4)
  ClienteModel cliente;

  @HiveField(5)
  String nomeStand;

  @HiveField(6)
  double dimensioneStand;

  @HiveField(7)
  String nomeManifestazione;

  @HiveField(8)
  String dataManifestazione;

  @HiveField(9)
  String cittaManifestazione;

  @HiveField(10)
  bool estero;

  @HiveField(11)
  List<Map<String, dynamic>> prodotti; // Hive can store List<Map<String, dynamic>>

  @HiveField(12)
  List<Map<String, dynamic>> servizi; // Hive can store List<Map<String, dynamic>>

  @HiveField(13)
  double iva;

  @HiveField(14)
  double rincaro;

  @HiveField(15)
  double acconto;

  @HiveField(16)
  double sconto;

  @HiveField(17)
  double totale;


  PreventivoModel({
    required this.id, // Make sure 'id' is in the constructor
    required this.numero,
    required this.data,
    required this.azienda,
    required this.cliente,
    required this.nomeStand,
    required this.dimensioneStand,
    required this.nomeManifestazione,
    required this.dataManifestazione,
    required this.cittaManifestazione,
    required this.estero,
    required this.prodotti,
    required this.servizi,
    required this.iva,
    required this.rincaro,
    required this.acconto,
    required this.sconto,
    required this.totale,
  });
}
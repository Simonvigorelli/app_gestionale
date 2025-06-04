import 'package:hive/hive.dart';

part 'grafica_model.g.dart';

@HiveType(typeId: 6)
class GraficaModel extends HiveObject {
  @HiveField(0)
  String codice;

  @HiveField(1)
  String descrizione;

  @HiveField(2)
  double prezzo;

  @HiveField(3)
  String tipoPrezzo; // "mq" oppure "pezzo"

  GraficaModel({
    required this.codice,
    required this.descrizione,
    required this.prezzo,
    required this.tipoPrezzo,
  });
}

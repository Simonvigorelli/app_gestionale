import 'package:hive/hive.dart';

part 'azienda_model.g.dart';

@HiveType(typeId: 5)
class AziendaModel extends HiveObject {
  @HiveField(0)
  String nome;

  @HiveField(1)
  String indirizzo;

  @HiveField(2)
  String telefono;

  @HiveField(3)
  String email;

  @HiveField(4)
  String piva;

  @HiveField(5)
  String iban;

  @HiveField(6)
  String codiceUnivoco;

  @HiveField(7)
  String logoPath;

  @HiveField(8)
  String firmaPath;

  AziendaModel({
    required this.nome,
    required this.indirizzo,
    required this.telefono,
    required this.email,
    required this.piva,
    required this.iban,
    required this.codiceUnivoco,
    required this.logoPath, // 👈 AGGIUNTO
    required this.firmaPath,
  });
}

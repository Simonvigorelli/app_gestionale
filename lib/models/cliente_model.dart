import 'package:hive/hive.dart';

part 'cliente_model.g.dart';

@HiveType(typeId: 4)
class ClienteModel extends HiveObject {
  @HiveField(0)
  String nome;

  @HiveField(1)
  String indirizzo;

  @HiveField(2)
  String telefono;

  @HiveField(3)
  String email;

  @HiveField(4)
  String piva; // ✅ Partita IVA

  @HiveField(5)
  String codiceUnivoco;

  ClienteModel({
    required this.nome,
    required this.indirizzo,
    required this.telefono,
    required this.email,
    required this.piva,
    required this.codiceUnivoco,
  });
}

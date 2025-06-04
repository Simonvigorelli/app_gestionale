import 'package:hive/hive.dart';
// Non serve json_annotation a meno che tu non stia usando json_serializable
part 'product_model.g.dart'; // Rimuovi i due slash (//) // Assicurati che questo file sia generato con flutter pub run build_runner build

@HiveType(typeId: 1) // Ho cambiato il typeId a 1. Assicurati che sia unico e non in conflitto con MovementModel (che ora è 2)
class ProductModel extends HiveObject {
  @HiveField(0)
  final String code;
  @HiveField(1)
  final String description;
  @HiveField(2)
  int quantity; // La quantità può cambiare
  @HiveField(3)
  final double price;
  @HiveField(4)
  final List<String>? imagePaths; // Reso nullable esplicitamente
  @HiveField(5)
  final String qrCode; // Questo è il codice QR univoco generato
  @HiveField(6)
  bool isInTransit; // Campo per indicare se il prodotto è in transito/in uscita

  // --- NUOVO CAMPO ---
  @HiveField(7) // Usa il prossimo campo disponibile
  String? currentMovementId; // ID del movimento di uscita corrente (null se non in transito)

  ProductModel({
    required this.code,
    required this.description,
    required this.quantity,
    required this.price,
    this.imagePaths, // Non required
    required this.qrCode,
    this.isInTransit = false, // Valore predefinito: non in transito
    this.currentMovementId, // Aggiunto al costruttore
  });

  // Factory per creare ProductModel da una Map (Firestore)
  factory ProductModel.fromFirestore(Map<String, dynamic> data) {
    return ProductModel(
      code: data['code'] as String? ?? '', // Cast espliciti e null check
      description: data['description'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0, // Gestisci sia int che double da Firestore
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imagePaths: data['imagePaths'] != null
          ? (data['imagePaths'] as List<dynamic>).map((e) => e.toString()).toList()
          : null,
      qrCode: data['qrCode'] as String? ?? '',
      isInTransit: data['isInTransit'] as bool? ?? false,
      currentMovementId: data['currentMovementId'] as String?, // Leggi il nuovo campo
    );
  }

  // Metodo per convertire ProductModel in una Map (Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'description': description,
      'quantity': quantity,
      'price': price,
      'imagePaths': imagePaths,
      'qrCode': qrCode,
      'isInTransit': isInTransit,
      'currentMovementId': currentMovementId, // Scrivi il nuovo campo
    };
  }

  // Metodo copyWith per creare una nuova istanza con valori modificati
  ProductModel copyWith({
    String? code,
    String? description,
    int? quantity,
    double? price,
    List<String>? imagePaths,
    String? qrCode,
    bool? isInTransit,
    String? currentMovementId, // Aggiunto al copyWith
  }) {
    return ProductModel(
      code: code ?? this.code,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      imagePaths: imagePaths ?? this.imagePaths,
      qrCode: qrCode ?? this.qrCode,
      isInTransit: isInTransit ?? this.isInTransit,
      currentMovementId: currentMovementId ?? this.currentMovementId, // Aggiorna il nuovo campo
    );
  }
}
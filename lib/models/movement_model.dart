// lib/models/movement_model.dart
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Necessario per Timestamp

part 'movement_model.g.dart';

@HiveType(typeId: 2) // O il typeId che hai scelto per MovementModel
class MovementModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String productCode;
  @HiveField(2)
  String productDescription;
  @HiveField(3)
  String manifestation;
  @HiveField(4)
  String? stand;
  @HiveField(5)
  int quantity;
  @HiveField(6)
  DateTime dateOut;
  @HiveField(7)
  DateTime? dateIn;

  MovementModel({
    required this.id,
    required this.productCode,
    required this.productDescription,
    required this.manifestation,
    this.stand,
    required this.quantity,
    required this.dateOut,
    this.dateIn,
  });

  factory MovementModel.fromFirestore(Map<String, dynamic> data) {
    return MovementModel(
      id: data['id'] as String? ?? '',
      productCode: data['productCode'] as String? ?? '',
      productDescription: data['productDescription'] as String? ?? '',
      manifestation: data['manifestation'] as String? ?? '',
      stand: data['stand'] as String?,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      dateOut: (data['dateOut'] as Timestamp).toDate(),
      dateIn: (data['dateIn'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'productCode': productCode,
      'productDescription': productDescription,
      'manifestation': manifestation,
      'stand': stand,
      'quantity': quantity,
      'dateOut': Timestamp.fromDate(dateOut),
      'dateIn': dateIn != null ? Timestamp.fromDate(dateIn!) : null,
    };
  }

  MovementModel copyWith({
    String? id,
    String? productCode,
    String? productDescription,
    String? manifestation,
    String? stand,
    int? quantity,
    DateTime? dateOut,
    DateTime? dateIn,
  }) {
    return MovementModel(
      id: id ?? this.id,
      productCode: productCode ?? this.productCode,
      productDescription: productDescription ?? this.productDescription,
      manifestation: manifestation ?? this.manifestation,
      stand: stand ?? this.stand,
      quantity: quantity ?? this.quantity,
      dateOut: dateOut ?? this.dateOut,
      dateIn: dateIn ?? this.dateIn,
    );
  }
}
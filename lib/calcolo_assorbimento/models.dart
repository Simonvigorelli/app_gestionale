class Stand {
  String name;
  int area;
  List<Device> devices;

  Stand({required this.name, required this.area, required this.devices});

  Map<String, dynamic> toJson() => {
        'name': name,
        'area': area,
        'devices': devices.map((d) => d.toJson()).toList(),
      };

  factory Stand.fromJson(Map<String, dynamic> json) {
    return Stand(
      name: json['name'],
      area: json['area'],
      devices:
          (json['devices'] as List).map((d) => Device.fromJson(d)).toList(),
    );
  }
}

class Device {
  String name;
  int quantity;
  double power;
  int? length;

  Device(
      {required this.name,
      required this.quantity,
      required this.power,
      this.length});

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'power': power,
        'length': length,
      };

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      name: json['name'],
      quantity: json['quantity'],
      power: (json['power'] as num).toDouble(),
      length: json['length'],
    );
  }
}

class TransformerModel {
  String name;
  String inputVoltage; // Es. "100-240V AC, 2.2A, 50/60 Hz"
  double inputCurrent; // Es. 2.2A
  String frequency; // Es. "50/60 Hz"
  double outputVoltage; // Es. 24V
  double outputCurrent; // Es. 10A
  double outputPower; // Es. 240W
  double efficiency; // Es. 92%
  double maxMeters; // Metri supportati

  TransformerModel({
    required this.name,
    required this.inputVoltage,
    required this.inputCurrent,
    required this.frequency,
    required this.outputVoltage,
    required this.outputCurrent,
    required this.outputPower,
    required this.efficiency,
  }) : maxMeters =
            (outputPower / outputVoltage).clamp(0, 100); // Calcola metri LED

  Map<String, dynamic> toJson() => {
        'name': name,
        'inputVoltage': inputVoltage,
        'inputCurrent': inputCurrent,
        'frequency': frequency,
        'outputVoltage': outputVoltage,
        'outputCurrent': outputCurrent,
        'outputPower': outputPower,
        'efficiency': efficiency,
        'maxMeters': maxMeters,
      };

  factory TransformerModel.fromJson(Map<String, dynamic> map) {
    return TransformerModel(
      name: map['name'],
      inputVoltage: map['inputVoltage'],
      inputCurrent: (map['inputCurrent'] as num).toDouble(),
      frequency: map['frequency'],
      outputVoltage: (map['outputVoltage'] as num).toDouble(),
      outputCurrent: (map['outputCurrent'] as num).toDouble(),
      outputPower: (map['outputPower'] as num).toDouble(),
      efficiency: (map['efficiency'] as num).toDouble(),
    );
  }
}

class Transformer {
  String name;
  double capacity;

  Transformer({required this.name, required this.capacity});

  Map<String, dynamic> toJson() => {'name': name, 'capacity': capacity};

  factory Transformer.fromJson(Map<String, dynamic> json) => Transformer(
      name: json['name'], capacity: (json['capacity'] as num).toDouble());
}

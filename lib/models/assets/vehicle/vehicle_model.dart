class Vehicle {
  final String model;
  final String vrn;
  final String motValue;
  final String insuranceValue;
  final String vehicleType;
  final String ownerName;
  final double purchasePrice;
  final String purchaseDate;
  final String motDate;
  final double mileage;
  final String insuranceDate;
  String? imageURL; // Changed to nullable and mutable
  final String createdBy;
  final String createdDate;
  final String lastModifiedBy;
  final String lastModifiedDate;
  final String motExpiredDate;
  final String id;
  final String links;

  Vehicle({
    required this.model,
    required this.vrn,
    required this.motValue,
    required this.insuranceValue,
    required this.ownerName,
    required this.vehicleType,
    required this.purchasePrice,
    required this.purchaseDate,
    required this.motDate,
    required this.insuranceDate,
    this.imageURL,
    required this.createdBy,
    required this.createdDate,
    required this.lastModifiedBy,
    required this.lastModifiedDate,
    required this.mileage,
    required this.motExpiredDate,
    required this.links,
    required this.id,
  });

  /// **✅ Convert JSON to `Vehicle` object**
  factory Vehicle.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError("JSON cannot be null");
    }

    // Safely extract the ID from links
    String extractedId = '';
    try {
      if (json['_links'] != null &&
          json['_links']['self'] != null &&
          json['_links']['self']['href'] != null) {
        final href = json['_links']['self']['href'] as String;
        extractedId = Uri.parse(href).pathSegments.last;
      }
    } catch (e) {
      extractedId = 'unknown-id';
    }

    return Vehicle(
      model: json['model'] ?? 'Unknown',
      vehicleType: json['vehicle_type'] ?? 'Unknown',
      vrn: json['vrn'] ?? 'Unknown',
      motValue: json['motValue'] ?? 'N/A',
      insuranceValue: json['insuranceValue'] ?? 'N/A',
      ownerName: json['owner_name'] ?? 'N/A',
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      purchaseDate: json['purchaseDate'] ?? 'N/A',
      motDate: json['motDate'] ?? 'N/A',
      insuranceDate: json['insuranceDate'] ?? 'N/A',
      imageURL: json['imageURL'], // Keep as nullable
      createdBy: json['createdBy'] ?? 'Unknown',
      createdDate: json['createdDate'] ?? 'N/A',
      lastModifiedBy: json['lastModifiedBy'] ?? 'Unknown',
      lastModifiedDate: json['lastModifiedDate'] ?? 'N/A',
      motExpiredDate: json['motExpiredDate'] ?? 'N/A',
      links: json['_links']?['self']?['href'] ?? 'N/A',
      mileage: (json['mileage'] as num?)?.toDouble() ?? 0.0,
      id: json['id'] ?? extractedId,
    );
  }

  /// **✅ Convert `Vehicle` object to JSON**
  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'vrn': vrn,
      'motValue': motValue,
      'insuranceValue': insuranceValue,
      'vehicle_type': vehicleType,
      'owner_name': ownerName,
      'purchasePrice': purchasePrice,
      'purchaseDate': purchaseDate,
      'motDate': motDate,
      'insuranceDate': insuranceDate,
      'imageURL': imageURL,
      'createdBy': createdBy,
      'createdDate': createdDate,
      'lastModifiedBy': lastModifiedBy,
      'lastModifiedDate': lastModifiedDate,
      'mileage': mileage,
      'motExpiredDate': motExpiredDate,
      'id': id
    };
  }
}
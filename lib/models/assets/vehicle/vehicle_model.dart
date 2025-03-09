class Vehicle {
  final String model;
  final String vrn;
  final String motValue;
  final String insuranceValue;
  final String vehicleCategory;
  final String ownerName;
  final bool isActive;
  final double purchasePrice;
  final String purchaseDate;
  final String motDate;
  final String Milage;
  final String insuranceDate;
  final String imageURL;
  final String createdBy;
  final String createdDate;
  final String lastModifiedBy;
  final String lastModifiedDate;
  final String motExpiredDate;

  Vehicle({
    required this.model,
    required this.vrn,
    required this.motValue,
    required this.insuranceValue,
    required this.vehicleCategory,
    required this.ownerName,
    required this.isActive,
    required this.purchasePrice,
    required this.purchaseDate,
    required this.motDate,
    required this.insuranceDate,
    required this.imageURL,
    required this.createdBy,
    required this.createdDate,
    required this.lastModifiedBy,
    required this.lastModifiedDate,
    required this.Milage,
    required this.motExpiredDate
  });

  /// **✅ Convert JSON to `Vehicle` object**
  factory Vehicle.fromJson(Map<String, dynamic>? json) {
    return Vehicle(
      model: json?['model'] ?? 'Unknown',
      vrn: json?['vrn'] ?? 'Unknown',
      motValue: json?['motValue'] ?? 'N/A',
      insuranceValue: json?['insuranceValue'] ?? 'N/A',
      vehicleCategory: json?['vehicleCategory'] ?? 'N/A',
      ownerName: json?['owner_name'] ?? 'N/A',
      isActive: json?['isActive'] ?? false,
      purchasePrice: (json?['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      purchaseDate: json?['purchaseDate'] ?? 'N/A',
      motDate: json?['motDate'] ?? 'N/A',
      insuranceDate: json?['insuranceDate'] ?? 'N/A',
      imageURL: json?['imageURL'] ?? '',
      createdBy: json?['createdBy'] ?? 'Unknown',
      createdDate: json?['createdDate'] ?? 'N/A',
      lastModifiedBy: json?['lastModifiedBy'] ?? 'Unknown',
      lastModifiedDate: json?['lastModifiedDate'] ?? 'N/A',
      motExpiredDate: json?['motExpiredDate'] ?? 'N/A',
      Milage: json?['Milege'] ?? 'N/A',
    );
  }

  /// **✅ Convert `Vehicle` object to JSON**
  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'vrn': vrn,
      'motValue': motValue,
      'insuranceValue': insuranceValue,
      'vehicleCategory': vehicleCategory,
      'owner_name': ownerName, // ✅ Ensures correct key format
      'isActive': isActive,
      'purchasePrice': purchasePrice,
      'purchaseDate': purchaseDate,
      'motDate': motDate,
      'insuranceDate': insuranceDate,
      'imageURL': imageURL,
      'createdBy': createdBy,
      'createdDate': createdDate,
      'lastModifiedBy': lastModifiedBy,
      'lastModifiedDate': lastModifiedDate,
      'Milege': Milage,
      'motExpiredDate': motExpiredDate,
      'type': 'Vehicle', // ✅ Ensures type is set for filtering
    };
  }

  get rating => null;


}

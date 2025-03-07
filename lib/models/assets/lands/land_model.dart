class Land {
  final String landName;
  final String landType;
  final double landSize;
  final String landAddress;
  final String landCity;
  final String landProvince;
  final String purchaseDate; // Keeping it as String for flexibility
  final double purchasePrice;
  final String landImage;

  Land({
    required this.landName,
    required this.landType,
    required this.landSize,
    required this.landAddress,
    required this.landCity,
    required this.landProvince,
    required this.purchaseDate,
    required this.purchasePrice,
    required this.landImage,
  });

  /// **✅ Convert JSON to `Land` object**
  factory Land.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError("JSON data cannot be null");
    }

    return Land(
      landName: json['landName']?.toString() ?? 'Unknown',
      landType: json['landType']?.toString() ?? 'Unknown',
      landSize: (json['landSize'] as num?)?.toDouble() ?? 0.0,
      landAddress: json['landAddress']?.toString() ?? 'Unknown',
      landCity: json['landCity']?.toString() ?? 'Unknown',
      landProvince: json['landProvince']?.toString() ?? 'Unknown',
      purchaseDate: json['purchaseDate']?.toString() ?? 'N/A', // Ensuring String
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      landImage: json['landImage']?.toString() ?? '',
    );
  }

  /// **✅ Convert `Land` object to JSON**
  Map<String, dynamic> toJson() {
    return {
      'landName': landName,
      'landType': landType,
      'landSize': landSize,
      'landAddress': landAddress,
      'landCity': landCity,
      'landProvince': landProvince,
      'purchaseDate': purchaseDate, // Keeping as String
      'purchasePrice': purchasePrice,
      'landImage': landImage,
    };
  }
}

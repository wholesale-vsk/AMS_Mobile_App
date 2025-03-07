class Land {
  final String name;
  final String type;
  final double size;
  final String address;
  final String city;
  final String province;
  final String purchaseDate;
  final double purchasePrice;
  final String imageURL;

  Land({
    required this.name,
    required this.type,
    required this.size,
    required this.address,
    required this.city,
    required this.province,
    required this.purchaseDate,
    required this.purchasePrice,
    required this.imageURL,
  });

  /// **✅ Convert JSON to `Land` object**
  factory Land.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError("❌ JSON data is null, cannot parse `Land` object.");
    }

    return Land(
      name: json['name'] ?? 'Unknown',
      type: json['type'] ?? 'Unknown',
      size: (json['size'] is num) ? (json['size'] as num).toDouble() : 0.0,
      address: json['address'] ?? 'Unknown',
      city: json['city'] ?? 'Unknown',
      province: json['province'] ?? 'Unknown',
      purchaseDate: json['purchaseDate'] ?? 'N/A',
      purchasePrice: (json['purchasePrice'] is num) ? (json['purchasePrice'] as num).toDouble() : 0.0,
      imageURL: json['imageURL'] is String ? json['imageURL'] : "",
    );
  }

  /// **✅ Convert `Land` object to JSON**
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'size': size,
      'address': address,
      'city': city,
      'province': province,
      'purchaseDate': purchaseDate,
      'purchasePrice': purchasePrice,
      'imageURL': imageURL,
      'category': 'Land', // ✅ Ensures filtering works
    };
  }
}

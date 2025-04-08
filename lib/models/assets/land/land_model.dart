class Land {
  final String name;
  final String landType;
  final double landSize;
  final String address;
  final String city;
  final String province;
  final String purchaseDate;
  final double purchasePrice;
  final String leaseDate;
  final double leaseValue;
  final String links;
  String? imageURL; // Changed to nullable and mutable

  Land({
    required this.name,
    required this.landType,
    required this.landSize,
    required this.address,
    required this.city,
    required this.province,
    required this.purchaseDate,
    required this.purchasePrice,
    required this.leaseDate,
    required this.leaseValue,

    required this.links,
    this.imageURL, // Add as optional parameter
  });

  /// **✅ Convert JSON to `Land` object**
  factory Land.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError("❌ JSON data is null, cannot parse `Land` object.");
    }

    return Land(
      name: json['name'] ?? 'Unknown',
      landType: json['landType'] ?? 'Unknown',
      landSize: (json['landSize'] is num) ? (json['landSize'] as num).toDouble() : 0.0,
      address: json['address'] ?? 'Unknown',
      city: json['city'] ?? 'Unknown',
      province: json['province'] ?? 'Unknown',
      purchaseDate: json['purchaseDate'] ?? 'N/A',
      purchasePrice: (json['purchasePrice'] is num) ? (json['purchasePrice'] as num).toDouble() : 0.0,
      leaseDate: json['lease_date'] ?? 'N/A',
      leaseValue: json['leaseValue'] ?? 'N/A',
      imageURL: json['imageURL'] is String ? json['imageURL'] : "",
      links: json['_links']['self']['href'] ?? 'N/A',

    );
  }

















  /// **✅ Convert `Land` object to JSON**
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': landType,
      'landSize': landSize,
      'address': address,
      'city': city,
      'province': province,
      'purchaseDate': purchaseDate,
      'purchasePrice': purchasePrice,
      'lease_date': leaseDate,
      'leaseValue': leaseValue,
      'imageURL': imageURL ,
      'links': links,
      'category': 'Land', // ✅ Ensures filtering works
    };
  }
}

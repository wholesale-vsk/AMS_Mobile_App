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
  String? imageURL; // Add this field

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
    this.imageURL, // Optional parameter
  });

  /// **✅ Convert JSON to `Land` object**
  factory Land.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError("❌ JSON data is null, cannot parse `Land` object.");
    }

    // Extract image path
    final String imagePath = json['landImage']?.toString() ?? json['imageURL']?.toString() ?? '';

    // Safely extract links
    String extractedLinks = 'N/A';
    try {
      if (json['_links'] != null &&
          json['_links']['self'] != null &&
          json['_links']['self']['href'] != null) {
        extractedLinks = json['_links']['self']['href'];
      }
    } catch (e) {
      // Use default value if anything goes wrong
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
      leaseValue: (json['leaseValue'] is num) ? (json['leaseValue'] as num).toDouble() : 0.0,
      imageURL: json['imageURL']?.toString() ?? imagePath,
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
      'links': links,
      'category': 'Land', // ✅ Ensures filtering works
    };
  }
}
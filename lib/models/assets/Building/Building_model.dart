class Building {
  final String name;
  final String buildingType;
  final int numberOfFloors;
  final double totalArea;
  final String city;
  final String address;
  final String province;
  final String ownerName;
  final String purchaseDate;
  final String constructionType;
  final double constructionCost;
  final DateTime? constructionDate;
  final String imageURL;

  Building({
    required this.name,
    required this.buildingType,
    required this.numberOfFloors,
    required this.totalArea,
    required this.city,
    required this.address,
    required this.province,
    required this.purchaseDate,
    required this.ownerName,
    required this.constructionType,
    required this.constructionCost,
    this.constructionDate,
    required this.imageURL,
  });

  factory Building.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError("JSON data cannot be null");
    }

    return Building(
      name: json['name']?.toString() ?? 'Unknown',
      buildingType: json['buildingType']?.toString() ?? 'Unknown',
      numberOfFloors: _parseInt(json['numberOfFloors']),
      totalArea: _parseDouble(json['totalArea']),
      address: json['address']?.toString() ?? 'Unknown',
      city: json['city']?.toString() ?? 'Unknown',
      province: json['province']?.toString() ?? 'Unknown',
      ownerName: json['ownerName']?.toString() ?? 'Unknown',
      constructionType: json['constructionType']?.toString() ?? 'Unknown',
      constructionCost: _parseDouble(json['constructionCost']),
      purchaseDate: json['purchaseDate']?.toString() ?? 'N/A',
      constructionDate: _parseDate(json['constructionDate']),

      imageURL: json?['imageUrl'] ?? '', // ✅ If API uses lowercase "imageUrl"

    );
  }

  get buildingName => null;

  // Utility function to safely parse integers
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Utility function to safely parse doubles
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Utility function to safely parse dates
  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

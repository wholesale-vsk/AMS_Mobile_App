import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../../models/assets/vehicle/vehicle_model.dart';

class LoadVehicleService {
  final FlutterSecureStorage _secureStorage;
  final Dio _dio;
  final Logger _logger = Logger();
  final String _imageBaseUrl = "http://149.102.154.118:9000";

  LoadVehicleService({FlutterSecureStorage? secureStorage, Dio? dio})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _dio = dio ?? Dio(BaseOptions(
          baseUrl: "https://api.ams.hexalyte.com",
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  /// **🚗 Fetch paginated vehicles from API**
  /// - `page` = current page number (default: 1)
  /// - `pageSize` = number of vehicles per page (default: 20)
  Future<Map<String, dynamic>> fetchVehicles({int page = 1, int pageSize = 100}) async {
    _logger.i('🚗 Fetching vehicles... Page: $page, Limit: $pageSize');

    try {
      String? accessToken = await _secureStorage.read(key: 'access_token');
      if (accessToken == null) {
        _logger.e("❌ Access token missing. Please log in again.");
        throw Exception("❌ Access token missing. Please log in again.");
      }

      // Update Authorization token dynamically
      _dio.options.headers['Authorization'] = 'Bearer $accessToken';

      _logger.d("📤 Sending GET request to: ${_dio.options.baseUrl}/vehicle/vehicles");

      final response = await _dio.get(
        "/vehicle/vehicles",
        queryParameters: {
          "page": page - 1, // Convert to zero-based index for API
          "size": pageSize,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        _logger.i('✅ Vehicles fetched successfully.');

        final List<dynamic> vehiclesJson = response.data['_embedded']?['vehicles'] ?? [];
        final int totalElements = int.tryParse(response.data['page']?['totalElements']?.toString() ?? "0") ?? 0;
        final int totalPages = int.tryParse(response.data['page']?['totalPages']?.toString() ?? "1") ?? 1;

        _logger.d("📌 Total Vehicles: $totalElements, Total Pages: $totalPages");

        if (vehiclesJson.isEmpty) {
          _logger.w("⚠️ No vehicles found on this page.");
          return {
            'totalElements': totalElements,
            'totalPages': totalPages,
            'currentPage': page,
            'vehicles': []
          };
        }

        // Convert JSON to List<Vehicle> and preprocess image URLs
        List<Vehicle> vehicles = await Future.wait(vehiclesJson.map((json) async {
          Vehicle vehicle = Vehicle.fromJson(json);

          // Process the image URL if it exists - now using authenticated URLs
          if (vehicle.imageURL != null && vehicle.imageURL!.isNotEmpty) {
            vehicle.imageURL = await getAuthenticatedImageUrl(vehicle.imageURL);
          }

          return vehicle;
        }));

        return {
          'totalElements': totalElements,
          'totalPages': totalPages,
          'currentPage': page,
          'vehicles': vehicles
        };
      } else {
        _logger.e("❌ API Error: ${response.statusCode}, Response: ${response.data}");
        return {
          'totalElements': 0,
          'totalPages': 0,
          'currentPage': page,
          'vehicles': []
        };
      }
    } on DioException catch (dioError) {
      _logger.e("❌ DioException: ${dioError.response?.statusCode} - ${dioError.message}");
      return {
        'totalElements': 0,
        'totalPages': 0,
        'currentPage': page,
        'vehicles': [],
        'error': dioError.message
      };
    } catch (e) {
      _logger.e("❌ Unexpected Error: $e");
      return {
        'totalElements': 0,
        'totalPages': 0,
        'currentPage': page,
        'vehicles': [],
        'error': e.toString()
      };
    }
  }

  /// **🚙 Fetch a single vehicle by ID**
  Future<Vehicle?> fetchVehicleById(String vehicleId) async {
    _logger.i('🚙 Fetching vehicle with ID: $vehicleId');

    try {
      String? accessToken = await _secureStorage.read(key: 'access_token');
      if (accessToken == null) {
        _logger.e("❌ Access token missing. Please log in again.");
        throw Exception("❌ Access token missing. Please log in again.");
      }

      // Update Authorization token dynamically
      _dio.options.headers['Authorization'] = 'Bearer $accessToken';

      final response = await _dio.get("/vehicle/vehicles/$vehicleId");

      if (response.statusCode == 200 && response.data != null) {
        _logger.i('✅ Vehicle fetched successfully.');

        Vehicle vehicle = Vehicle.fromJson(response.data);

        // Process the image URL if it exists
        if (vehicle.imageURL != null && vehicle.imageURL!.isNotEmpty) {
          vehicle.imageURL = await getAuthenticatedImageUrl(vehicle.imageURL);
        }

        return vehicle;
      } else {
        _logger.e("❌ API Error: ${response.statusCode}, Response: ${response.data}");
        return null;
      }
    } on DioException catch (dioError) {
      _logger.e("❌ DioException: ${dioError.response?.statusCode} - ${dioError.message}");
      return null;
    } catch (e) {
      _logger.e("❌ Unexpected Error: $e");
      return null;
    }
  }

  /// **🔍 Search vehicles by registration number, owner, or model**
  Future<List<Vehicle>> searchVehicles(String query) async {
    _logger.i('🔍 Searching vehicles with query: $query');

    try {
      String? accessToken = await _secureStorage.read(key: 'access_token');
      if (accessToken == null) {
        _logger.e("❌ Access token missing. Please log in again.");
        throw Exception("❌ Access token missing. Please log in again.");
      }

      // Update Authorization token dynamically
      _dio.options.headers['Authorization'] = 'Bearer $accessToken';

      final response = await _dio.get(
        "/vehicle/vehicles/search",
        queryParameters: {"query": query},
      );

      if (response.statusCode == 200 && response.data != null) {
        _logger.i('✅ Search results fetched successfully.');

        final List<dynamic> vehiclesJson = response.data ?? [];

        if (vehiclesJson.isEmpty) {
          _logger.w("⚠️ No vehicles found matching the search criteria.");
          return [];
        }

        // Convert JSON to List<Vehicle> and preprocess image URLs
        List<Vehicle> vehicles = await Future.wait(vehiclesJson.map((json) async {
          Vehicle vehicle = Vehicle.fromJson(json);

          // Process the image URL if it exists
          if (vehicle.imageURL != null && vehicle.imageURL!.isNotEmpty) {
            vehicle.imageURL = await getAuthenticatedImageUrl(vehicle.imageURL);
          }

          return vehicle;
        }));

        return vehicles;
      } else {
        _logger.e("❌ API Error: ${response.statusCode}, Response: ${response.data}");
        return [];
      }
    } on DioException catch (dioError) {
      _logger.e("❌ DioException: ${dioError.response?.statusCode} - ${dioError.message}");
      return [];
    } catch (e) {
      _logger.e("❌ Unexpected Error: $e");
      return [];
    }
  }

  /// Process the image URL to ensure it's a full URL
  String _processImageUrl(String imageUrl) {
    // If it's already a full URL, return it as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // Check if this is a local cache path mistakenly used as a URL
    if (imageUrl.contains('data/user/0/com.example.hexalyte_ams/cache')) {
      _logger.w("⚠️ Detected local cache path in URL: $imageUrl");
      // Extract the image ID if possible
      try {
        final filename = imageUrl.split('/').last;
        // If it's a scaled image, try to get the original ID
        if (filename.startsWith('scaled_')) {
          final imageId = filename.replaceAll('scaled_', '').replaceAll('.jpg', '');
          return '$_imageBaseUrl/images/$imageId';
        }
      } catch (e) {
        _logger.e("❌ Error processing cache path: $e");
      }
      // If we can't extract an ID, return empty to use default image
      return '';
    }

    // Remove leading slash if present
    final cleanPath = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;

    // Combine with base URL
    return '$_imageBaseUrl/$cleanPath';
  }

  /// Get the full image URL with authentication if needed
  Future<String?> getAuthenticatedImageUrl(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return ''; // Return empty string for null or empty paths
    }

    // First, ensure it's a proper image path (not a local cache path)
    if (imagePath.contains('data/user/0/com.example.hexalyte_ams/cache')) {
      _logger.w("⚠️ Detected local cache path in URL: $imagePath");
      // Extract the image ID if possible
      try {
        final filename = imagePath.split('/').last;
        // If it's a scaled image, try to get the original ID
        if (filename.startsWith('scaled_')) {
          final imageId = filename.replaceAll('scaled_', '').replaceAll('.jpg', '');
          imagePath = 'images/$imageId';
        } else {
          // Can't process this path properly
          return '';
        }
      } catch (e) {
        _logger.e("❌ Error processing cache path: $e");
        return '';
      }
    }

    // If the image path is already a full URL from our server, check if it has authentication
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      if (imagePath.contains(_imageBaseUrl) && !imagePath.contains('token=')) {
        // It's our server but missing authentication - extract the path
        try {
          final uri = Uri.parse(imagePath);
          imagePath = uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;
        } catch (e) {
          _logger.e("❌ Error parsing image URL: $e");
          return  imagePath; // Return as is if we can't parse it
        }
      } else {
        // It's either already authenticated or from another server
        return imagePath;
      }
    }

    // Remove leading slash if present
    final cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;

    try {
      // Get access token if needed for authenticated images
      String? accessToken = await _secureStorage.read(key: 'access_token');

      // Build the full URL (with token if available)
      if (accessToken != null && accessToken.isNotEmpty) {
        // For authenticated image access
        return '$_imageBaseUrl/$cleanPath?token=$accessToken';
      } else {
        // For public image access
        return '$_imageBaseUrl/$cleanPath';
      }
    } catch (e) {
      _logger.e("❌ Error getting authenticated image URL: $e");
      // Return the basic URL if there's an error
      return '$_imageBaseUrl/$cleanPath';
    }
  }

  /// Get current access token - helper method for UI components
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }
}
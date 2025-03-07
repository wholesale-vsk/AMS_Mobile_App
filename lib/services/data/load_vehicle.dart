import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/assets/vehicle/vehicle_model.dart';

class LoadVehicleService {
  final FlutterSecureStorage _secureStorage;
  final Dio _dio;

  LoadVehicleService({FlutterSecureStorage? secureStorage, Dio? dio})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _dio = dio ?? Dio(BaseOptions(
          baseUrl: "https://api.ams.hexalyte.com",
          headers: {'Content-Type': 'application/json'},
          connectTimeout: Duration(seconds: 10),
          receiveTimeout: Duration(seconds: 10),
        ));

  /// **🚗 Fetch paginated vehicles from API**
  /// - `page` = current page number (default: 1)
  /// - `pageSize` = number of vehicles per page (default: 20)
  Future<Map<String, dynamic>> fetchVehicles({int page = 1, int pageSize = 20}) async {
    print('🚗 Fetching vehicles... Page: $page, Limit: $pageSize');

    try {
      String? accessToken = await _secureStorage.read(key: 'access_token');
      if (accessToken == null) {
        throw Exception("❌ Access token missing. Please log in again.");
      }

      // Update Authorization token dynamically
      _dio.options.headers['Authorization'] = 'Bearer $accessToken';

      print("📤 Sending GET request to: ${_dio.options.baseUrl}/vehicle/vehicles");

      final response = await _dio.get(
        "/vehicle/vehicles",
        queryParameters: {
          "page": page - 1, // Convert to zero-based index for API
          "size": pageSize,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        print('✅ Vehicles fetched successfully.');

        final List<dynamic> vehiclesJson = response.data['_embedded']?['vehicles'] ?? [];
        final int totalElements = int.tryParse(response.data['page']?['totalElements']?.toString() ?? "0") ?? 0;
        final int totalPages = int.tryParse(response.data['page']?['totalPages']?.toString() ?? "1") ?? 1;

        print("📌 Total Vehicles: $totalElements, Total Pages: $totalPages");

        if (vehiclesJson.isEmpty) {
          print("⚠️ No vehicles found on this page.");
          return {
            'totalElements': totalElements,
            'totalPages': totalPages,
            'currentPage': page,
            'vehicles': []
          };
        }

        // Convert JSON to List<Vehicle>
        List<Vehicle> vehicles = vehiclesJson.map((json) => Vehicle.fromJson(json)).toList();

        return {
          'totalElements': totalElements,
          'totalPages': totalPages,
          'currentPage': page,
          'vehicles': vehicles
        };
      } else {
        print("❌ API Error: ${response.statusCode}, Response: ${response.data}");
        return {
          'totalElements': 0,
          'totalPages': 0,
          'currentPage': page,
          'vehicles': []
        };
      }
    } on DioException catch (dioError) {
      print("❌ DioException: ${dioError.response?.statusCode} - ${dioError.message}");
      return {
        'totalElements': 0,
        'totalPages': 0,
        'currentPage': page,
        'vehicles': []
      };
    } catch (e) {
      print("❌ Unexpected Error: $e");
      return {
        'totalElements': 0,
        'totalPages': 0,
        'currentPage': page,
        'vehicles': []
      };
    }
  }
}

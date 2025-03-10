import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/assets/building/building_model.dart';

class LoadBuildingService {
  final FlutterSecureStorage _secureStorage;
  final Dio _dio;

  LoadBuildingService({FlutterSecureStorage? secureStorage, Dio? dio})
      : _secureStorage = secureStorage ?? FlutterSecureStorage(),
        _dio = dio ?? Dio(BaseOptions(
          baseUrl: "https://api.ams.hexalyte.com", // ✅ Ensure no trailing slash
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    // ✅ Enable debugging with Dio Interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print("📤 Request: ${options.method} ${options.baseUrl}${options.path}");
        print("🔑 Headers: ${options.headers}");
        handler.next(options);
      },
      onResponse: (response, handler) {
        print("✅ Response: ${response.statusCode}");
        handler.next(response);
      },
      onError: (DioException e, handler) {
        print("❌ Error: ${e.response?.statusCode} - ${e.message}");
        handler.next(e);
      },
    ));
  }

  /// **🏗 Fetch paginated buildings from API**
  /// - `page` = current page number (default: 1)
  /// - `size` = number of buildings per page (default: 20)
  Future<Map<String, dynamic>> fetchBuildings({int page = 1, int size = 100}) async {
    print('🏗 Fetching Buildings - Page: $page, Size: $size');

    try {
      final String? accessToken = await _secureStorage.read(key: 'access_token');

      if (accessToken == null) {
        throw Exception("❌ Access token missing. Please log in again.");
      }

      // ✅ Add Authorization token dynamically
      _dio.options.headers['Authorization'] = 'Bearer $accessToken';

      // 📤 Send GET request
      final response = await _dio.get(
        "/asset/assets",
        queryParameters: {
          "page": page - 1, // ✅ Convert to zero-based index
          "size": size,
        },
      );

      // ✅ Handle successful response
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> buildingsJson = response.data['_embedded']?['assets'] ?? [];
        final int totalElements = int.tryParse(response.data['page']?['totalElements']?.toString() ?? "0") ?? 0;
        final int totalPages = int.tryParse(response.data['page']?['totalPages']?.toString() ?? "1") ?? 1;

        print("📌 Total Buildings: $totalElements, Total Pages: $totalPages");

        if (buildingsJson.isEmpty) {
          print("⚠️ No buildings found on this page.");
          return {
            'totalElements': totalElements,
            'totalPages': totalPages,
            'currentPage': page,
            'buildings': []
          };
        }

        // ✅ Convert JSON to List<Building>
        List<Building> buildings = buildingsJson.map((json) => Building.fromJson(json)).toList();

        return {
          'totalElements': totalElements,
          'totalPages': totalPages,
          'currentPage': page,
          'buildings': buildings
        };
      } else {
        print("❌ API Error: ${response.statusCode}, Response: ${response.data}");
        return {
          'totalElements': 0,
          'totalPages': 0,
          'currentPage': page,
          'buildings': []
        };
      }
    } on DioException catch (dioError) {
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout) {
        print("⏳ Timeout Error: ${dioError.message}");
      } else if (dioError.type == DioExceptionType.badResponse) {
        print("❌ API Response Error: ${dioError.response?.statusCode} - ${dioError.response?.data}");
      } else {
        print("❌ DioException: ${dioError.message}");
      }
      return {
        'totalElements': 0,
        'totalPages': 0,
        'currentPage': page,
        'buildings': []
      };
    } catch (e) {
      print("❌ Unexpected Error: $e");
      return {
        'totalElements': 0,
        'totalPages': 0,
        'currentPage': page,
        'buildings': []
      };
    }
  }
}

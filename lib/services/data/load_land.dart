import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/assets/land/land_model.dart';

class LoadLandsService {
  final FlutterSecureStorage _secureStorage;
  final Dio _dio;

  LoadLandsService({FlutterSecureStorage? secureStorage, Dio? dio})
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

  /// **🏡 Fetch paginated lands from API**
  /// - `page` = current page number (default: 1)
  /// - `size` = number of lands per page (default: 20)
  Future<Map<String, dynamic>> fetchLands({int page = 1, int size = 100}) async {
    print('🏡 Fetching Lands - Page: $page, Size: $size');

    try {
      final String? accessToken = await _secureStorage.read(key: 'access_token');

      if (accessToken == null) {
        throw Exception("❌ Access token missing. Please log in again.");
      }

      // ✅ Add Authorization token dynamically
      _dio.options.headers['Authorization'] = 'Bearer $accessToken';

      // 📤 Send GET request
      final response = await _dio.get(
        "/land/lands",
        queryParameters: {
          "page": page - 1, // ✅ Convert to zero-based index
          "size": size,
        },
      );

      // ✅ Handle successful response
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> landsJson = response.data['_embedded']?['lands'] ?? [];
        final int totalElements = int.tryParse(response.data['page']?['totalElements']?.toString() ?? "0") ?? 0;
        final int totalPages = int.tryParse(response.data['page']?['totalPages']?.toString() ?? "1") ?? 1;

        print("📌 Total Lands: $totalElements, Total Pages: $totalPages");

        if (landsJson.isEmpty) {
          print("⚠️ No lands found on this page.");
          return {
            'totalElements': totalElements,
            'totalPages': totalPages,
            'currentPage': page,
            'lands': []
          };
        }

        // ✅ Convert JSON to List<Land>
        List<Land> lands = landsJson.map((json) => Land.fromJson(json)).toList();

        return {
          'totalElements': totalElements,
          'totalPages': totalPages,
          'currentPage': page,
          'lands': lands
        };
      } else {
        print("❌ API Error: ${response.statusCode}, Response: ${response.data}");
        return {
          'totalElements': 0,
          'totalPages': 0,
          'currentPage': page,
          'lands': []
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
        'lands': []
      };
    } catch (e) {
      print("❌ Unexpected Error: $e");
      return {
        'totalElements': 0,
        'totalPages': 0,
        'currentPage': page,
        'lands': []
      };
    }
  }
}

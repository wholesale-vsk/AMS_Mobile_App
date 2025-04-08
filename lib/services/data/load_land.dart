import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../../models/assets/land/land_model.dart';

class LoadLandsService {
  final FlutterSecureStorage _secureStorage;
  final Dio _dio;
  final Logger _logger = Logger();
  final String _imageBaseUrl = "http://149.102.154.118:9000";

  LoadLandsService({FlutterSecureStorage? secureStorage, Dio? dio})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _dio = dio ?? Dio(BaseOptions(
          baseUrl: "https://api.ams.hexalyte.com", // ✅ Ensure no trailing slash
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    // ✅ Enable debugging with Dio Interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.i("📤 Request: ${options.method} ${options.baseUrl}${options.path}");
        _logger.d("🔑 Headers: ${options.headers}");
        handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.i("✅ Response: ${response.statusCode}");
        handler.next(response);
      },
      onError: (DioException e, handler) {
        _logger.e("❌ Error: ${e.response?.statusCode} - ${e.message}");
        handler.next(e);
      },
    ));
  }

  /// **🏡 Fetch paginated lands from API**
  /// - `page` = current page number (default: 1)
  /// - `size` = number of lands per page (default: 20)
  Future<Map<String, dynamic>> fetchLands({int page = 1, int size = 100}) async {
    _logger.i('🏡 Fetching Lands - Page: $page, Size: $size');

    try {
      final String? accessToken = await _secureStorage.read(key: 'access_token');

      if (accessToken == null) {
        _logger.e("❌ Access token missing. Please log in again.");
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

        _logger.i("📌 Total Lands: $totalElements, Total Pages: $totalPages");

        if (landsJson.isEmpty) {
          _logger.w("⚠️ No lands found on this page.");
          return {
            'totalElements': totalElements,
            'totalPages': totalPages,
            'currentPage': page,
            'lands': []
          };
        }

        // ✅ Convert JSON to List<Land> and process image URLs
        List<Land> lands = await Future.wait(landsJson.map((json) async {
          // Check and prepare image URL before creating the Land object
          final String? rawImageUrl = json['imageURL'] ?? json['landImage'];

          // Create Land object
          Land land = Land.fromJson(json);

          // Process the image URL if it exists
          if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
            // Ensure land.imageURL exists (whether it comes from API directly or we assign here)
            land.imageURL = await getAuthenticatedImageUrl(rawImageUrl);
            _logger.d("🖼️ Processed image URL: ${land.imageURL}");
          }

          return land;
        }));

        return {
          'totalElements': totalElements,
          'totalPages': totalPages,
          'currentPage': page,
          'lands': lands
        };
      } else {
        _logger.e("❌ API Error: ${response.statusCode}, Response: ${response.data}");
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
        _logger.e("⏳ Timeout Error: ${dioError.message}");
      } else if (dioError.type == DioExceptionType.badResponse) {
        _logger.e("❌ API Response Error: ${dioError.response?.statusCode} - ${dioError.response?.data}");
      } else {
        _logger.e("❌ DioException: ${dioError.message}");
      }
      return {
        'totalElements': 0,
        'totalPages': 0,
        'currentPage': page,
        'lands': [],
        'error': dioError.message
      };
    } catch (e) {
      _logger.e("❌ Unexpected Error: $e");
      return {
        'totalElements': 0,
        'totalPages': 0,
        'currentPage': page,
        'lands': [],
        'error': e.toString()
      };
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

    // Check if this is a local cache path mistakenly used as a URL
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

    // NEW CHECK: If it's just a path starting with /images, ensure we add the base URL
    if (imagePath.startsWith('/images/') || imagePath == '/images') {
      // Remove leading slash and add base URL
      final cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
      imagePath = '$_imageBaseUrl/$cleanPath';
    }

    // If it's already a full URL from our server, check if it has authentication
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      if (imagePath.contains(_imageBaseUrl) && !imagePath.contains('token=')) {
        // It's our server but missing authentication - extract the path
        try {
          final uri = Uri.parse(imagePath);
          imagePath = uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;
        } catch (e) {
          _logger.e("❌ Error parsing image URL: $e");
          return imagePath; // Return as is if we can't parse it
        }
      } else if (!imagePath.contains(_imageBaseUrl)) {
        // It's from another server, return as is
        return imagePath;
      }
    }

    // For simple paths without protocol, add the base URL
    if (!imagePath.startsWith('http://') && !imagePath.startsWith('https://')) {
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

    // Already a full URL with authentication
    return imagePath;
  }

  /// Get current access token - helper method for UI components
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }
}
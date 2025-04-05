import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hexalyte_ams/services/api_environment.dart';
import 'package:hexalyte_ams/services/auth/api_response_formatter.dart';
import 'package:logger/logger.dart';

class LandService {
  final Dio dio = Dio(BaseOptions(baseUrl: DataEnvironment.baseURL));
  final Logger _logger = Logger();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// **Update Land Details**
  Future<ApiResponse> updateLand({
    required String landName,
    required String landType,
    required String landSize,
    required String landAddress,
    required String landCity,
    required String purchaseDate,
    required String purchasePrice,
    required String landImage,
    required String leaseValue,
    required String leaseDate,
    required String landId,

  }) async {
    dio.options.contentType = Headers.jsonContentType;

    try {
      // Retrieve the stored token
      String? accessToken = await _secureStorage.read(key: 'access_token');

      final updateData = {
        "name": landName,
        "landSize": landSize,
        "landType": landType,
        "address": landAddress,
        "city": landCity,
        "purchaseDate": purchaseDate,
        "purchasePrice": purchasePrice,
        "lease_date": leaseDate,
        "leaseValue": leaseValue,
        "imageURL": landImage,
      };

      final response = await dio.put(
        'https://api.ams.hexalyte.com/land/lands/$landId', // Corrected Endpoint
        data: updateData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      return ApiResponse(
        isSuccess: true,
        statusCode: response.statusCode,
        message: 'Land details updated successfully!',
      );
    } on DioException catch (e) {
      print("DioException in updateLand: ${e.response?.data}");
      return ApiResponse(
        isSuccess: false,
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error_description'] ?? 'An error occurred',
      );
    } catch (e, stackTrace) {
      print("Exception in updateLand: $e");
      print("StackTrace: $stackTrace");

      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        message: 'Unexpected error occurred',
      );
    }
  }

  addLand({required String landName,
    required String landType,
    required String landSize,
    required String landAddress,
    required String landCity,
    required String purchaseDate,
    required String purchasePrice,
    required String landImage,
    required String leaseValue,
    required String leaseDate,

  }) async {
    _logger.i(
        'Land details: $landName, $landType, $landSize, $landAddress, $landCity, , $purchaseDate, $purchasePrice, $landImage');
    String? accessToken = await _secureStorage.read(key: 'access_token');

    try {
      final response = await dio.post(
        'https://api.ams.hexalyte.com/land/lands', // Corrected Endpoint
        data: {
          "name": landName,
          "landSize": landSize,
          "landType": landType,
          "address": landAddress,
          "city": landCity,
          "purchaseDate": purchaseDate,
          "purchasePrice": purchasePrice,
          "lease_date": leaseDate,
          "leaseValue": leaseValue,
          "imageURL": landImage,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      return ApiResponse(
        isSuccess: true,
        statusCode: response.statusCode,
        message: 'Land details added successfully!',
        data: response.data,
      );
    } on DioException catch (e) {
      print("DioException in addLand: ${e.response?.data}");
      return ApiResponse(
        isSuccess: false,
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error_description'] ?? 'An error occurred',
      );
    } catch (e, stackTrace) {
      print("Exception in addLand: $e");
      print("StackTrace: $stackTrace");

      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        message: 'Unexpected error occurred',
      );
    }
  }


  /// **Delete Land**
  Future<ApiResponse> deleteLand({
    required String landId,
  }) async {
    try {
      // Retrieve the stored token
      String? accessToken = await _secureStorage.read(key: 'access_token');
      if (accessToken == null) {
        return ApiResponse(
          isSuccess: false,
          statusCode: 401,
          message: 'Unauthorized: No access token found',
        );
      }

      var url = 'https://api.ams.hexalyte.com/land/lands/$landId';
      _logger.i('Deleting land with URL: $url');

      final response = await dio.delete(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      return ApiResponse(
        isSuccess: true,
        statusCode: response.statusCode,
        message: 'Land deleted successfully!',
      );
    } on DioException catch (e) {
      print("DioException in deleteLand: ${e.response?.data}");
      return ApiResponse(
        isSuccess: false,
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error_description'] ??
            'An error occurred while deleting the land',
      );
    } catch (e, stackTrace) {
      print("Exception in deleteLand: $e");
      print("StackTrace: $stackTrace");

      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        message: 'Unexpected error occurred during land deletion',
      );
    }
  }
}
fetchLands() {}

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hexalyte_ams/services/api_environment.dart';
import 'package:hexalyte_ams/services/auth/api_response_formatter.dart';

class LandService {
  final Dio dio = Dio(BaseOptions(baseUrl: DataEnvironment.baseURL));
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// **Update Land Details**
  Future<ApiResponse> updateLand({
    required String landId,
    required String landName,
    required String landType,
    required String landSize,
    required String landAddress,
    required String landCity,
    required String landProvince,
    required String purchaseDate,
    required String purchasePrice,
    required String landImage,
    required String councilTaxDate,
    required String councilTaxValue,

  }) async {
    dio.options.contentType = Headers.jsonContentType;

    try {
      // Retrieve the stored token
      String? accessToken = await _secureStorage.read(key: 'access_token');

      final updateData = {
        "landName": landName,
        "landType": landType,
        "landSize": landSize,
        "landAddress": landAddress,
        "landCity": landCity,
        "landProvince": landProvince,
        "purchaseDate": purchaseDate,
        "purchasePrice": purchasePrice,
        "landImage": landImage,
        "councilTaxDate": councilTaxDate,
        "councilTaxValue": councilTaxValue,
      };

      final response = await dio.post(
        'https://api.ams.hexalyte.com/land/lands', // Corrected Endpoint
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

  addLand(
      {required String landName,
        required String landType,
        required String landSize,
        required String landAddress,
        required String landCity,
        required String landProvince,
        required String purchaseDate,
        required String purchasePrice,
        required String landImage,
        required String councilTaxValue, required String councilTaxDate,

      }) async {
    print(
        'Land details: $landName, $landType, $landSize, $landAddress, $landCity, $landProvince, $purchaseDate, $purchasePrice, $landImage');
    String? accessToken = await _secureStorage.read(key: 'access_token');

    try {
      final response = await dio.post(
        'https://api.ams.hexalyte.com/land/lands', // Corrected Endpoint
        data: {
          "name": landName,
          "landSize": landSize,
          "address": landAddress,
          "city": landCity,
          "province": landProvince,
          "purchaseDate": purchaseDate,
          "purchasePrice": purchasePrice,
          "councilTaxDate": councilTaxDate,
          "councilTaxValue": councilTaxValue,
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

  fetchLands() {}
}
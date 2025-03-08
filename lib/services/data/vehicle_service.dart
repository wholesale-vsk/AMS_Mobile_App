import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hexalyte_ams/services/api_environment.dart';
import 'package:hexalyte_ams/services/auth/api_response_formatter.dart';

class VehicleService {
  final Dio dio = Dio(BaseOptions(baseUrl: DataEnvironment.baseURL));
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// **Update Vehicle Details**
  Future<ApiResponse> updateVehicle({

    required String registrationNumber,
    required String vehicleType,
    required String vehicleModel,
    required String vehicleCategory,
    required String ownerName,
    required String motValue,
    required String motDate,
    required String milage,
    required String motExpiredDate,
    required String purchaseDate,
    required String purchasePrice,
    required String insuranceValue,
    required String insuranceDate,
    required String vehicleImage,
  }) async {
    try {
      // Retrieve the stored token
      String? accessToken = await _secureStorage.read(key: 'access_token');

      if (accessToken == null) {
        return ApiResponse(isSuccess: false, statusCode: 401, message: "Unauthorized: No token found");
      }

      final updateData = {
        "vrn": registrationNumber,
        "vehicleType": vehicleType,
        "model": vehicleModel,
        "vehicleCategory": vehicleCategory,
        "owner_name": ownerName,
        "purchasePrice": purchasePrice,
        "purchaseDate": purchaseDate,
        "imageURL": vehicleImage,
        "motValue": motValue,
        "motDate": motDate,
        "milage": milage,
        "insuranceValue": insuranceValue,
        "insuranceDate": insuranceDate,
        "motExpiredDate": motExpiredDate,
        "imageURL": vehicleImage.isNotEmpty ? vehicleImage : null, // ✅ P
      };

      final response = await dio.put(
        'https://api.ams.hexalyte.com/vehicle/vehicles/vehicle', // ✅ Changed from POST to PUT
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
        message: 'Vehicle details updated successfully!',
      );
    } on DioException catch (e) {
      debugPrint("🚨 DioException in updateVehicle: ${e.response?.data}");
      return ApiResponse(
        isSuccess: false,
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error_description'] ?? 'An error occurred',
      );
    } catch (e, stackTrace) {
      debugPrint("🚨 Exception in updateVehicle: $e");
      debugPrint("StackTrace: $stackTrace");

      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        message: 'Unexpected error occurred',
      );
    }
  }

  /// **Add New Vehicle**
  Future<ApiResponse> addVehicle({
    required String registrationNumber,
    required String vehicleType,
    required String vehicleModel,
    required String vehicleCategory,
    required String ownerName,
    required String motValue,
    required String motDate,
    required String milage,
    required String motExpiredDate,
    required String purchaseDate,
    required String purchasePrice,
    required String insuranceValue,
    required String insuranceDate,
    required String vehicleImage,

  }) async {
    try {
      String? accessToken = await _secureStorage.read(key: 'access_token');

      if (accessToken == null) {
        return ApiResponse(isSuccess: false, statusCode: 401, message: "Unauthorized: No token found");
      }

      final response = await dio.post(
        'https://api.ams.hexalyte.com/vehicle/vehicles',
        data: {
          "vrn": registrationNumber,
          "vehicleType": vehicleType,
          "model": vehicleModel,
          "vehicleCategory": vehicleCategory,
          "owner_name": ownerName,
          "purchasePrice": purchasePrice,
          "purchaseDate": purchaseDate,
          "imageURL": vehicleImage,
          "motValue": motValue,
          "motDate": motDate,
          "milage": milage,
          "insuranceValue": insuranceValue,
          "insuranceDate": insuranceDate,
          "motExpiredDate": motExpiredDate,
          "imageURL": vehicleImage.isNotEmpty ? vehicleImage : null, // ✅ P
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      debugPrint("✅ API Response Data (Add): ${response.data}");

      return ApiResponse(
        isSuccess: true,
        statusCode: response.statusCode,
        message: 'Vehicle details added successfully!',
        data: response.data,
      );
    } on DioException catch (e) {
      debugPrint("🚨 DioException in addVehicle: ${e.response?.data}");
      return ApiResponse(
        isSuccess: false,
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error_description'] ?? 'An error occurred',
      );
    } catch (e, stackTrace) {
      debugPrint("🚨 Exception in addVehicle: $e");
      debugPrint("StackTrace: $stackTrace");

      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        message: 'Unexpected error occurred',
      );
    }
  }

  /// **Fetch All Vehicles**
  Future<ApiResponse> fetchVehicles() async {
    try {
      String? accessToken = await _secureStorage.read(key: 'access_token');

      if (accessToken == null) {
        return ApiResponse(isSuccess: false, statusCode: 401, message: "Unauthorized: No token found");
      }

      final response = await dio.get(
        'https://api.ams.hexalyte.com/vehicle/vehicles',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      return ApiResponse(
        isSuccess: true,
        statusCode: response.statusCode,
        message: 'Vehicle data fetched successfully!',
        data: response.data,
      );
    } on DioException catch (e) {
      debugPrint("🚨 DioException in fetchVehicles: ${e.response?.data}");
      return ApiResponse(
        isSuccess: false,
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error_description'] ?? 'An error occurred',
      );
    } catch (e, stackTrace) {
      debugPrint("🚨 Exception in fetchVehicles: $e");
      debugPrint("StackTrace: $stackTrace");

      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        message: 'Unexpected error occurred',
      );
    }
  }
}

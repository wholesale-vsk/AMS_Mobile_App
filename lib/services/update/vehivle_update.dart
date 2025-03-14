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
        return ApiResponse(isSuccess: false,
            statusCode: 401,
            message: "Unauthorized: No token found");
      }

      final updateData = {
        "vrn": registrationNumber,
        "vehicle_type": vehicleType,
        "model": vehicleModel,
        "owner_name": ownerName,
        "purchasePrice": purchasePrice,
        "purchaseDate": purchaseDate,
        "imageURL": vehicleImage.isNotEmpty ? vehicleImage : null,
        "motValue": motValue,
        "motDate": motDate,
        "milage": milage,
        "insuranceValue": insuranceValue,
        "insuranceDate": insuranceDate,
        "motExpiredDate": motExpiredDate
      };

      final response = await dio.put(
        'https://api.ams.hexalyte.com/vehicle/vehicles/vehicle',
        // ✅ Changed from POST to PUT
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
}
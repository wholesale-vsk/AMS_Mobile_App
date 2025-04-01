import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hexalyte_ams/services/api_environment.dart';
import 'package:hexalyte_ams/services/auth/api_response_formatter.dart';

class BuildingService {
  final Dio dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// **Update Building Details**
  Future<ApiResponse> updateBuilding({
    required String buildingId,
    required String buildingName,
    required String buildingType,
    required String numberOfFloors,
    required String totalArea,
    required String buildingAddress,
    required String buildingCity,
    required String buildingProvince,
    required String ownerName,
    required String purchasePrice,
    required String purchaseDate,
    required String buildingImage,
    required String purposeOfUse,
    required String councilTax,
    required String councilTaxDate,
    required String councilTaxValue,
    required String leaseDate,
    required String leaseValue,
  }) async {
    dio.options.contentType = Headers.jsonContentType;

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

      final updateData = {
        "buildingId": buildingId,
        "name": buildingName,
        "buildingType": buildingType,
        "numberOfFloors": numberOfFloors,
        "totalArea": totalArea,
        "address": buildingAddress,
        "city": buildingCity,
        "buildingProvince": buildingProvince,
        "ownerName": ownerName,
        "purchasePrice": purchasePrice,
        "purchaseDate": purchaseDate,
        "imageURL": buildingImage.isNotEmpty ? buildingImage : null,
        // ✅ Prevents empty image from being sent
        "purposeOfUse": purposeOfUse,
        "councilTax": councilTax,
        "councilTaxDate": councilTaxDate,
        "councilTaxValue": councilTaxValue,
        "lease_date": leaseDate,
        "leaseValue": leaseValue,
      };
      var url = "https://api.ams.hexalyte.com/asset/assets/$buildingId";
      print('Updating building with URL: $url');
      final response = await dio.put(
        url,
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
        message: 'Building details updated successfully!',
      );
    } on DioException catch (e) {
      print("DioException in updateBuilding: ${e.response?.data}");
      return ApiResponse(
        isSuccess: false,
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error_description'] ?? 'An error occurred',
      );
    } catch (e, stackTrace) {
      print("Exception in updateBuilding: $e");
      print("StackTrace: $stackTrace");

      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        message: 'Unexpected error occurred',
      );
    }
  }

  /// **Add New Building**
  Future<ApiResponse> addBuilding({
    required String buildingId,
    required String buildingName,
    required String buildingType,
    required String numberOfFloors,
    required String totalArea,
    required String buildingAddress,
    required String buildingCity,
    required String buildingProvince,
    required String ownerName,
    required String buildingImage,
    required String purposeOfUse,
    required String councilTax,
    required String councilTaxDate,
    required String councilTaxValue,
    required String image,
    required String leaseValue,
    required String leaseDate,
    required String purchaseDate,
    required String purchasePrice,
  }) async {
    print(
        'Building Details: $buildingName, $buildingType, $numberOfFloors, $totalArea, $buildingAddress, $buildingCity, $buildingProvince, $ownerName, $purposeOfUse, $councilTax, $councilTaxDate, $councilTaxValue, ');

    String? accessToken = await _secureStorage.read(key: 'access_token');
    if (accessToken == null) {
      return ApiResponse(
        isSuccess: false,
        statusCode: 401,
        message: 'Unauthorized: No access token found',
      );
    }

    try {
      final response = await dio.post(
        'https://api.ams.hexalyte.com/asset/assets',
        data: {
          "buildingId": buildingId,
          "name": buildingName,
          "buildingType": buildingType,
          "numberOfFloors": numberOfFloors,
          "totalArea": totalArea,
          "address": buildingAddress,
          "city": buildingCity,
          "buildingProvince": buildingProvince,
          "ownerName": ownerName,
          "purchasePrice": purchasePrice,
          "purchaseDate": purchaseDate,
          "imageURL": buildingImage.isNotEmpty ? buildingImage : null,
          // ✅ Prevents empty image from being sent
          "purposeOfUse": purposeOfUse,
          "councilTax": councilTax,
          "councilTaxDate": councilTaxDate,
          "councilTaxValue": councilTaxValue,
          "lease_date": leaseDate,
          "leaseValue": leaseValue,
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
        message: 'Building details added successfully!',
        data: response.data,
      );
    } on DioException catch (e) {
      print("DioException in addBuilding: ${e.response?.data}");
      return ApiResponse(
        isSuccess: false,
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error_description'] ?? 'An error occurred',
      );
    } catch (e, stackTrace) {
      print("Exception in addBuilding: $e");
      print("StackTrace: $stackTrace");

      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        message: 'Unexpected error occurred',
      );
    }
  }
}

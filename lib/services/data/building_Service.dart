import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hexalyte_ams/services/api_environment.dart';
import 'package:hexalyte_ams/services/auth/api_response_formatter.dart';

class BuildingService {
  final Dio dio = Dio(BaseOptions(baseUrl: DataEnvironment.baseURL));
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
    required String constructionType,
    required String constructionCost,
    required String constructionDate,
    required String buildingImage,
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
        "buildingName": buildingName,
        "buildingType": buildingType,
        "numberOfFloors": numberOfFloors,
        "totalArea": totalArea,
        "buildingAddress": buildingAddress,
        "buildingCity": buildingCity,
        "buildingProvince": buildingProvince,
        "ownerName": ownerName,
        "constructionType": constructionType,
        "constructionCost": constructionCost,
        "constructionDate": constructionDate,
        "buildingImage": buildingImage.isNotEmpty ? buildingImage : null, // ✅ Prevents empty image from being sent
      };

      final response = await dio.put(
        '/asset/assets/$buildingId', // ✅ Corrected to use PUT request
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
    required String constructionType,
    required String constructionCost,
    required String constructionDate,
    required String buildingImage,
  }) async {
    print(
        'Building Details: $buildingName, $buildingType, $numberOfFloors, $totalArea, $buildingAddress, $buildingCity, $buildingProvince, $ownerName, $constructionType, $constructionDate');

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
        '/asset/assets', // ✅ Corrected API endpoint
        data: {
          "buildingId": buildingId,
          "name": buildingName,
          "buildingType": buildingType,
          "numberOfFloors": numberOfFloors,
          "totalArea": totalArea,
          "address": buildingAddress,
          "city": buildingCity,
          "province": buildingProvince,
          "ownerName": ownerName,
          "constructionType": constructionType,
          "purchasePrice": constructionCost,
          "purchaseDate": constructionDate,
          "imageURL": buildingImage.isNotEmpty ? buildingImage : null, // ✅ Prevents empty image from being sent
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

  /// **Fetch All Buildings**
  Future<ApiResponse> fetchBuildings() async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    if (accessToken == null) {
      return ApiResponse(
        isSuccess: false,
        statusCode: 401,
        message: 'Unauthorized: No access token found',
      );
    }

    try {
      final response = await dio.get(
        '/asset/assets', // ✅ Correct API endpoint
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      return ApiResponse(
        isSuccess: true,
        statusCode: response.statusCode,
        message: 'Buildings fetched successfully!',
        data: response.data,
      );
    } on DioException catch (e) {
      print("DioException in fetchBuildings: ${e.response?.data}");
      return ApiResponse(
        isSuccess: false,
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error_description'] ?? 'An error occurred',
      );
    } catch (e, stackTrace) {
      print("Exception in fetchBuildings: $e");
      print("StackTrace: $stackTrace");

      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        message: 'Unexpected error occurred',
      );
    }
  }
}

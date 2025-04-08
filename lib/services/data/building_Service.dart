import 'dart:io';
import 'dart:math' as _logger;

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hexalyte_ams/services/api_environment.dart';
import 'package:hexalyte_ams/services/auth/api_response_formatter.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:http_parser/http_parser.dart';

class BuildingService {
  final Dio dio = Dio();
  final Logger _logger = Logger();
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
    required String ownerName,
    required String purchasePrice,
    required String purchaseDate,
    required File buildingImage,
    required String purposeOfUse,
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
        "ownerName": ownerName,
        "purchasePrice": purchasePrice,
        "purchaseDate": purchaseDate,
        "imageURL": buildingImage.path.isNotEmpty ? buildingImage : null,
        "purposeOfUse": purposeOfUse,
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
    required String ownerName,
    required File buildingImage,
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
    _logger.i(buildingImage.path);
    print(
        'Building Details, required String image: $buildingName, $buildingType, $numberOfFloors, $totalArea, $buildingAddress, $buildingCity, , $ownerName, $purposeOfUse, $councilTax, $councilTaxDate, $councilTaxValue, ');

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
          "ownerName": ownerName,
          "purchasePrice": purchasePrice,
          "purchaseDate": purchaseDate,
          "purposeOfUse": purposeOfUse,
          "councilTax": councilTax,
          "councilTaxDate": councilTaxDate,
          "councilTaxValue": councilTaxValue,
          "lease_date": leaseDate,
          "leaseValue": leaseValue,
          // "imageURL": buildingImage.path.isNotEmpty ?
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

  Future<ApiResponse> uploadBuildingImage({
    required File imageFile,
  }) async {
    try {
      // Validate file existence and non-emptiness
      if (!imageFile.existsSync()) {
        _logger.e("Image file does not exist");
        return ApiResponse(
          isSuccess: false,
          statusCode: 400,
          message: 'Image file not found',
        );
      }

      // Read file bytes
      final imageBytes = await imageFile.readAsBytes();
      if (imageBytes.isEmpty) {
        _logger.e("Image file is empty");
        return ApiResponse(
          isSuccess: false,
          statusCode: 400,
          message: 'Empty image file',
        );
      }

      // Get file details
      final fileExtension = path.extension(imageFile.path).toLowerCase();
      final fileName = path.basename(imageFile.path);

      _logger.d("File Path: ${imageFile.path}");
      _logger.d("File Extension: $fileExtension");
      _logger.d("File Name: $fileName");
      _logger.d("File Size: ${imageBytes.length} bytes");

      // Validate file extension
      final validExtensions = ['.jpg', '.jpeg', '.png'];
      if (!validExtensions.contains(fileExtension)) {
        _logger.e("Invalid file extension: $fileExtension");
        return ApiResponse(
          isSuccess: false,
          statusCode: 400,
          message: 'Invalid file type. Only JPEG and PNG are allowed.',
        );
      }

      // Verify file signature
      bool isJpeg = imageBytes[0] == 0xFF && imageBytes[1] == 0xD8;
      bool isPng = imageBytes[0] == 0x89 && imageBytes[1] == 0x50 &&
          imageBytes[2] == 0x4E && imageBytes[3] == 0x47;

      if (!isJpeg && !isPng) {
        _logger.e("File signature does not match JPEG or PNG");
        return ApiResponse(
          isSuccess: false,
          statusCode: 400,
          message: 'Invalid image file format',
        );
      }

      // Attempt to decode image
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) {
        _logger.e("Unable to decode image file");
        return ApiResponse(
          isSuccess: false,
          statusCode: 400,
          message: 'Corrupted image file',
        );
      }

      // Optional: Image dimension check
      if (decodedImage.width > 4096 || decodedImage.height > 4096) {
        _logger.e("Image dimensions too large");
        return ApiResponse(
          isSuccess: false,
          statusCode: 400,
          message: 'Image dimensions exceed maximum allowed size',
        );
      }

      // Retrieve the stored token
      String? accessToken = await _secureStorage.read(key: 'access_token');

      // Validate access token
      if (accessToken == null || accessToken.isEmpty) {
        _logger.e("No access token available");
        return ApiResponse(
          isSuccess: false,
          statusCode: 401,
          message: 'Authentication required',
        );
      }

      // Determine MIME type
      String mimeType = isJpeg ? 'image/jpeg' : 'image/png';

      // Create MultipartFile
      final multipartFile = MultipartFile.fromBytes(
        imageBytes,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      );

      // Create FormData
      FormData formData = FormData.fromMap({
        "image": multipartFile,
      });

      // Perform upload
      final response = await dio.post(
        'https://api.ams.hexalyte.com/storage',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // Handle response
      if (response.statusCode == 200) {
        return ApiResponse(
          isSuccess: true,
          data: response.data,
          statusCode: response.statusCode,
          message: 'Building image uploaded successfully!',

        );
      } else {
        _logger.e("Upload failed with status code: ${response.statusCode}");
        _logger.e("Response body: ${response.data}");
        return ApiResponse(
          isSuccess: false,
          statusCode: response.statusCode ?? 400,
          message: response.data?['message']
              ?? response.data?['error_description']
              ?? 'Building image upload failed',
        );
      }
    } on DioException catch (e) {
      _logger.e("DioException in uploadBuildingImage: ${e.message}");
      _logger.e("DioException type: ${e.type}");
      _logger.e("DioException response: ${e.response?.data}");
      _logger.e("DioException error: ${e.error}");

      return ApiResponse(
        isSuccess: false,
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['message']
            ?? e.response?.data?['error_description']
            ?? e.message
            ?? 'An error occurred',
      );
    } catch (e, stackTrace) {
      _logger.e("Exception in uploadBuildingImage: $e");
      _logger.e("StackTrace: $stackTrace");

      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        message: 'Unexpected error occurred',
      );
    }
  }
  deleteBuilding({required String buildingId}) {

    Future<ApiResponse> deleteBuilding({
      required String buildingId,
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

        var url = "https://api.ams.hexalyte.com/asset/assets/$buildingId";
        print('Deleting building with URL: $url');

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
          message: 'Building deleted successfully!',
        );
      } on DioException catch (e) {
        _logger.e("DioException in deleteBuilding: ${e.response?.data}");
        return ApiResponse(
          isSuccess: false,
          statusCode: e.response?.statusCode ?? 500,
          message: e.response?.data?['error_description'] ?? 'An error occurred while deleting the building',
        );
      } catch (e, stackTrace) {
        _logger.e("Exception in deleteBuilding: $e");
        _logger.e("StackTrace: $stackTrace");

        return ApiResponse(
          isSuccess: false,
          statusCode: 500,
          message: 'Unexpected error occurred during building deletion',
        );
      }
    }
  }
}




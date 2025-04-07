import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hexalyte_ams/services/api_environment.dart';
import 'package:hexalyte_ams/services/auth/api_response_formatter.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:http_parser/http_parser.dart';



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
      _logger.e("DioException in updateLand: ${e.response?.data}");
      return ApiResponse(
        isSuccess: false,
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error_description'] ?? 'An error occurred',
      );
    } catch (e, stackTrace) {
      _logger.e("Exception in updateLand: $e");
      _logger.e("StackTrace: $stackTrace");

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
    required File landImage,
    required String leaseValue,
    required String leaseDate,

  }) async {
    _logger.i(landImage.path);
    var uploadedImage = uploadImage(imageFile: landImage);
    _logger.i(uploadedImage.toString());
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
          // "imageURL": landImage,
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
      _logger.e("DioException in addLand: ${e.response?.data}");
      return ApiResponse(
        isSuccess: false,
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error_description'] ?? 'An error occurred',
      );
    } catch (e, stackTrace) {
      _logger.e("Exception in addLand: $e");
      _logger.e("StackTrace: $stackTrace");

      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        message: 'Unexpected error occurred',
      );
    }
  }




  Future<ApiResponse> uploadImage({
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

      // Configure Dio
      final dioInstance = Dio(BaseOptions(
        validateStatus: (status) => status != null && status >= 200 && status < 600,
      ));

      // Perform upload
      final response = await dioInstance.post(
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
          message: 'Image uploaded successfully!',
        );
      } else {
        _logger.e("Upload failed with status code: ${response.statusCode}");
        _logger.e("Response body: ${response.data}");
        return ApiResponse(
          isSuccess: false,
          statusCode: response.statusCode ?? 400,
          message: response.data?['message']
              ?? response.data?['error_description']
              ?? 'Image upload failed',
        );
      }
    } on DioException catch (e) {
      _logger.e("DioException in uploadImage: ${e.message}");
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
      _logger.e("Exception in uploadImage: $e");
      _logger.e("StackTrace: $stackTrace");

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

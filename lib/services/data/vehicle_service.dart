import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hexalyte_ams/services/api_environment.dart';
import 'package:hexalyte_ams/services/auth/api_response_formatter.dart';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:http_parser/http_parser.dart';

class VehicleService {
  final Dio dio = Dio(BaseOptions(baseUrl: DataEnvironment.baseURL));
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  /// **Update Vehicle Details**
  Future<ApiResponse> updateVehicle({
    required String registrationNumber,
    required String vehicleType,
    required String vehicleModel,
    required String vehicleId,
    required String ownerName,
    required String motValue,
    required String motDate,
    required double mileage,
    required String motExpiredDate,
    required String purchaseDate,
    required double purchasePrice,
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
        "mileage": mileage,
        "insuranceValue": insuranceValue,
        "insuranceDate": insuranceDate,
        "motExpiredDate": motExpiredDate
      };

      final response = await dio.put(
        'https://api.ams.hexalyte.com/vehicle/vehicles/$vehicleId',
        // Use relative URL with baseURL
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
        data: response.data, // Added data field to match addVehicle
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
    required String ownerName,
    required String motValue,
    required String motDate,
    required double mileage,
    required String motExpiredDate,
    required String purchaseDate,
    required double purchasePrice,
    required String insuranceValue,
    required String insuranceDate,
    required File vehicleImage,
  }) async {
    try {
      _logger.i("Processing vehicle image: ${vehicleImage.path}");

      // Upload the vehicle image first
      var imageUploadResponse = await uploadVehicleImage(
          imageFile: vehicleImage);

      // If image upload failed, return the error
      if (!imageUploadResponse.isSuccess) {
        _logger.e(
            "Failed to upload vehicle image: ${imageUploadResponse.message}");
        return imageUploadResponse;
      }

      // Extract the image URL from the response
      String? imageUrl;
      if (imageUploadResponse.data is Map) {
        // Try different possible keys where the URL might be stored
        imageUrl = imageUploadResponse.data['url'] ??
            imageUploadResponse.data['imageUrl'] ??
            imageUploadResponse.data['data']?['url'];
      }

      _logger.i("Image upload successful, URL: $imageUrl");

      // Retrieve the access token
      String? accessToken = await _secureStorage.read(key: 'access_token');

      if (accessToken == null) {
        return ApiResponse(isSuccess: false,
            statusCode: 401,
            message: "Unauthorized: No token found");
      }

      // Create the vehicle data including the image URL
      final vehicleData = {
        "vrn": registrationNumber,
        "vehicle_type": vehicleType,
        "model": vehicleModel,
        "owner_name": ownerName,
        "purchasePrice": purchasePrice,
        "purchaseDate": purchaseDate,
        "motValue": motValue,
        "motDate": motDate,
        "mileage": mileage,
        "insuranceValue": insuranceValue,
        "insuranceDate": insuranceDate,
        "motExpiredDate": motExpiredDate
      };

      // Add image URL to data if available
      if (imageUrl != null && imageUrl.isNotEmpty) {
        vehicleData["imageURL"] = imageUrl;
      }

      // Create the vehicle with the image URL
      final response = await dio.post(
        'https://api.ams.hexalyte.com/vehicle/vehicles',
        data: vehicleData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      _logger.i("Vehicle created successfully: ${response.statusCode}");
      _logger.d("API Response Data (Add): ${response.data}");

      return ApiResponse(
        isSuccess: true,
        statusCode: response.statusCode,
        message: 'Vehicle details added successfully!',
        data: response.data,
      );
    } on DioException catch (e) {
      _logger.e("DioException in addVehicle: ${e.message}");
      if (e.response != null) {
        _logger.e("Response data: ${e.response?.data}");
      }

      return ApiResponse(
        isSuccess: false,
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['message'] ??
            e.response?.data?['error_description'] ??
            'An error occurred',
      );
    } catch (e, stackTrace) {
      _logger.e("Exception in addVehicle: $e");
      _logger.e("StackTrace: $stackTrace");

      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        message: 'Unexpected error occurred',
      );
    }
  }

  Future<ApiResponse> uploadVehicleImage({
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

      // Verify file signature with bounds checking
      if (imageBytes.length < 4) {
        _logger.e("File too small to verify signature");
        return ApiResponse(
          isSuccess: false,
          statusCode: 400,
          message: 'Invalid image file: too small',
        );
      }

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
      img.Image? decodedImage;
      try {
        decodedImage = img.decodeImage(imageBytes);
      } catch (e) {
        _logger.e("Error decoding image: $e");
        return ApiResponse(
          isSuccess: false,
          statusCode: 400,
          message: 'Unable to process image file',
        );
      }

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
        _logger.e(
            "Image dimensions too large: ${decodedImage.width}x${decodedImage
                .height}");
        return ApiResponse(
          isSuccess: false,
          statusCode: 400,
          message: 'Image dimensions exceed maximum allowed size (max: 4096x4096)',
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

      // Configure Dio with timeouts
      final dioInstance = Dio(BaseOptions(
        validateStatus: (status) =>
        status != null && status >= 200 && status < 600,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ));

      // Add logging interceptor for debugging
      if (kDebugMode) {
        dioInstance.interceptors.add(LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => _logger.d(obj.toString()),
        ));
      }

      // Perform upload with retry mechanism
      Response? response;
      int retries = 0;
      const maxRetries = 2;

      while (retries <= maxRetries) {
        try {
          _logger.d("Uploading image (attempt ${retries + 1})...");

          response = await dioInstance.post(
            'https://api.ams.hexalyte.com/storage',
            data: formData,
            options: Options(
              headers: {
                'Authorization': 'Bearer $accessToken',
                'Content-Type': 'multipart/form-data',
              },
            ),
          );

          // If we get here, the request was completed (though it might be an error)
          break;
        } on DioException catch (e) {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.connectionError) {
            if (retries < maxRetries) {
              retries++;
              _logger.w(
                  "Connection issue during upload, retrying (${retries}/${maxRetries})...");
              await Future.delayed(
                  Duration(seconds: 2 * retries)); // Exponential backoff
              continue;
            }
          }
          // If not a retryable error or we've exhausted retries, rethrow
          rethrow;
        }
      }

      // Process response
      if (response != null) {
        final statusCode = response.statusCode ?? 500;
        final responseData = response.data;

        _logger.d("Upload response: [Status: $statusCode] $responseData");

        if (statusCode >= 200 && statusCode < 300) {
          _logger.i("Vehicle image uploaded successfully");

          // Extract URL from response (adjust based on your API response structure)
          String? imageUrl;
          if (responseData is Map) {
            // Try different possible locations/keys for the URL
            imageUrl = responseData['url'] ??
                responseData['imageUrl'] ??
                responseData['data']?['url'] ??
                responseData['image_url'];

            // If still not found, try to search through nested maps
            if (imageUrl == null && responseData.containsKey('data') &&
                responseData['data'] is Map) {
              final dataMap = responseData['data'] as Map;
              imageUrl =
                  dataMap['url'] ?? dataMap['imageUrl'] ?? dataMap['image_url'];
            }
          }

          _logger.i("Image URL extracted: $imageUrl");

          return ApiResponse(
            isSuccess: true,
            data: responseData,
            statusCode: statusCode,
            message: 'Vehicle image uploaded successfully',
            // imageUrl: imageUrl,
          );
        } else {
          // Handle error response
          String errorMessage = 'Failed to upload image';

          if (responseData is Map) {
            errorMessage = responseData['message'] ??
                responseData['error'] ??
                responseData['error_description'] ??
                errorMessage;
          }

          _logger.e("Upload failed: $errorMessage [Status: $statusCode]");

          return ApiResponse(
            isSuccess: false,
            statusCode: statusCode,
            message: errorMessage,
          );
        }
      } else {
        // This should not happen due to our retry logic, but handle it anyway
        _logger.e("No response received after multiple attempts");
        return ApiResponse(
          isSuccess: false,
          statusCode: 500,
          message: 'Failed to receive response from server',
        );
      }
    } on DioException catch (e) {
      _logger.e("DioException in uploadVehicleImage: ${e.message}");
      _logger.e("DioException type: ${e.type}");
      if (e.response != null) {
        _logger.e("DioException response: ${e.response?.data}");
      }

      // Provide user-friendly error messages based on error type
      String errorMessage;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage =
          'Connection timed out. Please check your internet connection and try again.';
          break;
        case DioExceptionType.badResponse:
          String? serverMessage;
          if (e.response?.data is Map) {
            serverMessage = e.response?.data['message'] ??
                e.response?.data['error'] ??
                e.response?.data['error_description'];
          }
          errorMessage = serverMessage ?? 'Server returned an error response';
          break;
        case DioExceptionType.connectionError:
          errorMessage =
          'Cannot connect to the server. Please check your internet connection.';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Upload was cancelled';
          break;
        default:
          errorMessage = 'Network error: ${e.message ?? 'Unknown error'}';
      }

      return ApiResponse(
        isSuccess: false,
        statusCode: e.response?.statusCode ?? 500,
        message: errorMessage,
      );
    } catch (e, stackTrace) {
      _logger.e("Exception in uploadVehicleImage: $e");
      _logger.e("StackTrace: $stackTrace");

      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        message: 'Unexpected error occurred during upload',
      );
    }
  }
}
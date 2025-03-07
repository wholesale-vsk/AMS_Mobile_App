import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/models/auth/jwt_token.dart';
import 'package:hexalyte_ams/services/api_environment.dart';
import 'package:hexalyte_ams/services/auth/api_response_formatter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final Dio dio = Dio(BaseOptions(baseUrl: AuthEnvironment.baseURL));
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<ApiResponse> loginAuth({
    required String username,
    required String password,
  }) async {
    dio.options.contentType = Headers.formUrlEncodedContentType;
    try {
      final formData = {
        'username': username,
        'password': password,
        'grant_type': 'password',
        'client_id': 'ams-cloud-client',
        'client_secret': 'waBBbeLmADRjFsrYnPSXsKWscY6HYE9o',
      };

      final response = await dio.post(
        AuthEnvironment.baseURL, // Make sure to change this to the actual login endpoint
        data: formData,
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      // Decode JWT token
      Map<String, dynamic> tokenResult = JwtDecoder.decode(response.data['access_token']);
      JwtTokenData jwtData = JwtTokenData.fromJson(tokenResult);
      print('Name: ${jwtData.name}');
      print('Email: ${jwtData.email}');
      print('Role: ${jwtData.realmRoles[0]}');

      // Store the access token securely
      await _secureStorage.write(key: 'access_token', value: response.data['access_token']);

      return ApiResponse(
        isSuccess: true,
        statusCode: response.statusCode,
        message: response.data['access_token'],
      );
    } on DioException catch (e) {
      print('Dio Error: ${e.message}');
      Get.snackbar('Login Failed', 'Please try again.');
      return ApiResponse(
        isSuccess: false,
        statusCode: e.response?.statusCode,
        message: e.response?.data['error_description'] ?? 'An unknown error occurred',
      );
    }
  }
}

Future<void> logout() async {
  try {
    final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

    // 🔹 Step 1: Retrieve Access Token Before Deleting
    String? accessToken = await _secureStorage.read(key: 'access_token');
    print("Token Before Deletion: $accessToken");

    // 🔹 Step 2: Delete Tokens Securely
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');

    // 🔹 Step 3: Check Token After Deletion
    String? tokenAfterDeletion = await _secureStorage.read(key: 'access_token');
    print("Token After Deletion: $tokenAfterDeletion"); // Should be null

    // 🔹 Step 4: Call Logout API (If backend supports it)
    if (accessToken != null) {
      var dio;
      await dio.post(
        '${AuthEnvironment.baseURL}/auth/logout',
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        }),
      );
    }

    // 🔹 Step 5: Navigate User to Login Screen
    Get.offAllNamed('/login');

    print('User successfully logged out.');
  } catch (e) {
    print('Logout Error: $e');
    Get.snackbar('Logout Failed', 'An error occurred while logging out.');
  }
}

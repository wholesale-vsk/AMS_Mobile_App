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

      // Store refresh token if present in the response
      if (response.data['refresh_token'] != null) {
        await _secureStorage.write(key: 'refresh_token', value: response.data['refresh_token']);
      }

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

  Future<void> logout() async {
    try {
      final accessToken = await _secureStorage.read(key: 'access_token');
      final refreshToken = await _secureStorage.read(key: 'refresh_token');

      if (accessToken != null) {
        // Keycloak OpenID Connect logout endpoint
        const logoutEndpoint = 'https://auth.hexalyte.com/realms/ams-cloud/protocol/openid-connect/logout';

        try {
          // Call Keycloak logout endpoint
          await dio.post(
            logoutEndpoint,
            data: {
              'client_id': 'ams-cloud-client',
              'client_secret': 'waBBbeLmADRjFsrYnPSXsKWscY6HYE9o',
              'refresh_token': refreshToken,
            },
            options: Options(
              contentType: Headers.formUrlEncodedContentType,
              headers: {
                'Authorization': 'Bearer $accessToken',
              },
            ),
          );
        } catch (e) {
          // Log logout endpoint error, but continue with local logout
          print('Keycloak logout endpoint error: $e');
        }
      }

      // Clear all stored tokens
      await _secureStorage.deleteAll();

      // Navigate to login screen
      Get.offAllNamed('/login');
    } catch (e) {
      print('Logout Error: $e');
      Get.snackbar('Logout Failed', 'An error occurred while logging out.');
    }
  }
}
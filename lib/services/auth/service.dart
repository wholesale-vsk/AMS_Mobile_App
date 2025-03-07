import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final String _tokenUrl = 'https://auth.hexalyte.com/realms/ams-cloud/protocol/openid-connect/token';

  AuthService() {
    // Add interceptors to handle token expiration automatically
    _dio.interceptors.add(InterceptorsWrapper(

      onRequest: (options, handler) async {
        final token = await _getValidAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  // Login method
  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post(
        _tokenUrl,
        data: {
          'username': username,
          'password': password,
          'grant_type': 'password',
          'client_id': 'ams-cloud-client', // Replace with your client ID
          'client_secret': 'waBBbeLmADRjFsrYnPSXsKWscY6HYE9o', // Replace with your client secret if required
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _saveTokens(data['access_token'], data['refresh_token']);
        return true;
      }
    } catch (e) {
      print('Login Error: $e');
    }
    return false;
  }

  // Save tokens securely
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: 'access_token', value: accessToken);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);

    // Save token expiration time (30 minutes from now)
    final expirationTime = DateTime.now().add(const Duration(minutes: 30)).toIso8601String();
    await _secureStorage.write(key: 'access_token_expiry', value: expirationTime);
  }

  // Get stored token or refresh if expired
  Future<String?> _getValidAccessToken() async {
    final expirationTimeString = await _secureStorage.read(key: 'access_token_expiry');
    if (expirationTimeString != null) {
      final expirationTime = DateTime.parse(expirationTimeString);
      if (DateTime.now().isBefore(expirationTime)) {
        // Token is still valid
        return await _secureStorage.read(key: 'access_token');
      }
    }

    // Token is expired, refresh it
    final refreshed = await _refreshAccessToken();
    if (refreshed) {
      return await _secureStorage.read(key: 'access_token');
    }
    return null;
  }

  // Refresh access token
  Future<bool> _refreshAccessToken() async {
    final refreshToken = await _secureStorage.read(key: 'refresh_token');
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post(
        _tokenUrl,
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': 'ams-cloud-client', // Replace with your client ID
          'client_secret': 'waBBbeLmADRjFsrYnPSXsKWscY6HYE9o', // Replace with your client secret if required
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _saveTokens(data['access_token'], data['refresh_token']);
        return true;
      }
    } catch (e) {
      print('Token Refresh Error: $e');
    }
    return false;
  }

  // Clear tokens on logout
  Future<void> logout() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _secureStorage.delete(key: 'access_token_expiry');
  }

  // Dio instance for API calls
  Dio get dio => _dio;
}

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hexalyte_ams/models/chat/chat_models.dart';
import 'package:hexalyte_ams/services/auth/api_response_formatter.dart';
import 'package:logger/logger.dart';

class ChatService {
  final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://api.ams.hexalyte.com/',
    validateStatus: (status) => status != null && status >= 200 && status < 600,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  final Logger _logger = Logger();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Get all chat rooms for current user
  Future<ApiResponse<List<ChatRoom>>> getChatRooms() async {
    try {
      final String? accessToken =
          await _secureStorage.read(key: 'access_token');

      if (accessToken == null) {
        return ApiResponse.error(
          message: 'Authentication required',
          statusCode: 401,
        );
      }

      final response = await dio.get(
        '/chat/rooms',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data ?? [];
        final rooms = data.map((room) => ChatRoom.fromJson(room)).toList();

        return ApiResponse.success(rooms);
      } else {
        return ApiResponse.error(
          statusCode: response.statusCode,
          message: response.data?['message'] ?? 'Failed to load chat rooms',
        );
      }
    } on DioException catch (e) {
      _logger.e('DioException in getChatRooms: ${e.message}');
      return ApiResponse.error(
        statusCode: e.response?.statusCode,
        message: e.response?.data?['message'] ?? 'Network error',
      );
    } catch (e) {
      _logger.e('Exception in getChatRooms: $e');
      return ApiResponse.error(message: 'Unexpected error occurred');
    }
  }

  /// Get messages for a specific chat room
  Future<ApiResponse<List<ChatMessage>>> getMessages(String roomId) async {
    try {
      final String? accessToken =
          await _secureStorage.read(key: 'access_token');

      if (accessToken == null) {
        return ApiResponse.error(
          message: 'Authentication required',
          statusCode: 401,
        );
      }

      final response = await dio.get(
        '/chat/rooms/$roomId/messages',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data ?? [];
        final messages = data.map((msg) => ChatMessage.fromJson(msg)).toList();

        return ApiResponse.success(messages);
      } else {
        return ApiResponse.error(
          statusCode: response.statusCode,
          message: response.data?['message'] ?? 'Failed to load messages',
        );
      }
    } on DioException catch (e) {
      _logger.e('DioException in getMessages: ${e.message}');
      return ApiResponse.error(
        statusCode: e.response?.statusCode,
        message: e.response?.data?['message'] ?? 'Network error',
      );
    } catch (e) {
      _logger.e('Exception in getMessages: $e');
      return ApiResponse.error(message: 'Unexpected error occurred');
    }
  }

  /// Send a message to a chat room
  Future<ApiResponse<ChatMessage>> sendMessage({
    required String roomId,
    required String message,
    MessageType type = MessageType.text,
  }) async {
    try {
      final String? accessToken =
          await _secureStorage.read(key: 'access_token');

      if (accessToken == null) {
        return ApiResponse.error(
          message: 'Authentication required',
          statusCode: 401,
        );
      }

      final response = await dio.post(
        '/chat/rooms/$roomId/messages',
        data: {
          'message': message,
          'type': type.name,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final sentMessage = ChatMessage.fromJson(response.data);
        return ApiResponse.success(sentMessage);
      } else {
        return ApiResponse.error(
          statusCode: response.statusCode,
          message: response.data?['message'] ?? 'Failed to send message',
        );
      }
    } on DioException catch (e) {
      _logger.e('DioException in sendMessage: ${e.message}');
      return ApiResponse.error(
        statusCode: e.response?.statusCode,
        message: e.response?.data?['message'] ?? 'Network error',
      );
    } catch (e) {
      _logger.e('Exception in sendMessage: $e');
      return ApiResponse.error(message: 'Unexpected error occurred');
    }
  }

  /// Get all users for starting new chats
  Future<ApiResponse<List<ChatUser>>> getUsers() async {
    try {
      final String? accessToken =
          await _secureStorage.read(key: 'access_token');

      if (accessToken == null) {
        return ApiResponse.error(
          message: 'Authentication required',
          statusCode: 401,
        );
      }

      final response = await dio.get(
        '/chat/users',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data ?? [];
        final users = data.map((user) => ChatUser.fromJson(user)).toList();

        return ApiResponse.success(users);
      } else {
        return ApiResponse.error(
          statusCode: response.statusCode,
          message: response.data?['message'] ?? 'Failed to load users',
        );
      }
    } on DioException catch (e) {
      _logger.e('DioException in getUsers: ${e.message}');
      return ApiResponse.error(
        statusCode: e.response?.statusCode,
        message: e.response?.data?['message'] ?? 'Network error',
      );
    } catch (e) {
      _logger.e('Exception in getUsers: $e');
      return ApiResponse.error(message: 'Unexpected error occurred');
    }
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatStorage {
  static const String _chatMessagesKey = 'chat_messages';
  static const String _chatUsersKey = 'chat_users';

  // Save messages for a specific user
  static Future<void> saveMessages(
      String userId, List<Map<String, dynamic>> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final allMessages = await getSavedMessages();

    allMessages[userId] = messages;
    await prefs.setString(_chatMessagesKey, json.encode(allMessages));
  }

  // Get saved messages for a user
  static Future<Map<String, dynamic>> getSavedMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getString(_chatMessagesKey);

    if (messagesJson != null) {
      final Map<String, dynamic> decoded = json.decode(messagesJson);
      return decoded;
    }
    return {};
  }

  // Get messages for specific user
  static Future<List<Map<String, dynamic>>> getUserMessages(
      String userId) async {
    final allMessages = await getSavedMessages();
    final userMessages = allMessages[userId] as List?;

    if (userMessages != null) {
      return userMessages.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Save chat users
  static Future<void> saveChatUsers(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chatUsersKey, json.encode(users));
  }

  // Get saved chat users
  static Future<List<Map<String, dynamic>>> getChatUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_chatUsersKey);

    if (usersJson != null) {
      final List<dynamic> decoded = json.decode(usersJson);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }
}

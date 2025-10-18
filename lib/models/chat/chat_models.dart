class ChatUser {
  final String id;
  final String name;
  final String? email;
  final String? profileImage;
  final String role;
  final bool isOnline;
  final DateTime? lastSeen;

  ChatUser({
    required this.id,
    required this.name,
    this.email,
    this.profileImage,
    required this.role,
    this.isOnline = false,
    this.lastSeen,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] ?? json['userId'] ?? '',
      name: json['name'] ?? json['username'] ?? 'Unknown',
      email: json['email'],
      profileImage: json['profileImage'] ?? json['avatar'],
      role: json['role'] ?? 'user',
      isOnline: json['isOnline'] ?? false,
      lastSeen:
          json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
    );
  }
}

class ChatRoom {
  final String id;
  final String name;
  final List<ChatUser> participants;
  final ChatMessage? lastMessage;
  final DateTime createdAt;
  final bool isGroup;

  ChatRoom({
    required this.id,
    required this.name,
    required this.participants,
    this.lastMessage,
    required this.createdAt,
    this.isGroup = false,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] ?? json['roomId'] ?? '',
      name: json['name'] ?? 'Chat',
      participants: (json['participants'] as List? ?? [])
          .map((p) => ChatUser.fromJson(p))
          .toList(),
      lastMessage: json['lastMessage'] != null
          ? ChatMessage.fromJson(json['lastMessage'])
          : null,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isGroup: json['isGroup'] ?? false,
    );
  }
}

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final MessageType type;
  final String? attachmentUrl;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.type = MessageType.text,
    this.attachmentUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? json['messageId'] ?? '',
      roomId: json['roomId'] ?? json['chatRoomId'] ?? '',
      senderId: json['senderId'] ?? json['userId'] ?? '',
      senderName: json['senderName'] ?? json['userName'] ?? 'Unknown',
      message: json['message'] ?? json['content'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ??
          json['createdAt'] ??
          DateTime.now().toIso8601String()),
      type: MessageType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      attachmentUrl: json['attachmentUrl'] ?? json['fileUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'attachmentUrl': attachmentUrl,
    };
  }
}

enum MessageType { text, image, file, system }

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  List<Map<String, dynamic>> messages = [
    {
      "id": "1",
      "isMe": false,
      "message": "Hey there! How are you?",
      "time": "10:30 AM",
      "senderId": "1",
      "senderName": "John Doe",
      "type": "text"
    },
    {
      "id": "2",
      "isMe": true,
      "message": "I'm good! What about you?",
      "time": "10:32 AM",
      "senderId": "current_user",
      "senderName": "You",
      "type": "text"
    },
    {
      "id": "3",
      "isMe": false,
      "message": "Just chilling. Check out this cool image!",
      "time": "10:35 AM",
      "senderId": "1",
      "senderName": "John Doe",
      "type": "image",
      "fileUrl": "https://picsum.photos/400/300"
    },
  ];

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      String formattedTime = DateFormat('h:mm a').format(DateTime.now());

      setState(() {
        messages.add({
          "id": "temp_${DateTime.now().millisecondsSinceEpoch}",
          "isMe": true,
          "message": _messageController.text,
          "time": formattedTime,
          "senderId": "current_user",
          "senderName": "You",
          "type": "text"
        });
        _messageController.clear();
      });

      _scrollToBottom();

      // Simulate receiving a reply after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            messages.add({
              "id": "auto_${DateTime.now().millisecondsSinceEpoch}",
              "isMe": false,
              "message": _getAutoReply(_messageController.text),
              "time": DateFormat('h:mm a').format(DateTime.now()),
              "senderId": widget.user["id"],
              "senderName": widget.user["name"],
              "type": "text"
            });
          });
          _scrollToBottom();
        }
      });
    }
  }

  void _sendImage(File imageFile) {
    String formattedTime = DateFormat('h:mm a').format(DateTime.now());

    setState(() {
      messages.add({
        "id": "temp_${DateTime.now().millisecondsSinceEpoch}",
        "isMe": true,
        "message": "Image",
        "time": formattedTime,
        "senderId": "current_user",
        "senderName": "You",
        "type": "image",
        "filePath": imageFile.path,
        "isLocal": true
      });
    });

    _scrollToBottom();

    // Simulate receiving an image reply
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          messages.add({
            "id": "auto_${DateTime.now().millisecondsSinceEpoch}",
            "isMe": false,
            "message": "Nice photo! Here's one from me too.",
            "time": DateFormat('h:mm a').format(DateTime.now()),
            "senderId": widget.user["id"],
            "senderName": widget.user["name"],
            "type": "image",
            "fileUrl": "https://picsum.photos/400/300?random=2"
          });
        });
        _scrollToBottom();
      }
    });
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        _sendImage(File(image.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _takePhotoWithCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        _sendImage(File(image.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'Share Media',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Options
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.teal),
                ),
                title: const Text('Photo & Video Library'),
                subtitle: const Text('Choose from gallery'),
                onTap: () {
                  Get.back();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.teal),
                ),
                title: const Text('Camera'),
                subtitle: const Text('Take a photo'),
                onTap: () {
                  Get.back();
                  _takePhotoWithCamera();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.insert_drive_file, color: Colors.teal),
                ),
                title: const Text('Document'),
                subtitle: const Text('Share files (Coming Soon)'),
                onTap: () {
                  Get.back();
                  Get.snackbar(
                    'Coming Soon',
                    'File sharing will be available in the next update!',
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
              // Cancel button
              Container(
                margin: const EdgeInsets.all(16),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                    elevation: 0,
                  ),
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _getAutoReply(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('hello') ||
        message.contains('hi') ||
        message.contains('hey')) {
      return 'Hello! How can I help you today?';
    } else if (message.contains('how are you')) {
      return 'I\'m doing great! Thanks for asking.';
    } else if (message.contains('thank')) {
      return 'You\'re welcome!';
    } else if (message.contains('bye') || message.contains('goodbye')) {
      return 'Goodbye! Have a great day!';
    } else if (message.contains('help')) {
      return 'I\'m here to help! What do you need assistance with?';
    } else {
      return 'That\'s interesting! Tell me more.';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    int i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildChatBubble(message);
              },
            ),
          ),
          _buildMessageInput(isDarkMode),
        ],
      ),
    );
  }

  // 🔹 WhatsApp-Style AppBar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.teal,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.user["image"]),
            radius: 22,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user["name"],
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                widget.user["isOnline"]
                    ? "Online"
                    : "Last seen ${_formatLastSeen(widget.user["lastSeen"])}",
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam, color: Colors.white),
          onPressed: () {
            Get.snackbar(
              'Video Call',
              'Video call with ${widget.user["name"]}',
              duration: const Duration(seconds: 2),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.call, color: Colors.white),
          onPressed: () {
            Get.snackbar(
              'Voice Call',
              'Calling ${widget.user["name"]}',
              duration: const Duration(seconds: 2),
            );
          },
        ),
      ],
    );
  }

  // 🔹 Enhanced Chat Bubbles with Image Support
  Widget _buildChatBubble(Map<String, dynamic> message) {
    final isMe = message["isMe"];
    final type = message["type"] ?? "text";
    final time = message["time"];
    final senderName = message["senderName"];

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? Colors.teal[400] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight:
                isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show sender name for group chats (optional)
            if (!isMe && messages.length > 3)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  senderName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                  ),
                ),
              ),

            // Different content based on message type
            if (type == "image")
              _buildImageMessage(message, isMe)
            else
              _buildTextMessage(message["message"], isMe),

            // Message time
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 11,
                  color: isMe ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextMessage(String text, bool isMe) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        color: isMe ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildImageMessage(Map<String, dynamic> message, bool isMe) {
    final fileUrl = message["fileUrl"];
    final filePath = message["filePath"];
    final caption = message["message"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showImagePreview(fileUrl ?? filePath),
          child: Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: filePath != null
                  ? Image.file(
                      File(filePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, color: Colors.red);
                      },
                    )
                  : CachedNetworkImage(
                      imageUrl: fileUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
            ),
          ),
        ),
        if (caption.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            caption,
            style: TextStyle(
              fontSize: 14,
              color: isMe ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ],
    );
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Center(
                child: imageUrl.startsWith('http')
                    ? CachedNetworkImage(imageUrl: imageUrl)
                    : Image.file(File(imageUrl)),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Message Input Field with Attachment
  Widget _buildMessageInput(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          // Emoji button
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.teal),
            onPressed: () {
              Get.snackbar(
                'Coming Soon',
                'Emoji picker in next update!',
                duration: const Duration(seconds: 1),
              );
            },
          ),
          // Attachment button
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.teal),
            onPressed: _showAttachmentMenu,
          ),
          // Message input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'recently';

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';

// Model class for notifications
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.data,
    required this.timestamp,
    this.isRead = false,
  });

  // Convert notification to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  // Create notification from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
    );
  }

  // Create notification from Firebase RemoteMessage
  factory NotificationModel.fromRemoteMessage(RemoteMessage message) {
    return NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      data: message.data,
      timestamp: message.sentTime ?? DateTime.now(),
    );
  }
}

// Service to manage notifications
class NotificationService {
  static const String _storageKey = 'notifications';
  List<NotificationModel> _notifications = [];

  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Get all notifications
  List<NotificationModel> get notifications => _notifications;

  // Get unread notifications count
  int get unreadCount => _notifications.where((notification) => !notification.isRead).length;

  // Initialize service and load saved notifications
  Future<void> init() async {
    await _loadNotifications();
    _setupFirebaseListeners();
  }

  // Set up Firebase message listeners
  void _setupFirebaseListeners() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _addNotification(NotificationModel.fromRemoteMessage(message));
    });

    // Handle message opens from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _addNotification(NotificationModel.fromRemoteMessage(message));
      }
    });

    // Handle message opens from background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _addNotification(NotificationModel.fromRemoteMessage(message));
    });
  }

  // Load notifications from SharedPreferences
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString(_storageKey);

      if (notificationsJson != null) {
        final List<dynamic> decoded = jsonDecode(notificationsJson);
        _notifications = decoded
            .map((item) => NotificationModel.fromJson(item))
            .toList();

        // Sort by timestamp (newest first)
        _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  // Save notifications to SharedPreferences
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = jsonEncode(_notifications.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, encodedData);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  // Add a new notification (private method)
  Future<void> _addNotification(NotificationModel notification) async {
    // Check for duplicates
    if (!_notifications.any((n) => n.id == notification.id)) {
      _notifications.insert(0, notification); // Add to beginning of list
      await _saveNotifications();
    }
  }

  // Public method for adding notifications (used by background handler)
  Future<void> addNotification(NotificationModel notification) async {
    await _addNotification(notification);
  }

  // Mark a notification as read
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((notification) => notification.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      await _saveNotifications();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    await _saveNotifications();
  }

  // Delete a notification
  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((notification) => notification.id == id);
    await _saveNotifications();
  }

  // Clear all notifications
  Future<void> clearAll() async {
    _notifications.clear();
    await _saveNotifications();
  }
}

// Notification Screen Widget
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    await _notificationService.init();
    setState(() {});
  }

  Future<void> _handleRefresh() async {
    await _loadNotifications();
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _notificationService.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'mark_all_read') {
                  await _notificationService.markAllAsRead();
                  setState(() {});
                } else if (value == 'clear_all') {
                  await _notificationService.clearAll();
                  setState(() {});
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Text('Mark all as read'),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Text('Clear all'),
                ),
              ],
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: notifications.isEmpty
            ? const Center(
          child: Text('No notifications yet'),
        )
            : ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Dismissible(
              key: Key(notification.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) async {
                await _notificationService.deleteNotification(notification.id);
                setState(() {});
              },
              child: InkWell(
                onTap: () async {
                  await _notificationService.markAsRead(notification.id);

                  // Navigate to detail view or handle the notification action
                  if (notification.data != null && notification.data!.isNotEmpty) {
                    // Handle navigation based on notification data
                    // Example: Navigator.of(context).pushNamed('/detail', arguments: notification.data);
                  }

                  setState(() {});
                },
                child: Card(
                  elevation: notification.isRead ? 1 : 3,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: notification.isRead ? Colors.grey : Theme.of(context).primaryColor,
                      child: Icon(
                        _getNotificationIcon(notification),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.body),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: !notification.isRead
                        ? Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                    )
                        : null,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationModel notification) {
    // Customize based on notification type or category
    if (notification.data != null) {
      String? type = notification.data!['type'] as String?;

      switch (type) {
        case 'Asset':
          return Icons.real_estate_agent;
        case 'Land':
          return Icons.landscape;
        case 'Vehicle':
          return Icons.directions_car;
        case 'Common':
          return Icons.campaign;
        default:
          return Icons.notifications;
      }
    }
    return Icons.notifications;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(timestamp);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}

// NotificationBadge widget to show unread count on icons
class NotificationBadge extends StatefulWidget {
  final Widget child;

  const NotificationBadge({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    _setupListener();
  }

  Future<void> _loadUnreadCount() async {
    await _notificationService.init();
    setState(() {
      _unreadCount = _notificationService.unreadCount;
    });
  }

  void _setupListener() {
    // Listen for new messages (you might want to implement a stream in NotificationService)
    FirebaseMessaging.onMessage.listen((_) {
      _loadUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (_unreadCount > 0)
          Positioned(
            right: -5,
            top: -5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// Background message handler from your original code
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  print('Body: ${message.notification?.body}');
  print('Title: ${message.notification?.title}');
  print('Payload: ${message.data}');

  // Store background notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.addNotification(
      NotificationModel.fromRemoteMessage(message)
  );
}

// Example of how to integrate with your FirebaseApi class
class UpdatedFirebaseApi {
  final firebaseMessaging = FirebaseMessaging.instance;
  final notificationService = NotificationService();

  Future<void> initNotifications() async {
    await firebaseMessaging.requestPermission();
    final fCMToken = await firebaseMessaging.getToken();

    // Subscribe to topics
    await FirebaseMessaging.instance.subscribeToTopic("Common");
    await FirebaseMessaging.instance.subscribeToTopic("Asset");
    await FirebaseMessaging.instance.subscribeToTopic("Land");
    await FirebaseMessaging.instance.subscribeToTopic("Vehicle");

    // Set up background handler
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // Initialize notification service
    await notificationService.init();

    print('FCM Token: $fCMToken');
  }
}

// To use the NotificationScreen, add it to your routes:
// routes: {
//   '/notifications': (context) => const NotificationScreen(),
// }

// To add the badge in your bottom navigation bar or app drawer:
// NotificationBadge(
//   child: Icon(Icons.notifications),
// ),
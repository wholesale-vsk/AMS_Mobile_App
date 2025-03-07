import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [
    {
      "title": "New Message",
      "message": "You have received a new message from admin.",
      "date": DateTime.now().subtract(Duration(minutes: 5)),
      "isRead": false
    },
    {
      "title": "System Update",
      "message": "A new system update is available for your account.",
      "date": DateTime.now().subtract(Duration(hours: 3)),
      "isRead": true
    },
    {
      "title": "Reminder",
      "message": "Your scheduled maintenance is tomorrow at 10:00 AM.",
      "date": DateTime.now().subtract(Duration(days: 1)),
      "isRead": false
    },
  ];

  void markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification["isRead"] = true;
      }
    });
  }

  void dismissNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  Future<void> _refreshNotifications() async {
    await Future.delayed(Duration(milliseconds: 200)); // Simulate fast refresh
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          if (notifications.any((n) => !n["isRead"]))
            TextButton(
              onPressed: markAllAsRead,
              child: const Text("Mark all as read", style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: notifications.isEmpty
            ? const Center(child: Text("No new notifications", style: TextStyle(fontSize: 16)))
            : ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            var notification = notifications[index];

            return Dismissible(
              key: Key(notification["title"]),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                dismissNotification(index);
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  leading: CircleAvatar(
                    backgroundColor: notification["isRead"] ? Colors.grey : Colors.blue,
                    child: Icon(Icons.notifications, color: Colors.white),
                  ),
                  title: Text(
                    notification["title"],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: notification["isRead"] ? Colors.black54 : Colors.black,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification["message"], maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 5),
                      Text(
                        DateFormat("MMM dd, hh:mm a").format(notification["date"]),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: notification["isRead"]
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.circle, color: Colors.blue, size: 12),
                  onTap: () {
                    setState(() {
                      notifications[index]["isRead"] = true;
                    });
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

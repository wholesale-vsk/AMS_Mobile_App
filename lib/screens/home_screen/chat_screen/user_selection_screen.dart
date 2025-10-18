import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_screen.dart';
import 'chat_screen.dart';

class UserSelectionScreen extends StatefulWidget {
  const UserSelectionScreen({super.key});

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  final List<Map<String, dynamic>> users = [
    {
      "id": "1",
      "name": "John Doe",
      "role": "Manager",
      "status": "Hey there! I am using this chat app.",
      "image": "https://randomuser.me/api/portraits/men/1.jpg",
      "isOnline": true,
      "lastSeen": null,
    },
    {
      "id": "2",
      "name": "Emma Watson",
      "role": "Officer",
      "status": "Feeling excited today!",
      "image": "https://randomuser.me/api/portraits/women/2.jpg",
      "isOnline": false,
      "lastSeen": DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      "id": "3",
      "name": "Michael Brown",
      "role": "Director",
      "status": "Available for a chat.",
      "image": "https://randomuser.me/api/portraits/men/3.jpg",
      "isOnline": true,
      "lastSeen": null,
    },
    {
      "id": "4",
      "name": "Sophia Martinez",
      "role": "Admin Officer",
      "status": "Work hard, play hard!",
      "image": "https://randomuser.me/api/portraits/women/4.jpg",
      "isOnline": false,
      "lastSeen": DateTime.now().subtract(const Duration(minutes: 30)),
    },
    {
      "id": "5",
      "name": "Chris Evans",
      "role": "Control Officer",
      "status": "Loving the new Flutter update.",
      "image": "https://randomuser.me/api/portraits/men/5.jpg",
      "isOnline": true,
      "lastSeen": null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Select a Chat",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.offAll(() => HomeScreen()), // ✅ Removed const
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return InkWell(
              onTap: () => Get.to(() => ChatScreen(user: user)),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(user["image"]),
                        ),
                        Positioned(
                          bottom: 3,
                          right: 3,
                          child: CircleAvatar(
                            radius: 9,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 7,
                              backgroundColor:
                                  user["isOnline"] ? Colors.green : Colors.red,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user["name"],
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            user["status"],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey
                                  .shade600, // ✅ Fixed deprecated withOpacity
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user["isOnline"]
                                ? "Online"
                                : "Last seen ${_formatLastSeen(user["lastSeen"])}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey
                                  .shade500, // ✅ Fixed deprecated withOpacity
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 18, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'unknown';

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

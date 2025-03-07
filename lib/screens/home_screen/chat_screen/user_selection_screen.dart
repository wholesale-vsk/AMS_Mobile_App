import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_screen.dart';
import 'chat_screen.dart';

class UserSelectionScreen extends StatefulWidget {
  @override
  _UserSelectionScreenState createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  final List<Map<String, dynamic>> users = [
    {
      "name": "John Doe",
      "status": "Hey there! I am using this chat app.",
      "image": "https://randomuser.me/api/portraits/men/1.jpg",
      "isOnline": true
    },
    {
      "name": "Emma Watson",
      "status": "Feeling excited today!",
      "image": "https://randomuser.me/api/portraits/women/2.jpg",
      "isOnline": false
    },
    {
      "name": "Michael Brown",
      "status": "Available for a chat.",
      "image": "https://randomuser.me/api/portraits/men/3.jpg",
      "isOnline": true
    },
    {
      "name": "Sophia Martinez",
      "status": "Work hard, play hard!",
      "image": "https://randomuser.me/api/portraits/women/4.jpg",
      "isOnline": false
    },
    {
      "name": "Chris Evans",
      "status": "Loving the new Flutter update.",
      "image": "https://randomuser.me/api/portraits/men/5.jpg",
      "isOnline": true
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (users.isNotEmpty) {
        Get.to(() => ChatScreen(user: users[0])); // Auto-open first user's chat
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Select a Chat", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), // 🔙 Back button
          onPressed: () => Get.offAll(() => HomeScreen()),
          // Go back to the previous screen
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
                              backgroundColor: user["isOnline"] ? Colors.green : Colors.red,
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
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            user["status"],
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

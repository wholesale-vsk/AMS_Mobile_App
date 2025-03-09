import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class SupportScreen extends StatelessWidget {
  SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Support',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: ListView(
          children: [
            _buildSupportCard(
              icon: Icons.help_outline,
              title: 'FAQs',
              subtitle: 'Find answers to common questions',
              onTap: () => Get.toNamed(AppRoutes.FAQ_SCREEN),

            ),
            const SizedBox(height: 15),
            _buildSupportCard(
              icon: Icons.chat_bubble_outline,
              title: 'Live Chat',
              subtitle: 'Chat with our support team',
              onTap: () => Get.toNamed('/liveChat'),
            ),
            const SizedBox(height: 15),
            _buildSupportCard(
              icon: Icons.email_outlined,
              title: 'Submit a Ticket',
              // route: AppRoutes.TOTAL_ASSETS_REPORT_SCREEN,
              subtitle: 'Get help from our team',
              onTap: () => Get.toNamed(AppRoutes.TICKET_SUBMIT_SCREEN),

            ),
            const SizedBox(height: 30),
            const Text(
              "Need help?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Contact us via email or submit a support request for assistance.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
  //     floatingActionButton: FloatingActionButton.extended(
  //       backgroundColor: isDarkMode ? Colors.black : Colors.blueAccent,
  //       onPressed: () => Get.toNamed('/liveChat'),
  //       icon: const Icon(Icons.support_agent, color: Colors.white),
  //       label: const Text(
  //         "Live Support",
  //         style: TextStyle(color: Colors.white),
  //       ),
  //     ),

    );
   }

  Widget _buildSupportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Icon(icon, color: Colors.blueAccent, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

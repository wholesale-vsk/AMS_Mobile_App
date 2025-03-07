import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      "question": "How do I create an account?",
      "answer": "To create an account, go to the sign-up page and enter your details. You will receive a confirmation email."
    },
    {
      "question": "How can I reset my password?",
      "answer": "Go to the login screen, click on 'Forgot Password,' and follow the instructions to reset your password."
    },
    {
      "question": "Is my data secure?",
      "answer": "Yes, we use industry-standard encryption to protect your data and ensure privacy."
    },
    {
      "question": "How can I contact support?",
      "answer": "You can contact our support team via email at support@yourapp.com or through the in-app chat."
    },
    {
      "question": "Can I change my username?",
      "answer": "Yes, go to your profile settings and update your username. Note that you can only change it once per month."
    },
  ];

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQs"),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: faqs.length,
          itemBuilder: (context, index) {
            return _buildFAQCard(faqs[index], isDarkMode);
          },
        ),
      ),
    );
  }

  // 🔹 FAQ Card UI
  Widget _buildFAQCard(Map<String, String> faq, bool isDarkMode) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          faq["question"]!,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        leading: const Icon(Icons.help_outline, color: Colors.blueAccent),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              faq["answer"]!,
              style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.grey[300] : Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CardViewData {

  //::::::::::::::::::::::::::<< Icons & Labels >>:::::::::::::::::::::::::://
  static IconData getIcon(int index) {
    List<IconData> icons = [
      Icons.dashboard_rounded,
      Icons.account_balance_rounded,
      Icons.add_home_work_rounded,
      Icons.person_add_rounded,
      Icons.notifications_rounded,
      Icons.my_library_books_rounded,
      Icons.support_agent_rounded,
      Icons.chat_rounded,
      Icons.settings_suggest_rounded,
    ];

    // Bounds check to ensure index is valid
    if (index >= 0 && index < icons.length) {
      return icons[index];
    } else {
      // Return a default icon if index is out of range
      return Icons.help_outline;
    }
  }

  static String getLabel(int index) {
    List<String> labels = [
      "Dashboard",
      "Asset",
      "Add Asset",
      "User",
      "Notification",
      "Reports",
      "Support",
      "Chats",
      "Settings",
    ];

    // Bounds check to ensure index is valid
    if (index >= 0 && index < labels.length) {
      return labels[index];
    } else {
      // Return a default label if index is out of range
      return "Unknown";
    }
  }

  // Add a getter to return the total number of items
  static int get totalItems {
    return 9; // As there are 9 items in both icons and labels
  }
}

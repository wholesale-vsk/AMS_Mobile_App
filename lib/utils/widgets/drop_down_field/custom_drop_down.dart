import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../theme/app_theme_management.dart';
import '../../theme/font_size.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> options;
  final TextEditingController controller;
  final ValueChanged<String?> onChanged;
  final String selectedItem;
  final AppThemeManager themeManager = Get.find();


   CustomDropdown({
    Key? key,
    required this.label,
    required this.options,
    required this.controller,
    required this.onChanged,
    required this.selectedItem,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        dropdownColor: themeManager.primaryWhite,
        value: selectedItem.isNotEmpty ? selectedItem : null,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Text(
                  value,
                  style: TextStyle(
                    color: themeManager.primaryColor,
                    fontSize: FontSizes.small,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          onChanged(newValue); // Notify the parent widget about the change
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: themeManager.primaryColor,
            fontSize: FontSizes.small,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: themeManager.primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: themeManager.primaryColor),
          ),
        ),
        alignment: Alignment.centerLeft, // Align dropdown items properly
      ),
    );
  }
}

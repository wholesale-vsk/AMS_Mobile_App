import 'package:flutter/material.dart';
import 'package:hexalyte_ams/utils/theme/app_theme_management.dart';
import 'package:hexalyte_ams/utils/theme/font_size.dart';
import 'package:hexalyte_ams/utils/widgets/labels/label.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final List<dynamic> options;
  final T selectedValue;
  final ValueChanged<T?> onChanged;
  final AppThemeManager themeManager;

  const CustomDropdownField({
    Key? key,
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.themeManager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppLabel(
            text: label,
            fontSize: FontSizes.small,
            fontWeight: FontWeight.w500,
            textColor: themeManager.primaryColor,
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final result = await showDropdownDialog(context);
              if (result != null) {
                onChanged(result as T);
              }
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(selectedValue.toString(),
                            style: TextStyle(color: themeManager.primaryColor)),
                        Icon(Icons.arrow_drop_down,
                            color: themeManager.primaryColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> showDropdownDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 200,
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(options[index].toString()),
                  onTap: () {
                    Navigator.of(context).pop(options[index].toString());
                  },
                );
              },
            ),
          ),
        );
      },
    );
    return result;
  }
}

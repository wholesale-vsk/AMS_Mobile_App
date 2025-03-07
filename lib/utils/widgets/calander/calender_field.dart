// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../theme/app_theme_management.dart';
//
// class CalenderField extends StatelessWidget {
//   final AppThemeManager themeManager = Get.find();
//
//   final TextEditingController controller;
//   final String hintText;
//   final double fontSize;
//   final String title;
//   final IconData icon;
//   final bool obscureText;
//   final bool readOnly;
//   final FormFieldSetter<String>? onSaved;
//   final FormFieldValidator<String>? validator;
//
//   CalenderField({
//     super.key,
//     required this.controller,
//     required this.hintText,
//     required this.title,
//     required this.icon,
//     this.fontSize = 16.0,
//     this.obscureText = false,
//     this.readOnly = true,
//     this.onSaved,
//     this.validator,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//         controller: controller,
//         obscureText: obscureText,
//         readOnly: readOnly,
//         onSaved: onSaved,
//         validator: validator,
//         decoration: InputDecoration(
//           hintText: hintText,
//           hintStyle: TextStyle(
//             // color: DarkThemeColors.primaryCoolGray,
//               color: themeManager.primaryCoolGrey,
//               fontWeight: FontWeight.w400,
//               fontSize: fontSize),
//           enabledBorder: UnderlineInputBorder(
//             borderSide: BorderSide(color: themeManager.primaryColor, width: 1),
//           ),
//           focusedBorder: UnderlineInputBorder(
//             borderSide: BorderSide(color: themeManager.primaryColor, width: 2),
//           ),
//         ),
//         onTap: () async {
//           if (readOnly) {
//             final selectedDate = await showDatePicker(
//               context: context,
//               initialDate: DateTime.now(),
//               firstDate: DateTime(1900),
//               lastDate: DateTime.now(),
//               builder: (context, child) {
//                 return Theme(
//                   data: ThemeData(
//                     colorScheme: ColorScheme.light(
//                       primary: themeManager.primaryColor,
//                       onPrimary: themeManager.backgroundColor,
//                       onSurface: themeManager.textColor,
//                     ),
//                     dialogBackgroundColor: themeManager
//                         .backgroundColor, // Background color of the date picker dialog
//                   ),
//                   child: child!,
//                 );
//               },
//             );
//
//             if (selectedDate != null) {
//               controller.text = selectedDate.toString().substring(0, 10);
//             }
//           }
//         });
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/utils/theme/font_size.dart';

import '../../theme/app_theme_management.dart';

class CalendarField extends StatelessWidget {
  final AppThemeManager themeManager = Get.find();

  final TextEditingController controller;
  final String hintText;
  final double fontSize;
  final IconData icon;
  final bool obscureText;
  final bool readOnly;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;

  CalendarField({
    super.key,
    required this.controller,
    required this.hintText,
    //required this.title,
    required this.icon,
    this.fontSize = FontSizes.small,
    this.obscureText = false,
    this.readOnly = true,
    this.onSaved,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0,),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () async {
              if (readOnly) {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2500),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData(
                        colorScheme: ColorScheme.light(
                          primary: themeManager.primaryColor,
                          onPrimary: themeManager.backgroundColor,
                          onSurface: themeManager.textColor,
                        ),
                        dialogBackgroundColor: themeManager.backgroundColor,
                      ),
                      child: child!,
                    );
                  },
                );

                if (selectedDate != null) {
                  controller.text = selectedDate.toString().substring(0, 10);
                }
              }
            },
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: themeManager.primaryColor),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      obscureText: obscureText,
                      readOnly: true,
                      onSaved: onSaved,
                      validator: validator,
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TextStyle(
                          color: themeManager.primaryColor,
                          fontWeight: FontWeight.w400,
                          fontSize: fontSize,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: themeManager.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
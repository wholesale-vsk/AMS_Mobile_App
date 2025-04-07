import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:hexalyte_ams/utils/theme/app_theme_management.dart';
import 'package:hexalyte_ams/utils/widgets/labels/label.dart';
import '../../../controllers/image_controller/image_controller.dart';


class CustomImagePickerField extends StatelessWidget {
  final String label;
  final AppThemeManager themeManager;
  final Function(String) onImageSelected; // ✅ Add callback
  final ImagePickerController controller = Get.find<ImagePickerController>(); // ✅ Use Get.find()

  CustomImagePickerField({
    Key? key,
    required this.label,
    required this.themeManager,
    required this.onImageSelected, // ✅ Require callback
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
            fontWeight: FontWeight.w500,
            textColor: themeManager.primaryColor,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              await controller.pickImage(ImageSource.gallery); // ✅ Pass ImageSource
              if (controller.selectedImage.value != null) {
                onImageSelected(controller.selectedImage.value!.path); // ✅ Send image path
              }
            },
            child: Obx(
                  () => Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: themeManager.primaryColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: controller.selectedImage.value == null
                    ? Center(
                  child: Icon(Icons.add_a_photo, color: themeManager.primaryColor, size: 50),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(controller.selectedImage.value!, fit: BoxFit.cover, width: double.infinity),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hexalyte_ams/utils/theme/font_size.dart';
import 'package:hexalyte_ams/utils/theme/responsive_size.dart';
import 'package:hexalyte_ams/utils/widgets/buttons/filled_button.dart';
import 'package:hexalyte_ams/utils/theme/app_theme_management.dart';
import 'package:hexalyte_ams/controllers/image_picker_controller.dart';

import '../../../../controllers/image_picker_controller/image_picker_controller.dart';

class TicketSubmissionController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();
  final selectedPriority = ''.obs;

  void submitForm() {
    if (formKey.currentState!.validate()) {
      Get.snackbar("Success", "Ticket submitted successfully!",
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}

class TicketSubmissionForm extends StatelessWidget {
  final AppThemeManager themeManager = Get.find();
  final TicketSubmissionController controller = Get.put(TicketSubmissionController());
  final ImagePickerController imageController = Get.put(ImagePickerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeManager.backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveSize.getWidth(size: 16),
          vertical: ResponsiveSize.getHeight(size: 20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBackButton(),
            SizedBox(height: ResponsiveSize.getHeight(size: 10)),
            Text(
              "Submit a Ticket",
              style: TextStyle(
                fontSize: FontSizes.large,
                fontWeight: FontWeight.bold,
                color: themeManager.primaryColor,
              ),
            ),
            SizedBox(height: ResponsiveSize.getHeight(size: 10)),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCardField(
                          "Subject", controller.subjectController),
                      _buildCardField(
                          "Description", controller.descriptionController,
                          maxLines: 4),
                      _buildDropdownField(
                          "Priority Level", ["Low", "Medium", "High"]),
                      _buildImagePicker(),
                      SizedBox(height: ResponsiveSize.getHeight(size: 20)),
                      AppFilledButton(
                        text: 'Submit',
                        onPressed: controller.submitForm,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: themeManager.primaryColor),
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  Widget _buildCardField(String label, TextEditingController textController,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: TextFormField(
            controller: textController,
            cursorColor: themeManager.primaryColor,
            maxLines: maxLines,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: themeManager.primaryColor,
                fontSize: FontSizes.small,
              ),
              border: InputBorder.none,
            ),
            validator: (value) =>
            value!.isEmpty ? "$label is required" : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Obx(() => DropdownButtonFormField<String>(
            value: controller.selectedPriority.value.isEmpty
                ? null
                : controller.selectedPriority.value,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: themeManager.primaryColor,
                fontSize: FontSizes.small,
              ),
              border: InputBorder.none,
            ),
            items: options
                .map((option) => DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            ))
                .toList(),
            onChanged: (value) {
              controller.selectedPriority.value = value!;
            },
            validator: (value) =>
            value == null || value.isEmpty ? "Please select a priority level" : null,
          )),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Attach Screenshot",
              style: TextStyle(
                  color: themeManager.primaryColor, fontSize: FontSizes.small)),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () => imageController.pickImage(ImageSource.gallery),
            child: Obx(
                  () => Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: themeManager.primaryColor),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, blurRadius: 4, spreadRadius: 1)
                  ],
                ),
                child: imageController.selectedImage.value == null
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image,
                          color: themeManager.primaryColor, size: 40),
                      SizedBox(height: 4),
                      Text("Tap to Upload Image",
                          style: TextStyle(
                              color: themeManager.primaryColor,
                              fontSize: FontSizes.small)),
                    ],
                  ),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    imageController.selectedImage.value!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

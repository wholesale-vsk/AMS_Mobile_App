import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/controllers/image_picker_controller/image_picker_controller.dart';
import 'package:hexalyte_ams/utils/widgets/calander/calender_field.dart';
import 'package:hexalyte_ams/utils/widgets/drop_down_field/custom_drop_down.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../controllers/building_controller/building_controller.dart'; // ✅ Fixed import case sensitivity issue

class AddBuildingScreen extends StatelessWidget {
  final BuildingController buildingController = Get.find();
  final ImagePickerController imagePickerController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Add Building',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: buildingController.buildingFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField('Building Name', buildingController.buildingNameController),
                CustomDropdown(
                  label: 'Building Type',
                  options: const ['RESIDENTIAL', 'COMMERCIAL', 'INDUSTRIAL'],
                  selectedItem: buildingController.buildingTypeController.text,
                  onChanged: (value) {
                    buildingController.buildingTypeController.text = value!;
                  },
                  controller: buildingController.buildingTypeController,
                ),
                _buildTextField('Number of Floors', buildingController.numberOfFloorsController, isNumeric: true),
                _buildTextField('Total Area (sq. ft.)', buildingController.totalAreaController, isNumeric: true),
                _buildTextField('Address', buildingController.buildingAddressController),
                _buildTextField('City', buildingController.buildingCityController),
                _buildTextField('Province', buildingController.buildingProvinceController),
                _buildTextField('Owner Name', buildingController.ownerNameController),
                CalendarField(
                  controller: buildingController.constructionDateController,
                  hintText: 'Construction Date',
                  icon: Icons.calendar_today,
                ),
                _buildTextField('Construction Cost (LKR)', buildingController.constructionCostController, isNumeric: true),
                _buildImagePickerField(),
                const SizedBox(height: 20),
                Obx(() => ElevatedButton(
                  onPressed: buildingController.isLoading.value
                      ? null
                      : () async {
                    if (buildingController.buildingFormKey.currentState?.validate() ?? false) {
                      await buildingController.addBuilding();
                    } else {
                      Get.snackbar("Validation Error", "Please fill all required fields.");
                    }
                  },
                  child: Text(buildingController.isLoading.value ? 'Saving...' : 'Save Building'),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //:::::::::::::::::::::::::::::::::<< BUILD TEXT FIELD >>::::::::::::::::::::::::::::::::://
  Widget _buildTextField(String label, TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        cursorColor: Colors.blueAccent,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Please enter $label';
          if (isNumeric && double.tryParse(value) == null) return '$label must be a valid number';
          return null;
        },
      ),
    );
  }

  //:::::::::::::::::::::::::::::::::<< IMAGE PICKER FIELD >>::::::::::::::::::::::::::::::::://
  Widget _buildImagePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Building Image", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final XFile? pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
            if (pickedImage != null) {
              File selectedFile = File(pickedImage.path);
              imagePickerController.selectedImage.value = selectedFile;
              buildingController.buildingImageController.text = pickedImage.path;
              buildingController.update();
            } else {
              Get.snackbar("Image Selection", "No image was selected.");
            }
          },
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Obx(() {
              return imagePickerController.selectedImage.value != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  imagePickerController.selectedImage.value!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
                  : const Center(
                child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
              );
            }),
          ),
        ),
        const SizedBox(height: 10),
        Obx(() {
          return imagePickerController.selectedImage.value != null
              ? ElevatedButton(
            onPressed: () {
              Get.snackbar("Image Selected", "Building image added successfully.");
            },
            child: const Text("Use This Image"),
          )
              : const SizedBox.shrink();
        }),
      ],
    );
  }
}

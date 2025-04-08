import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'dart:io';

import '../../../../../controllers/Building_Controller/building_controller.dart';
import '../../../../../utils/widgets/calander/calender_field.dart';
import 'package:hexalyte_ams/utils/widgets/drop_down_field/custom_drop_down.dart';

class AddBuildingScreen extends StatelessWidget {
  final BuildingController buildingController = Get.put(BuildingController());
  final Logger _logger = Logger();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Add Building',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: buildingController.buildingFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader(context, "Building Details", Icons.business),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  Column(
                    children: [
                      _buildTextField('Building Name', buildingController.buildingNameController,
                          prefixIcon: Icons.home),
                      const SizedBox(height: 16),
                      CustomDropdown(
                        label: 'Building Type',
                        options: const ['RESIDENTIAL', 'COMMERCIAL', 'INDUSTRIAL', 'AGRICULTURAL'],
                        controller: buildingController.buildingTypeController,
                        onChanged: (value) {
                          buildingController.buildingTypeController.text = value!;
                        },
                        selectedItem: buildingController.buildingTypeController.text,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField('Floors', buildingController.numberOfFloorsController,
                                prefixIcon: Icons.stairs, isNumeric: true),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField('Area (sq.m)', buildingController.totalAreaController,
                                prefixIcon: Icons.square_foot, isNumeric: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Address', buildingController.buildingAddressController,
                          prefixIcon: Icons.location_on),
                      const SizedBox(height: 16),
                      _buildTextField('City', buildingController.buildingCityController,
                          prefixIcon: Icons.location_city),
                      const SizedBox(height: 16),
                      _buildTextField('Province', buildingController.buildingProvinceController,
                          prefixIcon: Icons.map),
                      const SizedBox(height: 16),
                      _buildTextField('Owner Name', buildingController.ownerNameController,
                          prefixIcon: Icons.person),
                      const SizedBox(height: 16),
                      _buildTextField('Purpose of Use', buildingController.purposeOfUseController,
                          prefixIcon: Icons.category),
                    ],
                  ),
                ),


                const SizedBox(height: 24),
                _buildSectionHeader(context, "Purchase Details", Icons.receipt_long),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  Column(
                    children: [
                      CalendarField(
                        controller: buildingController.purchaseDateController,
                        hintText: 'Purchase Date',
                        icon: Icons.calendar_today,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Purchase Price', buildingController.purchasePriceController,
                          prefixIcon: Icons.attach_money, isNumeric: true),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader(context, "Council Tax Details", Icons.account_balance),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  Column(
                    children: [
                      _buildTextField('Council value', buildingController.councilTaxController,
                          prefixIcon: Icons.attach_money, isNumeric: true),
                      const SizedBox(height: 16),

                      CalendarField(
                        controller: buildingController.councilTaxDateController,
                        hintText: 'Council Tax Date',
                        icon: Icons.calendar_today,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader(context, "Lease Details", Icons.description),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  Column(
                    children: [
                      _buildTextField('Lease Value', buildingController.leaseValueController,
                          prefixIcon: Icons.payments, isNumeric: true),
                      const SizedBox(height: 16),
                      CalendarField(
                        controller: buildingController.leaseDateController,
                        hintText: 'Lease Date',
                        icon: Icons.calendar_today,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader(context, "Building Image", Icons.image),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  Column(
                    children: [
                      _buildImagePicker(context),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Obx(() => ElevatedButton(
                  onPressed: buildingController.isLoading.value
                      ? null
                      : () async {
                    if (buildingController.buildingFormKey.currentState?.validate() ?? false) {
                      await buildingController.addBuilding();
                    } else {
                      Get.snackbar(
                        "Validation Error",
                        "Please fill all required fields.",
                        backgroundColor: Colors.red[100],
                        colorText: Colors.red[800],
                        snackPosition: SnackPosition.TOP,
                        margin: EdgeInsets.all(16),
                        borderRadius: 10,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildingController.isLoading.value
                          ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                      )
                          : Icon(Icons.save),
                      SizedBox(width: 10),
                      Text(
                        buildingController.isLoading.value ? 'Saving...' : 'Save Building',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700], size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumeric = false, IconData? prefixIcon}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      cursorColor: Colors.blue[700],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey[600]) : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter $label';
        if (isNumeric && double.tryParse(value) == null) return '$label must be a valid number';
        return null;
      },
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    // Add an RxString to track image path changes
    final imagePath = buildingController.buildingImageController.text.obs;

    // Add a listener to keep it in sync with the TextEditingController
    buildingController.buildingImageController.addListener(() {
      imagePath.value = buildingController.buildingImageController.text;
    });

    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Building Image',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: imagePath.value.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'No image selected',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
              : ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(imagePath.value),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _getImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _getImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            if (imagePath.value.isNotEmpty) ...[
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  buildingController.buildingImageController.text = '';
                  imagePath.value = '';
                },
                icon: const Icon(Icons.delete),
                label: const Text('Remove'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ],
    ));
  }
  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1000,
      maxHeight: 1000,
    );

    if (pickedFile != null) {
      final String extension = pickedFile.path
          .split('.')
          .last
          .toLowerCase();

      if (extension == 'png' || extension == 'jpg' || extension == 'jpeg') {
        // Accept both PNG and JPEG formats
        _logger.i("Selected Image: ${pickedFile.path}");
        buildingController.buildingImageController.text = pickedFile.path;
      } else {
        // Inform user if an unsupported format is selected
        _logger.w("Unsupported file format: ${pickedFile.path}");
        Get.snackbar('Format Error', 'Please select a PNG or JPEG image');
      }
    }
  }

}
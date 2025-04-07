import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/controllers/vehicle_controller/vehicle_controller.dart';

import 'package:hexalyte_ams/utils/widgets/calander/calender_field.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../../controllers/image_controller/image_controller.dart';

class AddVehicleScreen extends StatelessWidget {
  final VehicleController vehicleController = Get.put(VehicleController());
  final ImagePickerController imagePickerController = Get.put(ImagePickerController());

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
          'Add Vehicle',
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
            key: vehicleController.vehicleFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader(context, "Vehicle Details", Icons.directions_car),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  Column(
                    children: [
                      _buildTextField('Model', vehicleController.vehicleModelController,
                          prefixIcon: Icons.model_training),
                      const SizedBox(height: 16),
                      _buildTextField('Type', vehicleController.vehicleTypeController,
                          prefixIcon: Icons.branding_watermark),
                      const SizedBox(height: 16),
                      _buildTextField('Brand', vehicleController.brandController,
                          prefixIcon: Icons.branding_watermark),
                      const SizedBox(height: 16),
                      _buildTextField('Registration Number', vehicleController.registrationNumberController,
                          prefixIcon: Icons.app_registration),
                      const SizedBox(height: 16),
                      _buildTextField('Owner Name', vehicleController.ownerNameController,
                          prefixIcon: Icons.person),
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
                      _buildTextField('Purchase Price', vehicleController.purchasePriceController,
                          isNumeric: true, prefixIcon: Icons.attach_money),
                      const SizedBox(height: 16),
                      CalendarField(
                        controller: vehicleController.purchaseDateController,
                        hintText: 'Purchase Date',
                        icon: Icons.calendar_today,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Mileage', vehicleController.mileageController,
                          isNumeric: true, prefixIcon: Icons.speed),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader(context, "MOT Details", Icons.assignment),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  Column(
                    children: [
                      CalendarField(
                        controller: vehicleController.motDateController,
                        hintText: 'MOT Date',
                        icon: Icons.calendar_today,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('MOT Value', vehicleController.motValueController,
                          isNumeric: true, prefixIcon: Icons.monetization_on),
                      const SizedBox(height: 16),
                      CalendarField(
                        controller: vehicleController.motExpiredDateController,
                        hintText: 'MOT Expired Date',
                        icon: Icons.calendar_today,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader(context, "Service Details", Icons.build),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  Column(
                    children: [
                      CalendarField(
                        controller: vehicleController.serviceDateController,
                        hintText: 'Last Service Date',
                        icon: Icons.calendar_today,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader(context, "Insurance Details", Icons.security),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  Column(
                    children: [
                      CalendarField(
                        controller: vehicleController.insuranceDateController,
                        hintText: 'Insurance Date',
                        icon: Icons.calendar_today,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Insurance Value', vehicleController.insuranceValueController,
                          isNumeric: true, prefixIcon: Icons.payments),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader(context, "Vehicle Image", Icons.image),
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
                  onPressed: vehicleController.isLoading.value
                      ? null
                      : () async {
                    if (vehicleController.vehicleFormKey.currentState?.validate() ?? false) {
                      await vehicleController.addVehicle();
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
                      vehicleController.isLoading.value
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Icon(Icons.save),
                      SizedBox(width: 10),
                      Text(
                        vehicleController.isLoading.value ? 'Saving...' : 'Save Vehicle',
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
    final imagePath = vehicleController.vehicleImageController?.text.obs ?? ''.obs;

    // Add a listener to keep it in sync with the TextEditingController if it exists
    if (vehicleController.vehicleImageController != null) {
      vehicleController.vehicleImageController!.addListener(() {
        imagePath.value = vehicleController.vehicleImageController!.text;
      });
    }

    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle Image',
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
                  if (vehicleController.vehicleImageController != null) {
                    vehicleController.vehicleImageController!.text = '';
                  }
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

    if (pickedFile != null && vehicleController.vehicleImageController != null) {
      vehicleController.vehicleImageController!.text = pickedFile.path;
    }
  }
}
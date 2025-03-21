import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hexalyte_ams/controllers/vehicle_controller/vehicle_controller.dart';
import 'package:hexalyte_ams/controllers/image_picker_controller/image_picker_controller.dart';
import 'package:hexalyte_ams/utils/widgets/calander/calender_field.dart';
import 'package:hexalyte_ams/utils/widgets/drop_down_field/custom_drop_down.dart';
import 'dart:io';

class AddVehicleScreen extends StatelessWidget {
  final VehicleController vehicleController = Get.put(VehicleController());
  final ImagePickerController imagePickerController = Get.put(ImagePickerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back(); // Directly go back without confirmation
          },
        ),
        title: const Text(
          'Add Vehicle',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
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
                _buildSectionHeader(context, "Purchase Details", Icons.shopping_cart),
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
                        icon: Icons.calendar_month,
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
                        icon: Icons.calendar_month,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('MOT Value', vehicleController.motValueController,
                          isNumeric: true, prefixIcon: Icons.monetization_on),
                      const SizedBox(height: 16),
                      CalendarField(
                        controller: vehicleController.motExpiredDateController,
                        hintText: 'MOT Expired Date',
                        icon: Icons.calendar_month,
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
                        icon: Icons.calendar_month,
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
                        icon: Icons.calendar_month,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Insurance Value', vehicleController.insuranceValueController,
                          isNumeric: true, prefixIcon: Icons.payments),
                    ],
                  ),
                ),

                // Uncomment to add image picker functionality
                // const SizedBox(height: 24),
                // _buildSectionHeader(context, "Vehicle Image", Icons.image),
                // const SizedBox(height: 16),
                // _buildCard(context, _buildImagePickerField()),

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
                        snackPosition: SnackPosition.BOTTOM,
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
            offset: const Offset(0, 3),
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

// Uncomment to add image picker functionality
// Widget _buildImagePickerField() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.stretch,
//     children: [
//       InkWell(
//         onTap: () async {
//           await imagePickerController.pickImage(ImageSource.gallery);
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Obx(() {
//           File? selectedImage = imagePickerController.selectedImage.value;
//           return Container(
//             height: 150,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               border: Border.all(color: Colors.grey[300]!),
//               borderRadius: BorderRadius.circular(12),
//               image: selectedImage != null
//                   ? DecorationImage(image: FileImage(selectedImage), fit: BoxFit.cover)
//                   : null,
//             ),
//             child: selectedImage == null
//                 ? Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.add_a_photo, size: 40, color: Colors.grey[600]),
//                       SizedBox(height: 8),
//                       Text(
//                         "Tap to select vehicle image",
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                     ],
//                   )
//                 : null,
//           );
//         }),
//       ),
//     ],
//   );
// }
}
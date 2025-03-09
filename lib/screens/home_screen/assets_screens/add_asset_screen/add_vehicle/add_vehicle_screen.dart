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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back(); // Directly go back without confirmation
          },
        ),
        title: const Text(
          'Add Vehicle',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: vehicleController.vehicleFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("vehicle Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              _buildTextField('Model', vehicleController.vehicleModelController),
              _buildTextField('Brand', vehicleController.brandController),
              _buildTextField('Vehicle Registration Number', vehicleController.registrationNumberController),
              _buildTextField('Owner Name', vehicleController.ownerNameController),

              const Text("Purchase Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              _buildTextField('Purchase Price', vehicleController.purchasePriceController, isNumeric: true),

              CalendarField(
                controller: vehicleController.purchaseDateController,
                hintText: 'Purchase Date',
                icon: Icons.calendar_month,
              ),

              _buildTextField('Mileage', vehicleController.mileageController, isNumeric: true),

              const Text("MOT Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              CalendarField(
                controller: vehicleController.motDateController,
                hintText: 'MOT Date',
                icon: Icons.calendar_month,
              ),

              _buildTextField('MOT Value', vehicleController.motValueController, isNumeric: true),

              CalendarField(
                controller: vehicleController.motExpiredDateController,
                hintText: 'MOT Expired Date',
                icon: Icons.calendar_month,
              ),

              const Text("Service Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              CalendarField(
                controller: vehicleController.serviceDateController,
                hintText: 'Last Service Date',
                icon: Icons.calendar_month,
              ),

              const Text("Insurance Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              CalendarField(
                controller: vehicleController.insuranceDateController,
                hintText: 'Insurance Date',
                icon: Icons.calendar_month,
              ),
              _buildTextField('Insurance Value', vehicleController.insuranceValueController, isNumeric: true),

              // _buildImagePickerField(),

              const SizedBox(height: 20),

              Obx(() => ElevatedButton(
                onPressed: vehicleController.isLoading.value
                    ? null
                    : () async {
                  if (vehicleController.vehicleFormKey.currentState?.validate() ?? false) {
                    await vehicleController.addVehicle();
                  } else {
                    Get.snackbar("Validation Error", "Please fill all required fields.");
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(vehicleController.isLoading.value ? 'Saving...' : 'Save Vehicle'),
              )),
            ],
          ),
        ),
      ),
    );
  }

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
          if (value == null || value.isEmpty) return 'Please enter $label';
          if (isNumeric && double.tryParse(value) == null) return '$label must be a valid number';
          return null;
        },
      ),
    );
  }

//   Widget _buildImagePickerField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         const Text("Vehicle Image", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
//         const SizedBox(height: 8),
//         InkWell(
//           onTap: () async {
//             await imagePickerController.pickImage(ImageSource.gallery);
//           },
//           borderRadius: BorderRadius.circular(12),
//           child: Obx(() {
//             File? selectedImage = imagePickerController.selectedImage.value;
//             return Container(
//               height: 120,
//               width: 120,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//                 borderRadius: BorderRadius.circular(12),
//                 image: selectedImage != null
//                     ? DecorationImage(image: FileImage(selectedImage), fit: BoxFit.cover)
//                     : null,
//               ),
//               child: selectedImage == null
//                   ? const Center(child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey))
//                   : null,
//             );
//           }),
//         ),
//       ],
//     );
//   }
 }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../../controllers/Building_Controller/building_controller.dart';
import '../../../../../utils/widgets/calander/calender_field.dart';
import 'package:hexalyte_ams/utils/widgets/drop_down_field/custom_drop_down.dart';


class AddBuildingScreen extends StatelessWidget {
  final BuildingController buildingController = Get.put(BuildingController());

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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: buildingController.buildingFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const Text("Building Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              _buildTextField('Building Name', buildingController.buildingNameController),

              CustomDropdown(
                label: 'Land Type',
                options: const ['RESIDENTIAL', 'COMMERCIAL', 'INDUSTRIAL', 'AGRICULTURAL'],
                controller: buildingController.buildingTypeController,
                onChanged: (value) {
                  buildingController.buildingTypeController.text = value!;
                },
                selectedItem: buildingController.buildingTypeController.text,
              ),



              _buildTextField('Number of Floors', buildingController.numberOfFloorsController, isNumeric: true),
              _buildTextField('Total Area (sq.m)', buildingController.totalAreaController, isNumeric: true),
              _buildTextField('Address', buildingController.buildingAddressController),
              _buildTextField('City', buildingController.buildingCityController),
              _buildTextField('Owner Name', buildingController.ownerNameController),
              _buildTextField('Purpose of Use', buildingController.purposeOfUseController),

              const Text("Purchase Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              CalendarField(
                controller: buildingController.purchaseDateController,
                hintText: 'Purchase Date',
                icon: Icons.calendar_today,
              ),
              _buildTextField('Purchase Price', buildingController.purchasePriceController, isNumeric: true),

              const Text("Council Tax Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

              _buildTextField('Construction Cost', buildingController.councilTaxValueController, isNumeric: true),
              CalendarField(
                controller: buildingController.councilTaxDateController,
                hintText: 'council Tax Date',
                icon: Icons.calendar_today,
              ),

              const Text("lease Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

              _buildTextField('lease value', buildingController.leaseValueController, isNumeric: true),
              CalendarField(
                controller: buildingController.leaseDateController,
                hintText: 'lease Date',
                icon: Icons.calendar_today,
              ),
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
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(buildingController.isLoading.value ? 'Saving...' : 'Save Building'),
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
}

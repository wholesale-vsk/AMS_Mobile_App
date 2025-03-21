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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Add Building',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
                        label: 'Land Type',
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
                      _buildTextField('Construction Cost', buildingController.councilTaxValueController,
                          prefixIcon: Icons.construction, isNumeric: true),
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
}
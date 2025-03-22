import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../controllers/vehicle_controller/vehicle_controller.dart'; // Update the path as needed

class VehicleUpdatePage extends StatefulWidget {
  final Map<String, dynamic>? vehicleData;
  final dynamic asset;

  const VehicleUpdatePage({
    super.key,
    this.vehicleData,
    this.asset, required vehicle, required Map land,
  });

  @override
  _VehicleUpdatePageState createState() => _VehicleUpdatePageState();
}

class _VehicleUpdatePageState extends State<VehicleUpdatePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late VehicleController _vehicleController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize the vehicle controller
    _vehicleController = Get.put(VehicleController());

    // Populate form with vehicle data if available
    if (widget.vehicleData != null) {
      _populateForm();
    }
  }

  // Fill the form with existing vehicle data
  void _populateForm() {
    final data = widget.vehicleData!;

    _vehicleController.registrationNumberController.text = data['registrationNumber']?.toString() ?? data['vrn']?.toString() ?? '';
    _vehicleController.vehicleModelController.text = data['vehicleModel']?.toString() ?? data['model']?.toString() ?? '';
    _vehicleController.vehicleTypeController.text = data['vehicleType']?.toString() ?? data['vehicle_type']?.toString() ?? '';
    _vehicleController.vehicleImageController.text = data['vehicleImage']?.toString() ?? data['imageURL']?.toString() ?? '';
    _vehicleController.motDateController.text = data['motDate']?.toString() ?? '';
    _vehicleController.motExpiredDateController.text = data['motExpiredDate']?.toString() ?? '';
    _vehicleController.purchaseDateController.text = data['purchaseDate']?.toString() ?? '';
    _vehicleController.purchasePriceController.text = data['purchasePrice']?.toString() ?? '';
    _vehicleController.insuranceDateController.text = data['insuranceDate']?.toString() ?? '';
    _vehicleController.insuranceValueController.text = data['insuranceValue']?.toString() ?? '';
    _vehicleController.motValueController.text = data['motValue']?.toString() ?? '';
    _vehicleController.ownerNameController.text = data['ownerName']?.toString() ?? data['owner_name']?.toString() ?? '';
    _vehicleController.mileageController.text = data['mileage']?.toString() ?? data['milage']?.toString() ?? data[' milage']?.toString() ?? '';
    _vehicleController.vehicleIdController.text = data['vehicleId']?.toString() ?? '';

    // Handle brand if available
    if (data['brand'] != null) {
      _vehicleController.brandController.text = data['brand']?.toString() ?? '';
    }

    // Handle service date if available
    if (data['serviceDate'] != null) {
      _vehicleController.serviceDateController.text = data['serviceDate']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime initialDate;
    try {
      initialDate = DateTime.tryParse(controller.text) ?? DateTime.now();
    } catch (e) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submitForm() {
    if (_vehicleController.vehicleFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create updated data map
        final updatedData = {
          'registrationNumber': _vehicleController.registrationNumberController.text,
          'vrn': _vehicleController.registrationNumberController.text, // For compatibility
          'vehicleModel': _vehicleController.vehicleModelController.text,
          'model': _vehicleController.vehicleModelController.text, // For compatibility
          'vehicleType': _vehicleController.vehicleTypeController.text,
          'vehicle_type': _vehicleController.vehicleTypeController.text, // For compatibility
          'vehicleImage': _vehicleController.vehicleImageController.text,
          // 'imageURL': _vehicleController.vehicleImageController.text, // For compatibility
          'motDate': _vehicleController.motDateController.text,
          'motExpiredDate': _vehicleController.motExpiredDateController.text,
          'serviceDate': _vehicleController.serviceDateController.text,
          'purchaseDate': _vehicleController.purchaseDateController.text,
          'purchasePrice': _vehicleController.purchasePriceController.text,
          'insuranceDate': _vehicleController.insuranceDateController.text,
          'insuranceValue': _vehicleController.insuranceValueController.text,
          'motValue': _vehicleController.motValueController.text,
          'ownerName': _vehicleController.ownerNameController.text,
          'owner_name': _vehicleController.ownerNameController.text, // For compatibility
          'mileage': _vehicleController.mileageController.text,
          'milage': _vehicleController.mileageController.text, // For compatibility
          ' milage': _vehicleController.mileageController.text, // For compatibility with space prefix
          'brand': _vehicleController.brandController.text,
          'category': 'Vehicle', // Ensure category is set
        };

        Get.back(result: updatedData);
        Get.snackbar(
            'Success',
            'Vehicle details updated successfully!',
            snackPosition: SnackPosition.BOTTOM
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to update vehicle details: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildFormField(String label, TextEditingController controller, {
    TextInputType inputType = TextInputType.text,
    bool isDate = false,
    bool isRequired = true,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        readOnly: isDate,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: isDate
              ? IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context, controller),
          )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          if (isDate && value != null && value.isNotEmpty && DateTime.tryParse(value) == null) {
            return 'Enter a valid date (yyyy-MM-dd)';
          }
          return null;
        },
        onTap: isDate ? () => _selectDate(context, controller) : null,
      ),
    );
  }

  Widget _buildFormSection(String title, List<Widget> fields) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            ...fields,
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBasicInfoFields() {
    return [

      _buildFormField('Registration Number', _vehicleController.registrationNumberController,
          prefixIcon: Icons.confirmation_number),
      _buildFormField('Brand', _vehicleController.brandController,
          prefixIcon: Icons.branding_watermark),
      _buildFormField('Model', _vehicleController.vehicleModelController,
          prefixIcon: Icons.directions_car),
      _buildFormField('Vehicle Type', _vehicleController.vehicleTypeController,
          prefixIcon: Icons.category),
    ];
  }

  List<Widget> _buildOwnerInfoFields() {
    return [
      _buildFormField('Owner Name', _vehicleController.ownerNameController,
          prefixIcon: Icons.person),
      _buildFormField('Mileage', _vehicleController.mileageController,
          inputType: TextInputType.number, prefixIcon: Icons.speed),
      // _buildFormField('Vehicle Image URL', _vehicleController.vehicleImageController,
      //     prefixIcon: Icons.image),
      const SizedBox(height: 16),

      // // Image preview
      // Obx(() {
      //   final imageUrl = _vehicleController.vehicleImageController.text;
      //   if (imageUrl.isNotEmpty) {
      //     return Container(
      //       width: double.infinity,
      //       height: 200,
      //       decoration: BoxDecoration(
      //         border: Border.all(color: Colors.grey.shade300),
      //         borderRadius: BorderRadius.circular(12),
      //       ),
      //       child: ClipRRect(
      //         borderRadius: BorderRadius.circular(12),
      //         child: Image.network(
      //           imageUrl,
      //           fit: BoxFit.cover,
      //           errorBuilder: (context, error, stackTrace) => Center(
      //             child: Column(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //               children: [
      //                 Icon(Icons.broken_image, size: 48, color: Colors.grey.shade400),
      //                 const SizedBox(height: 8),
      //                 const Text('Image not available'),
      //               ],
      //             ),
      //           ),
      //         ),
      //       ),
      //     );
      //   } else {
      //     return const SizedBox.shrink();
      //   }
      // }),
    ];
  }

  List<Widget> _buildMotInsuranceFields() {
    return [
      Row(
        children: [
          Expanded(
            child: _buildFormField('MOT Date', _vehicleController.motDateController,
                isDate: true, prefixIcon: Icons.date_range),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildFormField('MOT Expiry Date', _vehicleController.motExpiredDateController,
                isDate: true, prefixIcon: Icons.date_range),
          ),
        ],
      ),
      _buildFormField('MOT Value', _vehicleController.motValueController,
          inputType: TextInputType.number, prefixIcon: Icons.attach_money),
      Row(
        children: [
          Expanded(
            child: _buildFormField('Insurance Date', _vehicleController.insuranceDateController,
                isDate: true, prefixIcon: Icons.date_range),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildFormField('Service Date', _vehicleController.serviceDateController,
                isDate: true, prefixIcon: Icons.build),
          ),
        ],
      ),
      _buildFormField('Insurance Value', _vehicleController.insuranceValueController,
          inputType: TextInputType.number, prefixIcon: Icons.attach_money),
    ];
  }

  List<Widget> _buildFinancialFields() {
    return [
      Row(
        children: [
          Expanded(
            child: _buildFormField('Purchase Date', _vehicleController.purchaseDateController,
                isDate: true, prefixIcon: Icons.date_range),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildFormField('Purchase Price', _vehicleController.purchasePriceController,
                inputType: TextInputType.number, prefixIcon: Icons.attach_money),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Define tabs
    final tabs = [
      const Tab(icon: Icon(Icons.directions_car), text: 'Basic Info'),
      const Tab(icon: Icon(Icons.person), text: 'Owner Info'),
      const Tab(icon: Icon(Icons.verified_user), text: 'MOT & Insurance'),
      const Tab(icon: Icon(Icons.attach_money), text: 'Financial'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Vehicle Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _submitForm,
            tooltip: 'Save Changes',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() => _vehicleController.isLoading.value || _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _vehicleController.vehicleFormKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Basic Info Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildFormSection('Basic Information', _buildBasicInfoFields()),
            ),

            // Owner Info Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildFormSection('Owner Information', _buildOwnerInfoFields()),
            ),

            // MOT & Insurance Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildFormSection('MOT & Insurance Details', _buildMotInsuranceFields()),
            ),

            // Financial Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildFormSection('Financial Information', _buildFinancialFields()),
            ),
          ],
        ),
      )),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Obx(() => ElevatedButton(
          onPressed: _vehicleController.isLoading.value || _isLoading
              ? null
              : () async {
            if (_vehicleController.vehicleFormKey.currentState?.validate() ?? false) {
              await _vehicleController.updateVehicle();
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
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: _vehicleController.isLoading.value || _isLoading
              ? const CircularProgressIndicator()
              : const Text(
            'Update Vehicle',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        )),
      ),
    );
  }
}
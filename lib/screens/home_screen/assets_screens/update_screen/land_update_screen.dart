import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../controllers/land_controller/land_controller.dart'; // Update the path as needed

class LandUpdatePage extends StatefulWidget {
  final Map<String, dynamic>? landData;
  final dynamic asset;

  const LandUpdatePage({
    super.key,
    this.landData,
    this.asset, required Map<String, dynamic> land, required Map<String, dynamic> vehicle,
  });

  @override
  _LandUpdatePageState createState() => _LandUpdatePageState();
}

class _LandUpdatePageState extends State<LandUpdatePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LandController _landController;
  bool _isLoading = false;

  // Define land type options
  final List<String> _landTypeOptions = [
    'RESIDENTIAL',
    'COMMERCIAL',
    'INDUSTRIAL',
    'AGRICULTURAL'
  ];

  String _selectedLandType = 'RESIDENTIAL';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize the land controller
    _landController = Get.put(LandController());

    // Populate form with land data if available
    if (widget.landData != null) {
      _populateForm();
    }
  }

  // Fill the form with existing land data
  void _populateForm() {
    final data = widget.landData!;

    _landController.landIdController.text = data['landId']?.toString() ?? data['id']?.toString() ?? '';
    _landController.landNameController.text = data['landName']?.toString() ?? data['name']?.toString() ?? '';

    // Set the selected land type if it exists in the data
    final existingType = data['landType']?.toString() ?? data['type']?.toString() ?? '';
    if (existingType.isNotEmpty && _landTypeOptions.contains(existingType.toUpperCase())) {
      _selectedLandType = existingType.toUpperCase();
    }
    _landController.landTypeController.text = _selectedLandType;

    _landController.landSizeController.text = data['landSize']?.toString() ?? '';
    _landController.landAddressController.text = data['landAddress']?.toString() ?? data['address']?.toString() ?? '';
    _landController.landCityController.text = data['landCity']?.toString() ?? data['city']?.toString() ?? '';
    _landController.landProvinceController.text = data['landProvince']?.toString() ?? data['province']?.toString() ?? '';
    _landController.purchaseDateController.text = data['purchaseDate']?.toString() ?? '';
    _landController.purchasePriceController.text = data['purchasePrice']?.toString() ?? '';
    _landController.landImageController.text = data['landImage']?.toString() ?? data['imageURL']?.toString() ?? '';
    _landController.leaseDateController.text = data['leaseDate']?.toString() ?? data['lease_date']?.toString() ?? '';
    _landController.leaseValueController.text = data['leaseValue']?.toString() ?? '';
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
    if (_landController.landFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create updated data map
        final updatedData = {
          'landId': _landController.landIdController.text,
          'id': _landController.landIdController.text, // For compatibility
          'landName': _landController.landNameController.text,
          'name': _landController.landNameController.text, // For compatibility
          'landType': _selectedLandType,
          'type': _selectedLandType, // For compatibility
          'landSize': _landController.landSizeController.text,
          'landAddress': _landController.landAddressController.text,
          'address': _landController.landAddressController.text, // For compatibility
          'landCity': _landController.landCityController.text,
          'city': _landController.landCityController.text, // For compatibility
          'landProvince': _landController.landProvinceController.text,
          'province': _landController.landProvinceController.text, // For compatibility
          'purchaseDate': _landController.purchaseDateController.text,
          'purchasePrice': _landController.purchasePriceController.text,
          'landImage': _landController.landImageController.text,
          'imageURL': _landController.landImageController.text, // For compatibility
          'leaseDate': _landController.leaseDateController.text,
          'lease_date': _landController.leaseDateController.text, // For compatibility
          'leaseValue': _landController.leaseValueController.text,
          'category': 'Land', // Ensure category is set
        };

        Get.back(result: updatedData);
        Get.snackbar(
            'Success',
            'Land details updated successfully!',
            snackPosition: SnackPosition.BOTTOM
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to update land details: $e',
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

  Widget _buildLandTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedLandType,
        decoration: InputDecoration(
          labelText: 'Land Type',
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
          prefixIcon: const Icon(Icons.category),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: _landTypeOptions.map((String type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedLandType = newValue;
              _landController.landTypeController.text = newValue;
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Land Type is required';
          }
          return null;
        },
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
      _buildFormField('Land Name', _landController.landNameController,
          prefixIcon: Icons.title),
      _buildLandTypeDropdown(), // Using the dropdown instead of text field
      _buildFormField('Land Size', _landController.landSizeController,
          inputType: TextInputType.number, prefixIcon: Icons.straighten),


      const SizedBox(height: 16),

      // // Image preview
      // if (_landController.landImageController.text.isNotEmpty)
      //   Container(
      //     width: double.infinity,
      //     height: 200,
      //     decoration: BoxDecoration(
      //       border: Border.all(color: Colors.grey.shade300),
      //       borderRadius: BorderRadius.circular(12),
      //     ),
      //     child: ClipRRect(
      //       borderRadius: BorderRadius.circular(12),
      //       child: Image.network(
      //         _landController.landImageController.text,
      //         fit: BoxFit.cover,
      //         errorBuilder: (context, error, stackTrace) => Center(
      //           child: Column(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //               Icon(Icons.broken_image, size: 48, color: Colors.grey.shade400),
      //               const SizedBox(height: 8),
      //               const Text('Image not available'),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
    ];
  }

  List<Widget> _buildLocationFields() {
    return [
      _buildFormField('Land Address', _landController.landAddressController,
          prefixIcon: Icons.location_on, maxLines: 3),
      _buildFormField('City', _landController.landCityController,
          prefixIcon: Icons.location_city),

    ];
  }

  List<Widget> _buildFinancialFields() {
    return [
      Row(
        children: [
          Expanded(
            child: _buildFormField('Purchase Date', _landController.purchaseDateController,
                isDate: true, prefixIcon: Icons.date_range),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildFormField('Purchase Price', _landController.purchasePriceController,
                inputType: TextInputType.number, prefixIcon: Icons.attach_money),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: _buildFormField('Lease Date', _landController.leaseDateController,
                isDate: true, prefixIcon: Icons.date_range),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildFormField('Lease Value', _landController.leaseValueController,
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
      const Tab(icon: Icon(Icons.info), text: 'Basic Info'),
      const Tab(icon: Icon(Icons.location_on), text: 'Location'),
      const Tab(icon: Icon(Icons.attach_money), text: 'Financial'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Land Details'),
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
      body: Obx(() => _landController.isLoading.value || _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _landController.landFormKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Basic Info Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildFormSection('Basic Information', _buildBasicInfoFields()),
            ),

            // Location Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildFormSection('Location Details', _buildLocationFields()),
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
          onPressed: _landController.isLoading.value || _isLoading
              ? null
              : () async {
            if (_landController.landFormKey.currentState?.validate() ?? false) {
              await _landController.updateLand(widget.asset);
            } else {
              Get.snackbar(
                "Validation Error",
                "Please fill all required fields.",
                backgroundColor: Colors.red[100],
                colorText: Colors.red[800],
                snackPosition: SnackPosition.BOTTOM ,
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
          child: _landController.isLoading.value || _isLoading
              ? const CircularProgressIndicator()
              : const Text(
            'Update Land',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        )),
      ),
    );
  }
}
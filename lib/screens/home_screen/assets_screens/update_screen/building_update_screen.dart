import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/models/assets/building/building_model.dart';
import 'package:intl/intl.dart';

import '../../../../controllers/Building_Controller/building_controller.dart'; // Import the controller

class BuildingUpdatePage extends StatefulWidget {
  // final Building? building;
  final Map<String, dynamic>? buildingData;
  final dynamic asset;

  const BuildingUpdatePage(
      {super.key, required Map<String, dynamic> building, this.buildingData, this.asset});

  @override
  State<BuildingUpdatePage> createState() => _BuildingUpdatePageState();
}

class _BuildingUpdatePageState extends State<BuildingUpdatePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late BuildingController _buildingController;
  bool isLoading = true;

  // Define building type options
  final List<String> _buildingTypeOptions = [
    'RESIDENTIAL',
    'COMMERCIAL',
    'INDUSTRIAL',
    'AGRICULTURAL'
  ];

  String _selectedBuildingType = 'RESIDENTIAL';

  @override
  void initState() {
    super.initState();

    // Initialize the controller
    _buildingController = Get.put(BuildingController());

    _tabController = TabController(length: 4, vsync: this);
    _loadBuildingData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBuildingData() async {
    // Try to get building data from constructor parameters
    Map<String, dynamic>? buildingData;

    // First check if we have building data directly
    if (widget.buildingData != null) {
      buildingData = widget.buildingData;
    }
    // Then check if we have a building object
    /*else if (widget.building != null) {
      buildingData = _buildingFromModel(widget.building!);
    }*/
    // Finally check arguments
    else if (Get.arguments != null && Get.arguments is Map) {
      if (Get.arguments['buildingData'] != null) {
        buildingData = Get.arguments['buildingData'] as Map<String, dynamic>;
      } else if (Get.arguments['building'] != null) {
        buildingData =
            _buildingFromModel(Get.arguments['building'] as Building);
      }
    }

    // If we have building data, populate the form
    if (buildingData != null) {
      _buildingController.populateFormForEditing(buildingData);

      // Set selected building type if it exists in the data
      final existingType = buildingData['buildingType']?.toString() ?? '';
      if (existingType.isNotEmpty && _buildingTypeOptions.contains(existingType.toUpperCase())) {
        _selectedBuildingType = existingType.toUpperCase();
      }
      _buildingController.buildingTypeController.text = _selectedBuildingType;

      setState(() {
        isLoading = false;
      });
    } else {
      // Show error and navigate back if no data found
      Get.snackbar(
        'Error',
        'No building data found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );

      // Wait a moment for the snackbar to show before navigating back
      await Future.delayed(const Duration(seconds: 2));
      Get.back();
    }
  }

  // Convert Building model to Map for controller
  Map<String, dynamic> _buildingFromModel(Building building) {
    return {
      'name': building.name,
      'buildingType': building.buildingType,
      'numberOfFloors': building.numberOfFloors?.toString(),
      'totalArea': building.totalArea?.toString(),
      'address': building.address,
      'city': building.city,

      'ownerName': building.ownerName,
      'purposeOfUse': building.purposeOfUse,

      'councilTaxDate': building.councilTaxDate,
      'councilTaxValue': building.councilTax?.toString(),
      'lease_date': building.leaseDate,
      // Note: the controller expects 'lease_date' not 'leaseDate'
      'leaseValue': building.leaseValue?.toString(),
      'purchaseDate': building.purchaseDate,
      'purchasePrice': building.purchasePrice?.toString(),

    };
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
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

  Widget _buildFormField(
      String label,
      TextEditingController controller, {
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
            borderSide:
            BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: isDate
              ? IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context, controller),
          )
              : null,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          return null;
        },
        onTap: isDate ? () => _selectDate(context, controller) : null,
      ),
    );
  }

  Widget _buildBuildingTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedBuildingType,
        decoration: InputDecoration(
          labelText: 'Building Type',
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
        items: _buildingTypeOptions.map((String type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedBuildingType = newValue;
              _buildingController.buildingTypeController.text = newValue;
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Building Type is required';
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
      _buildFormField(
          'Building Name', _buildingController.buildingNameController,
          prefixIcon: Icons.business),
      _buildBuildingTypeDropdown(), // Using dropdown instead of text field
      _buildFormField(
          'Number of Floors', _buildingController.numberOfFloorsController,
          inputType: TextInputType.number, prefixIcon: Icons.layers),
      _buildFormField(
          'Total Area (sq ft)', _buildingController.totalAreaController,
          inputType: TextInputType.number, prefixIcon: Icons.square_foot),
      _buildFormField(
          'Purpose of Use', _buildingController.purposeOfUseController,
          prefixIcon: Icons.info_outline),
    ];
  }

  List<Widget> _buildLocationFields() {
    return [
      _buildFormField('Address', _buildingController.buildingAddressController,
          maxLines: 2, prefixIcon: Icons.location_on),
      Row(
        children: [
          Expanded(
            child: _buildFormField(
                'City', _buildingController.buildingCityController,
                prefixIcon: Icons.location_city),
          ),
          const SizedBox(width: 16),
          // Expanded(
          //   child: _buildFormField(
          //       'Province', _buildingController.buildingProvinceController,
          //       prefixIcon: Icons.map),
          // ),
        ],
      ),
    ];
  }

  List<Widget> _buildFinancialFields() {
    return [
      _buildFormField('Owner Name', _buildingController.ownerNameController,
          prefixIcon: Icons.person),
      Row(
        children: [
          Expanded(
            child: _buildFormField(
                'Purchase Date', _buildingController.purchaseDateController,
                isDate: true, prefixIcon: Icons.date_range),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildFormField(
                'Purchase Price', _buildingController.purchasePriceController,
                inputType: TextInputType.number,
                prefixIcon: Icons.attach_money),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: _buildFormField(
                'Lease Date', _buildingController.leaseDateController,
                isDate: true, prefixIcon: Icons.date_range),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildFormField(
                'Lease Value', _buildingController.leaseValueController,
                inputType: TextInputType.number,
                prefixIcon: Icons.attach_money),
          ),
        ],
      ),

      Row(
        children: [
          Expanded(
            child: _buildFormField('Council Tax Date',
                _buildingController.councilTaxDateController,
                isDate: true, prefixIcon: Icons.date_range),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildFormField('Council Tax Value',
                _buildingController.councilTaxValueController,
                inputType: TextInputType.number,
                prefixIcon: Icons.attach_money),
          ),
        ],
      ),
    ];
  }

  // List<Widget> _buildMediaFields() {
  //   return [
  //     _buildFormField(
  //         'Building Image URL', _buildingController.buildingImageController,
  //         prefixIcon: Icons.image),
  //     const SizedBox(height: 16),
  //
  //     // Image preview
  //     Obx(() {
  //       final imageUrl = _buildingController.buildingImageController.text;
  //       if (imageUrl.isNotEmpty) {
  //         return Container(
  //           width: double.infinity,
  //           height: 200,
  //           decoration: BoxDecoration(
  //             border: Border.all(color: Colors.grey.shade300),
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           child: ClipRRect(
  //             borderRadius: BorderRadius.circular(12),
  //             child: Image.network(
  //               imageUrl,
  //               fit: BoxFit.cover,
  //               errorBuilder: (context, error, stackTrace) => Center(
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Icon(Icons.broken_image,
  //                         size: 48, color: Colors.grey.shade400),
  //                     const SizedBox(height: 8),
  //                     const Text('Image not available'),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         );
  //       } else {
  //         return const SizedBox.shrink();
  //       }
  //     }),
  //   ];
  // }

  @override
  Widget build(BuildContext context) {
    // Define tabs
    final tabs = [
      const Tab(icon: Icon(Icons.business), text: 'Basic Info'),
      const Tab(icon: Icon(Icons.location_on), text: 'Location'),
      const Tab(icon: Icon(Icons.attach_money), text: 'Financial'),
      // const Tab(icon: Icon(Icons.image), text: 'Media'),
    ];

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading Building...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Building'),
        actions: [
          Obx(
                () => _buildingController.isLoading.value
                ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ))
                : IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                if (_buildingController.buildingFormKey.currentState?.validate() ?? false) {
                  // Update the building type before saving
                  _buildingController.buildingTypeController.text = _selectedBuildingType;
                  _buildingController.updateBuilding();
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
              tooltip: 'Save Changes',
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _buildingController.buildingFormKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Basic Info Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildFormSection(
                  'Basic Information', _buildBasicInfoFields()),
            ),

            // Location Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child:
              _buildFormSection('Location Details', _buildLocationFields()),
            ),

            // Financial Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildFormSection(
                  'Financial Information', _buildFinancialFields()),
            ),

            // // Media Tab
            // SingleChildScrollView(
            //   padding: const EdgeInsets.all(16),
            //   child: _buildFormSection('Building Media', _buildMediaFields()),
            // ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() => Container(
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
        child: ElevatedButton(
          onPressed: _buildingController.isLoading.value || isLoading
              ? null
              : () async {
            if (_buildingController.buildingFormKey.currentState?.validate() ?? false) {
              // Ensure the building type is set before updating
              _buildingController.buildingTypeController.text = _selectedBuildingType;
              await _buildingController.updateBuilding();
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
          child: _buildingController.isLoading.value
              ? const CircularProgressIndicator()
              : const Text(
            'Update Building',
            style:
            TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      )),
    );
  }
}
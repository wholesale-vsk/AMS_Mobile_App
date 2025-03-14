import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BuildingUpdatePage extends StatefulWidget {
  final Map<String, dynamic>? buildingData;

  BuildingUpdatePage({super.key, required this.buildingData});

  @override
  _BuildingUpdatePageState createState() => _BuildingUpdatePageState();
}

class _BuildingUpdatePageState extends State<BuildingUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();

    _controllers = {
      'buildingId': TextEditingController(text: widget.buildingData?['buildingId'] ?? ''),
      'buildingName': TextEditingController(text: widget.buildingData?['buildingName'] ?? ''),
      'buildingType': TextEditingController(text: widget.buildingData?['buildingType'] ?? ''),
      'numberOfFloors': TextEditingController(text: widget.buildingData?['numberOfFloors']?.toString() ?? ''),
      'totalArea': TextEditingController(text: widget.buildingData?['totalArea']?.toString() ?? ''),
      'buildingAddress': TextEditingController(text: widget.buildingData?['buildingAddress'] ?? ''),
      'buildingCity': TextEditingController(text: widget.buildingData?['buildingCity'] ?? ''),
      'buildingProvince': TextEditingController(text: widget.buildingData?['buildingProvince'] ?? ''),
      'ownerName': TextEditingController(text: widget.buildingData?['ownerName'] ?? ''),
      'purposeOfUse': TextEditingController(text: widget.buildingData?['purposeOfUse'] ?? ''),
      'councilTax': TextEditingController(text: widget.buildingData?['councilTax'] ?? ''),
      'councilTaxDate': TextEditingController(text: widget.buildingData?['councilTaxDate'] ?? ''),
      'councilTaxValue': TextEditingController(text: widget.buildingData?['councilTaxValue']?.toString() ?? ''),
      'leaseDate': TextEditingController(text: widget.buildingData?['leaseDate'] ?? ''),
      'leaseValue': TextEditingController(text: widget.buildingData?['leaseValue']?.toString() ?? ''),
      'purchaseDate': TextEditingController(text: widget.buildingData?['purchaseDate'] ?? ''),
      'purchasePrice': TextEditingController(text: widget.buildingData?['purchasePrice']?.toString() ?? ''),
      'buildingImage': TextEditingController(text: widget.buildingData?['buildingImage'] ?? ''),
    };
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_controllers[field]?.text ?? '') ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _controllers[field]?.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedData = _controllers.map((key, controller) => MapEntry(key, controller.text));
      Get.back(result: updatedData);
      Get.snackbar('Success', 'Building details updated successfully!', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Widget _buildFormField(String label, String key, {TextInputType inputType = TextInputType.text, bool isDate = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: _controllers[key],
        keyboardType: inputType,
        readOnly: isDate,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: isDate ? const Icon(Icons.calendar_today) : null,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          if (isDate && DateTime.tryParse(value) == null) {
            return 'Enter a valid date (yyyy-MM-dd)';
          }
          return null;
        },
        onTap: isDate ? () => _selectDate(context, key) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Building Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildFormField('Building ID', 'buildingId'),
              _buildFormField('Building Name', 'buildingName'),
              _buildFormField('Building Type', 'buildingType'),
              _buildFormField('Number of Floors', 'numberOfFloors', inputType: TextInputType.number),
              _buildFormField('Total Area (sq ft)', 'totalArea', inputType: TextInputType.number),
              _buildFormField('Building Address', 'buildingAddress'),
              _buildFormField('City', 'buildingCity'),
              _buildFormField('Province', 'buildingProvince'),
              _buildFormField('Owner Name', 'ownerName'),
              _buildFormField('Purpose of Use', 'purposeOfUse'),
              _buildFormField('Council Tax', 'councilTax'),
              _buildFormField('Council Tax Date', 'councilTaxDate', isDate: true),
              _buildFormField('Council Tax Value', 'councilTaxValue', inputType: TextInputType.number),
              _buildFormField('Lease Date', 'leaseDate', isDate: true),
              _buildFormField('Lease Value', 'leaseValue', inputType: TextInputType.number),
              _buildFormField('Purchase Date', 'purchaseDate', isDate: true),
              _buildFormField('Purchase Price', 'purchasePrice', inputType: TextInputType.number),
              _buildFormField('Building Image URL', 'buildingImage'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Update Building'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

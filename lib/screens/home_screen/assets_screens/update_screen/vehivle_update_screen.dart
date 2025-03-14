import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class VehicleUpdatePage extends StatefulWidget {
  final Map<String, dynamic> vehicleData;

  VehicleUpdatePage({super.key, required this.vehicleData});

  @override
  _VehicleUpdatePageState createState() => _VehicleUpdatePageState();
}

class _VehicleUpdatePageState extends State<VehicleUpdatePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _modelController;
  late TextEditingController _vrnController;
  late TextEditingController _motValueController;
  late TextEditingController _insuranceValueController;
  late TextEditingController _vehicleTypeController;
  late TextEditingController _ownerNameController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _purchaseDateController;
  late TextEditingController _motDateController;
  late TextEditingController _insuranceDateController;
  late TextEditingController _imageURLController;
  late TextEditingController _milageController;
  late TextEditingController _motExpiredDateController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    _modelController = TextEditingController(text: widget.vehicleData['model']);
    _vrnController = TextEditingController(text: widget.vehicleData['vrn']);
    _motValueController = TextEditingController(text: widget.vehicleData['motValue'].toString());
    _insuranceValueController = TextEditingController(text: widget.vehicleData['insuranceValue'].toString());
    _vehicleTypeController = TextEditingController(text: widget.vehicleData['vehicle_type']);
    _ownerNameController = TextEditingController(text: widget.vehicleData['owner_name']);
    _purchasePriceController = TextEditingController(text: widget.vehicleData['purchasePrice'].toString());
    _purchaseDateController = TextEditingController(text: widget.vehicleData['purchaseDate']);
    _motDateController = TextEditingController(text: widget.vehicleData['motDate']);
    _insuranceDateController = TextEditingController(text: widget.vehicleData['insuranceDate']);
    _milageController = TextEditingController(text: widget.vehicleData['milage'].toString());
    _motExpiredDateController = TextEditingController(text: widget.vehicleData['motExpiredDate']);
    _isActive = widget.vehicleData['isActive'] ?? true;
  }

  @override
  void dispose() {
    _modelController.dispose();
    _vrnController.dispose();
    _motValueController.dispose();
    _insuranceValueController.dispose();
    _vehicleTypeController.dispose();
    _ownerNameController.dispose();
    _purchasePriceController.dispose();
    _purchaseDateController.dispose();
    _motDateController.dispose();
    _insuranceDateController.dispose();
    _milageController.dispose();
    _motExpiredDateController.dispose();
    super.dispose();
  }

  /// Date Picker Handler
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  /// Submit Handler
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'model': _modelController.text,
        'vrn': _vrnController.text,
        'motValue': double.tryParse(_motValueController.text) ?? 0,
        'insuranceValue': double.tryParse(_insuranceValueController.text) ?? 0,
        'vehicle_type': _vehicleTypeController.text,
        'owner_name': _ownerNameController.text,
        'isActive': _isActive,
        'purchasePrice': double.tryParse(_purchasePriceController.text) ?? 0,
        'purchaseDate': _purchaseDateController.text,
        'motDate': _motDateController.text,
        'insuranceDate': _insuranceDateController.text,
        'milage': double.tryParse(_milageController.text) ?? 0,
        'motExpiredDate': _motExpiredDateController.text,
        'type': 'Vehicle',
      };

      print("Updated Vehicle Data: $updatedData");
      Get.back(result: updatedData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Vehicle Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('Model', _modelController),
              _buildTextField('Vehicle Registration Number (VRN)', _vrnController),
              _buildTextField('MOT Value', _motValueController, inputType: TextInputType.number),
              _buildTextField('Insurance Value', _insuranceValueController, inputType: TextInputType.number),
              _buildTextField('Vehicle Type', _vehicleTypeController),
              _buildTextField('Owner Name', _ownerNameController),
              _buildSwitchField('Active Status', _isActive),
              _buildTextField('Purchase Price', _purchasePriceController, inputType: TextInputType.number),
              _buildDateField('Purchase Date', _purchaseDateController),
              _buildDateField('MOT Date', _motDateController),
              _buildDateField('Insurance Date', _insuranceDateController),
              _buildTextField('Milage', _milageController, inputType: TextInputType.number),
              _buildDateField('MOT Expired Date', _motExpiredDateController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Update Vehicle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () => _selectDate(context, controller),
      ),
    );
  }

  Widget _buildSwitchField(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Switch(
            value: value,
            onChanged: (val) {
              setState(() {
                _isActive = val;
              });
            },
          ),
        ],
      ),
    );
  }
}
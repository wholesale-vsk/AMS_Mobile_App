import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class VehicleUpdatePage extends StatefulWidget {
  final Map<String, dynamic>? vehicleData;

  const VehicleUpdatePage({super.key, this.vehicleData, required asset, required Map<String, dynamic> land, required vehicle});

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
  late TextEditingController _vehicleColorController;
  late TextEditingController _engineNumberController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _purchaseDateController;
  late TextEditingController _motDateController;
  late TextEditingController _insuranceDateController;
  late TextEditingController _milageController;
  late TextEditingController _motExpiredDateController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final data = widget.vehicleData ?? {};

    _modelController = TextEditingController(text: data['model'] ?? '');
    _vrnController = TextEditingController(text: data['vrn'] ?? '');
    _motValueController = TextEditingController(text: data['motValue']?.toString() ?? '');
    _insuranceValueController = TextEditingController(text: data['insuranceValue']?.toString() ?? '');
    _vehicleTypeController = TextEditingController(text: data['vehicle_type'] ?? '');
    _ownerNameController = TextEditingController(text: data['owner_name'] ?? '');
    _vehicleColorController = TextEditingController(text: data['vehicle_color'] ?? '');
    _engineNumberController = TextEditingController(text: data['engine_number'] ?? '');
    _purchasePriceController = TextEditingController(text: data['purchasePrice']?.toString() ?? '');
    _purchaseDateController = TextEditingController(text: data['purchaseDate'] ?? '');
    _motDateController = TextEditingController(text: data['motDate'] ?? '');
    _insuranceDateController = TextEditingController(text: data['insuranceDate'] ?? '');
    _milageController = TextEditingController(text: data['milage']?.toString() ?? '');
    _motExpiredDateController = TextEditingController(text: data['motExpiredDate'] ?? '');
    _isActive = data['isActive'] ?? true;
  }

  String? _validateField(String? value, String label) {
    return (value == null || value.isEmpty) ? '$label is required' : null;
  }

  double _parseDouble(String value) => double.tryParse(value) ?? 0;

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'model': _modelController.text,
        'vrn': _vrnController.text,
        'motValue': _parseDouble(_motValueController.text),
        'insuranceValue': _parseDouble(_insuranceValueController.text),
        'vehicle_type': _vehicleTypeController.text,
        'owner_name': _ownerNameController.text,
        'vehicle_color': _vehicleColorController.text,
        'engine_number': _engineNumberController.text,
        'isActive': _isActive,
        'purchasePrice': _parseDouble(_purchasePriceController.text),
        'purchaseDate': _purchaseDateController.text,
        'motDate': _motDateController.text,
        'insuranceDate': _insuranceDateController.text,
        'milage': _parseDouble(_milageController.text),
        'motExpiredDate': _motExpiredDateController.text,
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
              _buildInputField('Model', _modelController),
              _buildInputField('VRN', _vrnController),
              _buildInputField('MOT Value', _motValueController, inputType: TextInputType.number),
              _buildInputField('Insurance Value', _insuranceValueController, inputType: TextInputType.number),
              _buildInputField('Vehicle Type', _vehicleTypeController),
              _buildInputField('Owner Name', _ownerNameController),
              _buildInputField('Vehicle Color', _vehicleColorController),
              _buildInputField('Engine Number', _engineNumberController),
              _buildSwitchField('Active Status'),
              _buildInputField('Purchase Price', _purchasePriceController, inputType: TextInputType.number),
              _buildInputField('Purchase Date', _purchaseDateController, isDate: true),
              _buildInputField('MOT Date', _motDateController, isDate: true),
              _buildInputField('Insurance Date', _insuranceDateController, isDate: true),
              _buildInputField('Milage', _milageController, inputType: TextInputType.number),
              _buildInputField('MOT Expired Date', _motExpiredDateController, isDate: true),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submitForm, child: const Text('Update Vehicle')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text, bool isDate = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        readOnly: isDate,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: isDate ? const Icon(Icons.calendar_today) : null,
        ),
        validator: (value) => _validateField(value, label),
        onTap: isDate ? () => _selectDate(context, controller) : null,
      ),
    );
  }

  Widget _buildSwitchField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Switch(
            value: _isActive,
            onChanged: (val) => setState(() => _isActive = val),
          ),
        ],
      ),
    );
  }
}

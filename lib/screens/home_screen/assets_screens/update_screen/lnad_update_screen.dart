import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LandUpdatePage extends StatefulWidget {
  final Map<String, dynamic>? landData;

  LandUpdatePage({super.key, required this.landData});

  @override
  _LandUpdatePageState createState() => _LandUpdatePageState();
}

class _LandUpdatePageState extends State<LandUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();

    _controllers = {
      'landId': TextEditingController(text: widget.landData?['landId'] ?? ''),
      'landName': TextEditingController(text: widget.landData?['landName'] ?? ''),
      'landType': TextEditingController(text: widget.landData?['landType'] ?? ''),
      'landSize': TextEditingController(text: widget.landData?['landSize']?.toString() ?? ''),
      'landAddress': TextEditingController(text: widget.landData?['landAddress'] ?? ''),
      'landCity': TextEditingController(text: widget.landData?['landCity'] ?? ''),
      'landProvince': TextEditingController(text: widget.landData?['landProvince'] ?? ''),
      'purchaseDate': TextEditingController(text: widget.landData?['purchaseDate'] ?? ''),
      'purchasePrice': TextEditingController(text: widget.landData?['purchasePrice']?.toString() ?? ''),
      'landImage': TextEditingController(text: widget.landData?['landImage'] ?? ''),
      'leaseDate': TextEditingController(text: widget.landData?['leaseDate'] ?? ''),
      'leaseValue': TextEditingController(text: widget.landData?['leaseValue']?.toString() ?? ''),
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
      Get.snackbar('Success', 'Land details updated successfully!', snackPosition: SnackPosition.BOTTOM);
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
      appBar: AppBar(title: const Text('Update Land Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildFormField('Land ID', 'landId'),
              _buildFormField('Land Name', 'landName'),
              _buildFormField('Land Type', 'landType'),
              _buildFormField('Land Size', 'landSize', inputType: TextInputType.number),
              _buildFormField('Land Address', 'landAddress'),
              _buildFormField('City', 'landCity'),
              _buildFormField('Province', 'landProvince'),
              _buildFormField('Purchase Date', 'purchaseDate', isDate: true),
              _buildFormField('Purchase Price', 'purchasePrice', inputType: TextInputType.number),
              _buildFormField('Land Image URL', 'landImage'),
              _buildFormField('Lease Date', 'leaseDate', isDate: true),
              _buildFormField('Lease Value', 'leaseValue', inputType: TextInputType.number),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Update Land'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
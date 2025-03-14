import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LandUpdatePage extends StatefulWidget {
  final Map<String, dynamic> landData;

  LandUpdatePage({super.key, required this.landData});

  @override
  _LandUpdatePageState createState() => _LandUpdatePageState();
}

class _LandUpdatePageState extends State<LandUpdatePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _landNameController;
  late TextEditingController _landTypeController;
  late TextEditingController _landSizeController;
  late TextEditingController _landAddressController;
  late TextEditingController _landCityController;
  late TextEditingController _landProvinceController;
  late TextEditingController _purchaseDateController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _landImageController;

  @override
  void initState() {
    super.initState();

    _landNameController = TextEditingController(text: widget.landData['landName']);
    _landTypeController = TextEditingController(text: widget.landData['landType']);
    _landSizeController = TextEditingController(text: widget.landData['landSize'].toString());
    _landAddressController = TextEditingController(text: widget.landData['landAddress']);
    _landCityController = TextEditingController(text: widget.landData['landCity']);
    _landProvinceController = TextEditingController(text: widget.landData['landProvince']);
    _purchaseDateController = TextEditingController(text: widget.landData['purchaseDate']);
    _purchasePriceController = TextEditingController(text: widget.landData['purchasePrice'].toString());
    _landImageController = TextEditingController(text: widget.landData['landImage']);
  }

  @override
  void dispose() {
    _landNameController.dispose();
    _landTypeController.dispose();
    _landSizeController.dispose();
    _landAddressController.dispose();
    _landCityController.dispose();
    _landProvinceController.dispose();
    _purchaseDateController.dispose();
    _purchasePriceController.dispose();
    _landImageController.dispose();
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
        'landName': _landNameController.text,
        'landType': _landTypeController.text,
        'landSize': double.tryParse(_landSizeController.text) ?? 0,
        'landAddress': _landAddressController.text,
        'landCity': _landCityController.text,
        'landProvince': _landProvinceController.text,
        'purchaseDate': _purchaseDateController.text,
        'purchasePrice': double.tryParse(_purchasePriceController.text) ?? 0,
        'landImage': _landImageController.text,
      };

      print("Updated Land Data: $updatedData");
      Get.back(result: updatedData);
    }
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
              _buildTextField('Land Name', _landNameController),
              _buildTextField('Land Type', _landTypeController),
              _buildTextField('Land Size (in Acres)', _landSizeController, inputType: TextInputType.number),
              _buildTextField('Land Address', _landAddressController),
              _buildTextField('Land City', _landCityController),
              _buildTextField('Land Province', _landProvinceController),
              _buildDateField('Purchase Date', _purchaseDateController),
              _buildTextField('Purchase Price (LKR)', _purchasePriceController, inputType: TextInputType.number),
              _buildTextField('Land Image URL', _landImageController),
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

  /// Generic Text Field
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

  /// Date Field
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
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LandUpdatePage extends StatefulWidget {
  final Map<String, dynamic>? landData;
  final dynamic asset;
  final Map<String, dynamic> vehicle;
  final dynamic land;

  const LandUpdatePage({
    super.key,
    this.landData,
    required this.asset,
    required this.vehicle,
    required this.land
  });

  @override
  _LandUpdatePageState createState() => _LandUpdatePageState();
}

class _LandUpdatePageState extends State<LandUpdatePage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  Map<String, TextEditingController> _controllers = {};
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Use either landData or land parameter, with landData taking precedence
    final data = widget.landData ?? widget.land;

    _controllers = {
      'landId': TextEditingController(text: data?['landId'] ?? data?['id'] ?? ''),
      'landName': TextEditingController(text: data?['landName'] ?? data?['name'] ?? ''),
      'landType': TextEditingController(text: data?['landType'] ?? data?['type'] ?? ''),
      'landSize': TextEditingController(text: data?['landSize']?.toString() ?? ''),
      'landAddress': TextEditingController(text: data?['landAddress'] ?? data?['address'] ?? ''),
      'landCity': TextEditingController(text: data?['landCity'] ?? data?['city'] ?? ''),
      'landProvince': TextEditingController(text: data?['landProvince'] ?? data?['province'] ?? ''),
      'purchaseDate': TextEditingController(text: data?['purchaseDate'] ?? ''),
      'purchasePrice': TextEditingController(text: data?['purchasePrice']?.toString() ?? ''),
      'landImage': TextEditingController(text: data?['landImage'] ?? data?['imageURL'] ?? ''),
      'leaseDate': TextEditingController(text: data?['leaseDate'] ?? data?['lease_date'] ?? ''),
      'leaseValue': TextEditingController(text: data?['leaseValue']?.toString() ?? ''),
      'taxAmount': TextEditingController(text: data?['taxAmount']?.toString() ?? ''),
      'landDescription': TextEditingController(text: data?['landDescription'] ?? data?['description'] ?? ''),
    };
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    _tabController.dispose();
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
      setState(() {
        _controllers[field]?.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create updated data map with compatibility for different key formats
        final updatedData = {
          // Primary keys
          'landId': _controllers['landId']!.text,
          'id': _controllers['landId']!.text,
          'landName': _controllers['landName']!.text,
          'name': _controllers['landName']!.text,
          'landType': _controllers['landType']!.text,
          'type': _controllers['landType']!.text,
          'landSize': _controllers['landSize']!.text,
          'landAddress': _controllers['landAddress']!.text,
          'address': _controllers['landAddress']!.text,
          'landCity': _controllers['landCity']!.text,
          'city': _controllers['landCity']!.text,
          'landProvince': _controllers['landProvince']!.text,
          'province': _controllers['landProvince']!.text,
          'purchaseDate': _controllers['purchaseDate']!.text,
          'purchasePrice': _controllers['purchasePrice']!.text,
          'landImage': _controllers['landImage']!.text,
          'imageURL': _controllers['landImage']!.text,
          'leaseDate': _controllers['leaseDate']!.text,
          'lease_date': _controllers['leaseDate']!.text,
          'leaseValue': _controllers['leaseValue']!.text,
          'taxAmount': _controllers['taxAmount']!.text,
          'landDescription': _controllers['landDescription']!.text,
          'description': _controllers['landDescription']!.text,
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

  Widget _buildFormField(String label, String key, {
    TextInputType inputType = TextInputType.text,
    bool isDate = false,
    bool isRequired = true,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _controllers[key],
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
            onPressed: () => _selectDate(context, key),
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
        onTap: isDate ? () => _selectDate(context, key) : null,
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

      _buildFormField('Land Name', 'landName', prefixIcon: Icons.title),
      _buildFormField('Land Type', 'landType', prefixIcon: Icons.category),
      _buildFormField('Land Size', 'landSize', inputType: TextInputType.number, prefixIcon: Icons.straighten),

      const SizedBox(height: 16),

      // Image preview
      if (_controllers['landImage']!.text.isNotEmpty)
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _controllers['landImage']!.text,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    const Text('Image not available'),
                  ],
                ),
              ),
            ),
          ),
        ),
    ];
  }

  List<Widget> _buildLocationFields() {
    return [
      _buildFormField('Land Address', 'landAddress', prefixIcon: Icons.location_on, maxLines: 3),
      _buildFormField('City', 'landCity', prefixIcon: Icons.location_city),
      _buildFormField('Province', 'landProvince', prefixIcon: Icons.map),
      _buildFormField('Description', 'landDescription', prefixIcon: Icons.description, maxLines: 4, isRequired: false),
    ];
  }

  List<Widget> _buildFinancialFields() {
    return [
      Row(
        children: [
          Expanded(
            child: _buildFormField('Purchase Date', 'purchaseDate', isDate: true, prefixIcon: Icons.date_range),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildFormField('Purchase Price', 'purchasePrice', inputType: TextInputType.number, prefixIcon: Icons.attach_money),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: _buildFormField('Lease Date', 'leaseDate', isDate: true, prefixIcon: Icons.date_range),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildFormField('Lease Value', 'leaseValue', inputType: TextInputType.number, prefixIcon: Icons.attach_money),
          ),
        ],
      ),
      _buildFormField('Tax Amount', 'taxAmount', inputType: TextInputType.number, prefixIcon: Icons.receipt, isRequired: false),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
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
      ),
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
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text(
            'Update Land',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
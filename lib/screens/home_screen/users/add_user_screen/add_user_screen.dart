import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/utils/theme/font_size.dart';
import 'package:hexalyte_ams/utils/theme/responsive_size.dart';
import 'package:hexalyte_ams/utils/theme/app_theme_management.dart';
import 'package:hexalyte_ams/utils/widgets/buttons/filled_button.dart';
import '../../../../utils/widgets/app_bar/appbar_component.dart';

class AddUserFormScreen extends StatefulWidget {
  @override
  _AddUserFormScreenState createState() => _AddUserFormScreenState();
}

class _AddUserFormScreenState extends State<AddUserFormScreen> {
  final AppThemeManager themeManager = Get.find();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedRole;
  bool _obscurePassword = true;

  void _createUser() {
    if (_formKey.currentState!.validate()) {
      // Perform user creation logic
      print("User Created: ${_firstNameController.text}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeManager.backgroundColor,
      appBar: AppBarComponent(
        appBarTitle: 'Add User',
        screenWidth: ResponsiveSize.width,
        screenHeight: ResponsiveSize.height,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveSize.getWidth(size: 16),
          vertical: ResponsiveSize.getHeight(size: 10),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildTextField('First Name', _firstNameController, Icons.person),
                          _buildTextField('Last Name', _lastNameController, Icons.person_outline),
                          _buildTextField('Email Address', _emailController, Icons.email, inputType: TextInputType.emailAddress),
                          _buildTextField('Phone Number', _phoneController, Icons.phone, inputType: TextInputType.phone),
                          _buildDropdownField('User Role', ['Super Admin', 'Admin', 'Manager']),
                          _buildTextField('Username', _usernameController, Icons.account_circle),
                          _buildPasswordField('Password', _passwordController),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              AppFilledButton(
                text: 'Create User',
                onPressed: _createUser,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? inputType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        cursorColor: themeManager.primaryColor,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: themeManager.primaryColor),
          labelText: label,
          labelStyle: TextStyle(fontSize: FontSizes.small, color: themeManager.primaryColor),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: themeManager.primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        validator: (value) => value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        obscureText: _obscurePassword,
        cursorColor: themeManager.primaryColor,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock, color: themeManager.primaryColor),
          labelText: label,
          labelStyle: TextStyle(fontSize: FontSizes.small, color: themeManager.primaryColor),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: themeManager.primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          filled: true,
          fillColor: Colors.grey[100],
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
            color: themeManager.primaryColor,
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        value: _selectedRole,
        elevation: 2,
        dropdownColor: themeManager.backgroundColor,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.admin_panel_settings, color: themeManager.primaryColor),
          labelText: label,
          labelStyle: TextStyle(fontSize: FontSizes.small, color: themeManager.primaryColor),
          contentPadding: EdgeInsets.all(16),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: themeManager.primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        items: options
            .map((option) => DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedRole = value;
          });
        },
        validator: (value) => value == null ? 'Please select a role' : null,
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

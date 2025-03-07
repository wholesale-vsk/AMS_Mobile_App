import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/theme/app_theme_management.dart';
import '../../../utils/theme/responsive_size.dart';
import '../home_screen.dart';

class AppSettings extends StatelessWidget {
  final AppThemeManager themeManager = Get.find<AppThemeManager>();

  AppSettings({Key? key}) : super(key: key);

  // List of themes for the dropdown
  final List<String> themeNames = ThemeType.values.map((theme) => theme.name.capitalizeFirst!).toList();
  RxString selectedTheme = ThemeType.values.first.name.capitalizeFirst!.obs;

  // Logout Function
  void logout() {
    Get.offNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // 🔹 White Header
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // 🔹 Back Button
          onPressed: () => Get.offAll(() => HomeScreen()),
        ),
        title: Text(
          "App Settings",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveSize.getHeight(size: 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Appearance'),
            _buildDropdownSetting(
              context,
              icon: Icons.palette,
              label: 'Theme',
              value: selectedTheme,
              items: themeNames,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  selectedTheme.value = newValue;
                  final selectedThemeType = ThemeType.values.firstWhere(
                          (theme) => theme.name.capitalizeFirst! == selectedTheme.value);
                  themeManager.setTheme(selectedThemeType);
                }
              },
            ),
            Divider(thickness: 1, color: Colors.grey.shade300),

            _buildSectionTitle('Notifications'),
            _buildSwitchSetting(
              context,
              icon: Icons.notifications,
              label: 'Enable Notifications',
              value: true.obs,
              onChanged: (bool? newValue) {},
            ),
            Divider(thickness: 1, color: Colors.grey.shade300),

            _buildSectionTitle('Privacy & Security'),
            _buildSwitchSetting(
              context,
              icon: Icons.location_on,
              label: 'Enable Location Services',
              value: true.obs,
              onChanged: (bool? newValue) {},
            ),
            _buildSwitchSetting(
              context,
              icon: Icons.data_usage,
              label: 'Share Data with Third Parties',
              value: false.obs,
              onChanged: (bool? newValue) {},
            ),
            _buildSwitchSetting(
              context,
              icon: Icons.visibility,
              label: 'Profile Visibility',
              value: true.obs,
              onChanged: (bool? newValue) {},
            ),

            SizedBox(height: ResponsiveSize.getHeight(size: 32)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveSize.getHeight(size: 16)),
          child: ElevatedButton(
            onPressed: logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveSize.getHeight(size: 16),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Logout',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  // Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveSize.getHeight(size: 12)),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: themeManager.textColor),
      ),
    );
  }

  // Dropdown Settings Card
  Widget _buildDropdownSetting(
      BuildContext context, {
        required IconData icon,
        required String label,
        required RxString value,
        required List<String> items,
        required ValueChanged<String?> onChanged,
      }) {
    return _buildCard(
      child: Row(
        children: [
          Icon(icon, color: themeManager.primaryColor, size: 30),
          SizedBox(width: 16),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: themeManager.textColor)),
          ),
          Obx(
                () {
              return DropdownButton<String>(
                value: value.value,
                icon: Icon(Icons.arrow_drop_down, color: themeManager.textColor),
                style: TextStyle(color: themeManager.textColor),
                onChanged: onChanged,
                items: items.map((String value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // Switch Settings Card
  Widget _buildSwitchSetting(
      BuildContext context, {
        required IconData icon,
        required String label,
        required RxBool value,
        required ValueChanged<bool?> onChanged,
      }) {
    return _buildCard(
      child: Row(
        children: [
          Icon(icon, color: themeManager.primaryColor, size: 30),
          SizedBox(width: 16),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: themeManager.textColor)),
          ),
          Obx(
                () {
              return Switch(
                value: value.value,
                onChanged: onChanged,
                activeColor: themeManager.primaryColor,
              );
            },
          ),
        ],
      ),
    );
  }

  // Common Card Layout
  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveSize.getHeight(size: 16)),
        child: child,
      ),
    );
  }
}

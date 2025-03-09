import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/theme/app_theme_management.dart';
import '../../../utils/theme/responsive_size.dart';
import '../home_screen.dart';

class AppSettings extends StatelessWidget {
  final AppThemeManager themeManager;
  final RxBool enableNotifications = true.obs;
  final RxBool enableLocationServices = true.obs;
  final RxBool shareDataWithThirdParties = false.obs;
  final RxBool profileVisibility = true.obs;

  AppSettings({Key? key})
      : themeManager = Get.find<AppThemeManager>(),
        super(key: key);

  // Logout Function
  void logout() {
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
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
            _buildSectionTitle('Notifications'),
            _buildSwitchSetting(
              icon: Icons.notifications,
              label: 'Enable Notifications',
              value: enableNotifications,
            ),
            Divider(thickness: 1, color: Colors.grey.shade300),

            _buildSectionTitle('Privacy & Security'),
            _buildSwitchSetting(
              icon: Icons.location_on,
              label: 'Enable Location Services',
              value: enableLocationServices,
            ),
            _buildSwitchSetting(
              icon: Icons.data_usage,
              label: 'Share Data with Third Parties',
              value: shareDataWithThirdParties,
            ),
            _buildSwitchSetting(
              icon: Icons.visibility,
              label: 'Profile Visibility',
              value: profileVisibility,
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
            child: const Text(
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

  // Switch Settings Card
  Widget _buildSwitchSetting({
    required IconData icon,
    required String label,
    required RxBool value,
  }) {
    return _buildCard(
      child: Row(
        children: [
          Icon(icon, color: themeManager.primaryColor, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: themeManager.textColor),
            ),
          ),
          Obx(() {
            return Switch(
              value: value.value,
              onChanged: (bool newValue) => value.value = newValue,
              activeColor: themeManager.primaryColor,
            );
          }),
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../services/auth/auth_service.dart';
import '../../../utils/theme/app_theme_management.dart';
import '../../../utils/theme/responsive_size.dart';
import '../home_screen.dart';

class AppSettings extends StatelessWidget {
  final AppThemeManager themeManager;
  final RxBool enableNotifications = true.obs;
  final RxBool enableLocationServices = true.obs;
  final RxBool shareDataWithThirdParties = false.obs;
  final RxBool profileVisibility = true.obs;
  final AuthService _authService = Get.find<AuthService>();

  AppSettings({Key? key})
      : themeManager = Get.find<AppThemeManager>(),
        super(key: key);

  // Location Services Toggle Handler
  Future<bool> _handleLocationServicesToggle(bool currentValue) async {
    if (!currentValue) {
      // When turning on location services
      var status = await Permission.location.request();

      if (status.isGranted) {
        // Permission granted
        Get.snackbar(
          'Location Services',
          'Location access granted',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        // Permission denied
        Get.snackbar(
          'Location Services',
          'Location permission denied',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } else {
      // When turning off location services
      Get.snackbar(
        'Location Services',
        'Location services disabled',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Logout Function
  void logout() {
    // Show confirmation dialog before logout
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Close the dialog
              Get.back();

              try {
                // Call the logout method from AuthService
                await _authService.logout();
              } catch (e) {
                // Handle any logout errors
                Get.snackbar(
                  'Logout Error',
                  'Failed to logout. Please try again.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Boolean for dark mode with fallback to false
    final isDarkMode = themeManager.isDarkMode ?? false;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDarkMode
                ? Colors.white
                : Colors.black,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode
                ? Colors.white
                : Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: isDarkMode
                  ? Colors.white70
                  : Colors.black54,
            ),
            onPressed: () {
              // Show help information
              Get.dialog(
                AlertDialog(
                  title: const Text('Help'),
                  content: const Text('This is the settings page where you can customize your app experience.'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveSize.getWidth(size: 16),
          vertical: ResponsiveSize.getHeight(size: 12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ResponsiveSize.getHeight(size: 20)),

            _buildSectionWithIcon(
              'Notifications',
              Icons.notifications_none_outlined,
            ),
            _buildSwitchSettingRounded(
              icon: Icons.notifications_active_outlined,
              label: 'Push Notifications',
              description: 'Receive alerts for new messages and updates',
              value: enableNotifications,
              isDarkMode: isDarkMode,
            ),

            SizedBox(height: ResponsiveSize.getHeight(size: 20)),
            _buildSectionWithIcon(
              'Privacy & Security',
              Icons.shield_outlined,
            ),
            _buildSwitchSettingRounded(
              icon: Icons.location_on_outlined,
              label: 'Location Services',
              description: 'Allow app to access your location',
              value: enableLocationServices,
              isDarkMode: isDarkMode,
              onToggle: _handleLocationServicesToggle,
            ),
            _buildSwitchSettingRounded(
              icon: Icons.share_outlined,
              label: 'Data Sharing',
              description: 'Share anonymous usage data to improve app',
              value: shareDataWithThirdParties,
              isDarkMode: isDarkMode,
            ),
            _buildSwitchSettingRounded(
              icon: Icons.visibility_outlined,
              label: 'Profile Visibility',
              description: 'Make your profile visible to other users',
              value: profileVisibility,
              isDarkMode: isDarkMode,
            ),

            _buildActionCard(
              icon: Icons.info_outline,
              label: 'About',
              onTap: () {
                // Show about dialog
                Get.dialog(
                  AlertDialog(
                    title: const Text('About'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/logo.png', height: 80),
                        const SizedBox(height: 16),
                        const Text('App Version 1.1.0'),
                        const SizedBox(height: 8),
                        const Text('© 2025 Hexalyte'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              isDarkMode: isDarkMode,
            ),

            SizedBox(height: ResponsiveSize.getHeight(size: 40)),
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
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveSize.getHeight(size: 16),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                    Icons.logout,
                    size: 20,
                    color: Colors.white // Ensures visibility on red background
                ),
                const SizedBox(width: 8),
                const Text(
                  'Logout',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white // Ensures visibility on red background
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Section Title with Icon
  Widget _buildSectionWithIcon(String title, IconData iconData) {
    return Padding(
      padding: EdgeInsets.only(
        left: ResponsiveSize.getWidth(size: 4),
        bottom: ResponsiveSize.getHeight(size: 12),
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            size: 20,
            color: themeManager.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeManager.textColor,
            ),
          ),
        ],
      ),
    );
  }

  // Rounded Switch Settings
  Widget _buildSwitchSettingRounded({
    required IconData icon,
    required String label,
    required String description,
    required RxBool value,
    required bool isDarkMode,
    Future<bool> Function(bool)? onToggle,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveSize.getHeight(size: 8)),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2A2A2A)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveSize.getWidth(size: 16),
          vertical: ResponsiveSize.getHeight(size: 16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: themeManager.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: themeManager.primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: themeManager.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode
                          ? Colors.white70
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Obx(() {
              return Switch.adaptive(
                value: value.value,
                onChanged: (bool newValue) async {
                  // Check if a custom toggle handler is provided
                  if (onToggle != null) {
                    bool result = await onToggle(value.value);
                    value.value = result;
                  } else {
                    // Default behavior
                    value.value = newValue;
                  }
                },
                activeColor: themeManager.primaryColor,
              );
            }),
          ],
        ),
      ),
    );
  }

  // Action Card
  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveSize.getHeight(size: 8)),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2A2A2A)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveSize.getWidth(size: 16),
            vertical: ResponsiveSize.getHeight(size: 16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: themeManager.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: themeManager.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: themeManager.textColor,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDarkMode
                    ? Colors.white54
                    : Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
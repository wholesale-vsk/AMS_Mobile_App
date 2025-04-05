import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationServicesController extends GetxController {
  final RxBool enableLocationServices = false.obs;

  Future<void> toggleLocationServices(bool newValue) async {
    if (newValue) {
      // Request location permission when turning on
      var status = await Permission.location.request();

      if (status.isGranted) {
        // Permission granted
        enableLocationServices.value = true;
        // You can add additional logic here, like initializing location services
        Get.snackbar(
          'Location Services',
          'Location access granted',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        // Permission denied
        enableLocationServices.value = false;
        Get.snackbar(
          'Location Services',
          'Location permission denied',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      // Turn off location services
      enableLocationServices.value = false;
      // Optional: Add logic to disable location tracking
    }
  }
}

class AppSettings extends StatelessWidget {
  final LocationServicesController locationController =
  Get.put(LocationServicesController());

  AppSettings({Key? key}) : super(key: key);

  Widget _buildSwitchSettingRounded({
    required IconData icon,
    required String label,
    required String description,
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.blue,
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
                      color: isDarkMode ? Colors.white : Colors.black,
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
                value: locationController.enableLocationServices.value,
                onChanged: locationController.toggleLocationServices,
                activeColor: Colors.blue,
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSwitchSettingRounded(
                icon: Icons.location_on_outlined,
                label: 'Location Services',
                description: 'Allow app to access your location',
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
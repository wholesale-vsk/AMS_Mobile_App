import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../services/auth/auth_service.dart';


class LogoutController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Observable state for logout process
  final RxBool isLoading = false.obs;

  // Logout method with comprehensive handling
  Future<void> logout({bool showConfirmation = true}) async {
    // Optional confirmation dialog
    if (showConfirmation) {
      final confirmed = await _showLogoutConfirmationDialog();
      if (!confirmed) return;
    }

    try {
      // Set loading state
      isLoading.value = true;

      // Perform logout
      await _authService.logout();

      // Clear all routes and navigate to login
      Get.offAllNamed(AppRoutes.LOGIN_SCREEN);

      // Show success notification
      _showLogoutNotification(
          title: 'Logout Successful',
          message: 'You have been logged out',
          isError: false
      );
    } catch (e) {
      // Handle logout errors
      _showLogoutNotification(
          title: 'Logout Error',
          message: 'Failed to logout. Please try again.',
          isError: true
      );
    } finally {
      // Reset loading state
      isLoading.value = false;
    }
  }

  // Configurable logout confirmation dialog
  Future<bool> _showLogoutConfirmationDialog() async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      barrierDismissible: false,
    ) ?? false;
  }

  // Centralized notification method
  void _showLogoutNotification({
    required String title,
    required String message,
    required bool isError
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
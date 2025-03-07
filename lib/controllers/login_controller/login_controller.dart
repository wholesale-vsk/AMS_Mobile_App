import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/controllers/network_controller/network_controller.dart';
import '../../routes/app_routes.dart';
import '../../services/auth/auth_service.dart';
import 'package:dio/dio.dart';

class LoginScreenController extends GetxController {
  var loginBtnState = true.obs;
  var isLoading = false.obs;
  var obscureText = true.obs;
  final AuthService authService = AuthService();
  final NetworkController networkController = Get.find<NetworkController>();

  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? email;
  String? password;

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  // Validate email
  String? verifyEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';

    return null;
  }

  // Validate password
  String? verifyPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 3) return 'Password must be at least 6 characters';
    return null;
  }

  // Handle login form submission
  Future<void> onSubmit() async {
    if (loginFormKey.currentState!.validate()) {
      email = emailController.text;
      password = passwordController.text;

      // Proceed with login
      await loginToDashboard();
    } else {
      Get.snackbar('Validation Error', 'Please fix the errors in the form');
    }
  }

  // Perform login action
  Future<void> loginToDashboard() async {
    loginBtnState.value = false;
    isLoading.value = true;

    try {
      if (networkController.connectionStatus.value != -1) {
        final response = await authService.loginAuth(
          username: email!,
          password: password!,
        );
        if (response.isSuccess) {
          Get.snackbar('Success', 'Logged in successfully!');
          // Directly navigate to Home Screen after successful login
          Get.offAllNamed(AppRoutes.HOME_SCREEN);
        } else {
          Get.snackbar('Error', response.message ?? 'Login failed. Please try again.');
        }
      } else {
        Get.snackbar('Error', 'No internet connection.');
      }
    } on DioError catch (e) {  // Catch DioError here
      if (e.response?.statusCode == 404) {
        Get.snackbar('Error', 'Incorrect credentials or invalid endpoint.');
      } else if (e.response?.statusCode == 500) {
        Get.snackbar('Error', 'Server error, please try again later.');
      } else {
        Get.snackbar('Error', 'Login failed. Please try again.');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unknown error occurred.');
    } finally {
      isLoading.value = false;
      loginBtnState.value = true;
    }
  }
}

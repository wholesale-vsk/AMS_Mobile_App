import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:hexalyte_ams/routes/app_routes.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to Login Screen after Lottie animation duration
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        Get.offNamed(AppRoutes.LOGIN_SCREEN);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation from the uploaded file
          Lottie.asset(
          'assets/images/loading.json', // Use the correct path from pubspec.yaml
          width: 180,
          height: 180,
          fit: BoxFit.contain,
        ),


            const SizedBox(height: 30),

            // Loading Text
            const Text(
              "Loading, please wait...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/controllers/assets_controllers/assets_controller.dart';
import 'package:hexalyte_ams/controllers/network_controller/network_controller.dart';
import 'package:hexalyte_ams/controllers/building_controller/building_controller.dart';
import 'package:hexalyte_ams/controllers/image_picker_controller/image_picker_controller.dart';
import 'package:hexalyte_ams/routes/app_routes.dart';
import 'package:hexalyte_ams/services/firebase/firebase_api.dart';
import 'package:hexalyte_ams/utils/theme/app_theme_management.dart';
import 'package:hexalyte_ams/services/auth/auth_service.dart'; // Add this import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("✅ Firebase initialized successfully");

    await FirebaseApi().initNotifications();

  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }

  // ✅ Register controllers globally before running the app
  Get.lazyPut(() => NetworkController(), fenix: true);
  Get.put(AppThemeManager());
  Get.put(AssetController());
  Get.put(ImagePickerController());
  Get.put(AuthService()); // Add this line to register AuthService

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fadeIn,
      getPages: AppRoutes.routes,
      initialRoute: AppRoutes.LOADING_SCREEN,
    );
  }
}
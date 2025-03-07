import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/constants/image_assets.dart';
import '../../controllers/login_controller/login_controller.dart';
import '../../utils/theme/app_theme_management.dart';
import '../../utils/theme/responsive_size.dart';
import '../../utils/widgets/buttons/filled_button.dart';
import '../../utils/widgets/input_fields/password_input_field.dart';
import '../../utils/widgets/input_fields/text_input_field.dart';
import '../../utils/widgets/labels/label.dart';

class LoginScreen extends StatelessWidget {
  final AppThemeManager themeManager = Get.find();
  final LoginScreenController loginController = Get.put(LoginScreenController());

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen width and height for responsiveness
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: themeManager.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveSize.getWidth(size: 20)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    ImageAssets.login,
                    width: screenWidth > 600 ? ResponsiveSize.getWidth(size: 350) : ResponsiveSize.getWidth(size: 250),
                    height: screenHeight > 600 ? ResponsiveSize.getHeight(size: 350) : ResponsiveSize.getHeight(size: 250),
                  ),
                ),
                SizedBox(height: ResponsiveSize.getHeight(size: 20)),
                // Welcome text with responsive font size
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: screenWidth > 600 ? ResponsiveSize.getWidth(size: 28) : ResponsiveSize.getWidth(size: 24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Please login to continue.',
                  style: TextStyle(
                    fontSize: ResponsiveSize.getWidth(size: 16),
                    fontWeight: FontWeight.normal,
                    color: themeManager.primaryCoolGrey,  // Define color directly
                  ),
                ),
                SizedBox(height: ResponsiveSize.getHeight(size: 40)),
                Form(
                  key: loginController.loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email Field with responsive padding and font size
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: ResponsiveSize.getWidth(size: 14),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      AppTextFormField(
                        controller: loginController.emailController,
                        hintText: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        borderColor: themeManager.primaryColor,
                        inputTextColor: themeManager.primaryColor,
                        cursorColor: themeManager.primaryColor,
                        validator: loginController.verifyEmail,
                        fontSize: ResponsiveSize.getWidth(size: 14),
                      ),
                      SizedBox(height: ResponsiveSize.getHeight(size: 20)),
                      // Password Field
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: ResponsiveSize.getWidth(size: 14),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      AppPasswordTextFormField(
                        controller: loginController.passwordController,
                        hintText: 'Enter your password',
                        obscureText: loginController.obscureText,
                        validator: loginController.verifyPassword,
                        fontSize: ResponsiveSize.getWidth(size: 14),
                        inputTextColor: themeManager.primaryColor,
                        hintColor: themeManager.primaryCoolGrey,
                        cursorColor: themeManager.primaryColor,
                        borderColor: themeManager.primaryColor,
                      ),
                      SizedBox(height: ResponsiveSize.getHeight(size: 36)),
                      // Login Button with responsive size
                      AppFilledButton(
                        backgroundColor:
                        loginController.loginBtnState.value
                            ? themeManager.primaryColor
                            : themeManager.primaryCoolGrey,
                        text: 'Login',
                        onPressed: () {
                          if (loginController.loginBtnState.value) {
                            loginController.onSubmit();
                          }
                        },
                      ),
                      SizedBox(height: ResponsiveSize.getHeight(size: 10)),
                      // Loader
                      if (loginController.isLoading.value)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

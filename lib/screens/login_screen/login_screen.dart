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
    // Get screen dimensions for responsiveness
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: themeManager.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveSize.getWidth(size: 5),
              vertical: ResponsiveSize.getHeight(size:5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: ResponsiveSize.getHeight(size: 10)),
                // Logo with subtle animation
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Image.asset(
                        ImageAssets.login,
                        width: screenWidth > 600
                            ? ResponsiveSize.getWidth(size: 200)
                            : ResponsiveSize.getWidth(size: 180),
                        height: screenWidth > 600
                            ? ResponsiveSize.getHeight(size: 200)
                            : ResponsiveSize.getHeight(size: 180),
                      ),
                    );
                  },
                ),
                SizedBox(height: ResponsiveSize.getHeight(size: 36)),

                // Welcome text with modern typography
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: screenWidth > 600
                        ? ResponsiveSize.getWidth(size: 32)
                        : ResponsiveSize.getWidth(size: 28),
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: ResponsiveSize.getHeight(size: 8)),
                Text(
                  'Sign in to continue',
                  style: TextStyle(
                    fontSize: ResponsiveSize.getWidth(size: 16),
                    fontWeight: FontWeight.w400,
                    color: themeManager.primaryCoolGrey.withOpacity(0.7),
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: ResponsiveSize.getHeight(size: 48)),

                // Login Form in a Card for depth
                Container(
                  decoration: BoxDecoration(
                    color: themeManager.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(ResponsiveSize.getWidth(size: 24)),
                  child: Form(
                    key: loginController.loginFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email field with improved styling
                        Text(
                          'Email',
                          style: TextStyle(
                            fontSize: ResponsiveSize.getWidth(size: 14),
                            fontWeight: FontWeight.w500,
                            color: themeManager.primaryColor,
                          ),
                        ),
                        SizedBox(height: ResponsiveSize.getHeight(size: 8)),
                        AppTextFormField(
                          controller: loginController.emailController,
                          hintText: 'Enter your email address',
                          keyboardType: TextInputType.emailAddress,
                          borderColor: themeManager.primaryColor.withOpacity(0.3),
                          inputTextColor: themeManager.primaryColor,
                          cursorColor: themeManager.primaryColor,
                          validator: loginController.verifyEmail,
                          fontSize: ResponsiveSize.getWidth(size: 15),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: themeManager.primaryColor.withOpacity(0.7),
                            size: ResponsiveSize.getWidth(size: 20),
                          ),
                        ),
                        SizedBox(height: ResponsiveSize.getHeight(size: 24)),

                        // Password field with improved styling
                        Text(
                          'Password',
                          style: TextStyle(
                            fontSize: ResponsiveSize.getWidth(size: 14),
                            fontWeight: FontWeight.w500,
                            color: themeManager.primaryColor,
                          ),
                        ),
                        SizedBox(height: ResponsiveSize.getHeight(size: 8)),
                        AppPasswordTextFormField(
                          controller: loginController.passwordController,
                          hintText: 'Enter your password',
                          obscureText: loginController.obscureText,
                          validator: loginController.verifyPassword,
                          fontSize: ResponsiveSize.getWidth(size: 15),
                          inputTextColor: themeManager.primaryColor,
                          hintColor: themeManager.primaryCoolGrey.withOpacity(0.6),
                          cursorColor: themeManager.primaryColor,
                          borderColor: themeManager.primaryColor.withOpacity(0.3),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: themeManager.primaryColor.withOpacity(0.7),
                            size: ResponsiveSize.getWidth(size: 20),
                          ),
                        ),

                        // // Forgot password link
                        // Align(
                        //   alignment: Alignment.centerRight,
                        //   child: TextButton(
                        //     onPressed: () {
                        //       // Implement forgot password functionality
                        //     },
                        //     style: TextButton.styleFrom(
                        //       padding: EdgeInsets.symmetric(
                        //         vertical: ResponsiveSize.getHeight(size: 8),
                        //       ),
                        //       minimumSize: Size.zero,
                        //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        //     ),
                        //     child: Text(
                        //       'Forgot Password?',
                        //       style: TextStyle(
                        //         fontSize: ResponsiveSize.getWidth(size: 13),
                        //         fontWeight: FontWeight.w500,
                        //         color: themeManager.primaryColor,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        SizedBox(height: ResponsiveSize.getHeight(size: 32)),

                        // Login button with improved styling
                        Obx(() => AppFilledButton(
                          backgroundColor: loginController.loginBtnState.value
                              ? themeManager.primaryColor
                              : themeManager.primaryCoolGrey.withOpacity(0.5),
                          text: 'Sign In',
                          onPressed: () {
                            if (loginController.loginBtnState.value) {
                              loginController.onSubmit();
                            }
                          },
                          height: ResponsiveSize.getHeight(size: 55),
                          borderRadius: 12,
                          textStyle: TextStyle(
                            fontSize: ResponsiveSize.getWidth(size: 16),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                          showShadow: true,
                        )),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: ResponsiveSize.getHeight(size: 16)),

                // Loading indicator with improved styling
                Obx(() => loginController.isLoading.value
                    ? Container(
                  margin: EdgeInsets.only(top: ResponsiveSize.getHeight(size: 16)),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeManager.primaryColor),
                    strokeWidth: 3,
                  ),
                )
                    : const SizedBox()),

                SizedBox(height: ResponsiveSize.getHeight(size: 24)),

                // Sign up option
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Text(
                //       "Don't have an account?",
                //       style: TextStyle(
                //         fontSize: ResponsiveSize.getWidth(size: 14),
                //         color: themeManager.primaryCoolGrey,
                //       ),
                //     ),
                //     TextButton(
                //       onPressed: () {
                //         // Navigate to sign up screen
                //       },
                //       style: TextButton.styleFrom(
                //         minimumSize: Size.zero,
                //         padding: EdgeInsets.symmetric(
                //           horizontal: ResponsiveSize.getWidth(size: 8),
                //           vertical: ResponsiveSize.getHeight(size: 4),
                //         ),
                //         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //       ),
                //       child: Text(
                //         'Sign Up',
                //         style: TextStyle(
                //           fontSize: ResponsiveSize.getWidth(size: 14),
                //           fontWeight: FontWeight.w600,
                //           color: themeManager.primaryColor,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
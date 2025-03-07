import 'dart:ui';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';

// :::::::::::::::::::::::::<< Enum >>:::::::::::::::::::::::: //
enum ThemeType { light, dark, teal, pastel, sunset, forest }

class AppThemeManager extends GetxController {
  Rx<ThemeType> themeType = ThemeType.light.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  // :::::::::::::::::::::::::<< Load Theme >>:::::::::::::::::::::::: //
  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedTheme = prefs.getString('theme');
    if (storedTheme != null) {
      // Load the saved theme from SharedPreferences
      themeType.value = ThemeType.values.firstWhere(
            (e) => e.toString().split('.').last == storedTheme,
        orElse: () => ThemeType.light,
      );
    } else {
      themeType.value = ThemeType.light; // Default theme
      _saveTheme(ThemeType.light); // Save default theme
    }
  }

  // :::::::::::::::::::::::::<< Save Theme >>:::::::::::::::::::::::: //
  Future<void> _saveTheme(ThemeType theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', theme.toString().split('.').last);
  }

  // :::::::::::::::::::::::::<< Set Theme >>:::::::::::::::::::::::: //
  void setTheme(ThemeType selectedTheme) {
    themeType.value = selectedTheme;
    _saveTheme(selectedTheme);
  }

  // :::::::::::::::::::::::::<< Theme-specific Color Getters >>:::::::::::::::::::::::: //
  Color get primaryColor => _getThemeColor(
      light: LightThemeColors.primaryColor,
      dark: DarkThemeColors.primaryColor,
      teal: TealThemeColors.primaryColor,
      pastel: PastelThemeColors.primaryColor,
      sunset: SunsetThemeColors.primaryColor,
      forest: ForestThemeColors.primaryColor);

  Color get backgroundColor => _getThemeColor(
      light: LightThemeColors.bg,
      dark: DarkThemeColors.bg,
      teal: TealThemeColors.bg,
      pastel: PastelThemeColors.bg,
      sunset: SunsetThemeColors.bg,
      forest: ForestThemeColors.bg);

  Color get textColor => _getThemeColor(
      light: LightThemeColors.text,
      dark: DarkThemeColors.text,
      teal: TealThemeColors.text,
      pastel: PastelThemeColors.text,
      sunset: SunsetThemeColors.text,
      forest: ForestThemeColors.text);

  Color get primaryCoolGrey => _getThemeColor(
      light: LightThemeColors.primaryCoolGray,
      dark: DarkThemeColors.primaryCoolGray,
      teal: TealThemeColors.primaryCoolGray,
      pastel: PastelThemeColors.primaryCoolGray,
      sunset: SunsetThemeColors.primaryCoolGray,
      forest: ForestThemeColors.primaryCoolGray);

  Color get primaryRed => _getThemeColor(
      light: LightThemeColors.primaryRed,
      dark: DarkThemeColors.primaryRed,
      teal: TealThemeColors.primaryRed,
      pastel: PastelThemeColors.primaryRed,
      sunset: SunsetThemeColors.primaryRed,
      forest: ForestThemeColors.primaryRed);

  Color get primaryPink => _getThemeColor(
      light: LightThemeColors.primaryPink,
      dark: DarkThemeColors.primaryPink,
      teal: TealThemeColors.primaryPink,
      pastel: PastelThemeColors.primaryPink,
      sunset: SunsetThemeColors.primaryPink,
      forest: ForestThemeColors.primaryPink);

  Color get primaryGreen => _getThemeColor(
      light: LightThemeColors.primaryGreen,
      dark: DarkThemeColors.primaryGreen,
      teal: TealThemeColors.primaryGreen,
      pastel: PastelThemeColors.primaryGreen,
      sunset: SunsetThemeColors.primaryGreen,
      forest: ForestThemeColors.primaryGreen);



  Color get primaryBlue => _getThemeColor(
      light: LightThemeColors.primaryBlue,
      dark: DarkThemeColors.primaryBlue,
      teal: TealThemeColors.primaryBlue,
      pastel: PastelThemeColors.primaryBlue,
      sunset: SunsetThemeColors.primaryBlue,
      forest: ForestThemeColors.primaryBlue);

  Color get primaryGrey => _getThemeColor(
      light: LightThemeColors.primaryGrey,
      dark: DarkThemeColors.primaryGrey,
      teal: TealThemeColors.primaryGrey,
      pastel: PastelThemeColors.primaryGrey,
      sunset: SunsetThemeColors.primaryGrey,
      forest: ForestThemeColors.primaryGrey);

  Color get primaryDark => _getThemeColor(
      light: LightThemeColors.primaryDark,
      dark: DarkThemeColors.primaryDark,
      teal: TealThemeColors.primaryDark,
      pastel: PastelThemeColors.primaryDark,
      sunset: SunsetThemeColors.primaryDark,
      forest: ForestThemeColors.primaryDark);

  Color get primaryWhite => _getThemeColor(
      light: LightThemeColors.primaryWhite,
      dark: DarkThemeColors.primaryWhite,
      teal: TealThemeColors.primaryWhite,
      pastel: PastelThemeColors.primaryWhite,
      sunset: SunsetThemeColors.primaryWhite,
      forest: ForestThemeColors.primaryWhite);

  Color get primaryYellow => _getThemeColor(
      light: LightThemeColors.primaryYellow,
      dark: DarkThemeColors.primaryYellow,
      teal: TealThemeColors.primaryYellow,
      pastel: PastelThemeColors.primaryYellow,
      sunset: SunsetThemeColors.primaryYellow,
      forest: ForestThemeColors.primaryYellow);

  Color get warning => _getThemeColor(
      light: LightThemeColors.warning,
      dark: DarkThemeColors.warning,
      teal: TealThemeColors.warning,
      pastel: PastelThemeColors.warning,
      sunset: SunsetThemeColors.warning,
      forest: ForestThemeColors.warning);

  Color get info => _getThemeColor(
      light: LightThemeColors.info,
      dark: DarkThemeColors.info,
      teal: TealThemeColors.info,
      pastel: PastelThemeColors.info,
      sunset: SunsetThemeColors.info,
      forest: ForestThemeColors.info);

  bool? get isDarkMode => null;

  // Helper function to get theme colors
  Color _getThemeColor({
    required Color light,
    required Color dark,
    required Color teal,
    required Color pastel,
    required Color sunset,
    required Color forest,
  }) {
    switch (themeType.value) {
      case ThemeType.light:
        return light;
      case ThemeType.dark:
        return dark;
      case ThemeType.teal:
        return teal;
      case ThemeType.pastel:
        return pastel;
      case ThemeType.sunset:
        return sunset;
      case ThemeType.forest:
        return forest;
      default:
        return light; // Default color
    }
  }
}


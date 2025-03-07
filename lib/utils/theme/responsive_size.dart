import 'package:get/get.dart';

class ResponsiveSize {
  double baseWidth = 360.0;
  double baseHeight = 753.0;

  static get width => Get.size.width;
  static get height => Get.size.height;

//:::::::::::::::::::::::::::::::::<< Get size using width >>::::::::::::::::::::::::::::::::://
  static double getWidth({required double size}) {
    return size * (width / ResponsiveSize().baseWidth);
  }

//:::::::::::::::::::::::::::::::::<< Get size using height >>::::::::::::::::::::::::::::::::://
  static double getHeight({required double size}) {
    return size * (height / ResponsiveSize().baseHeight);
  }
}

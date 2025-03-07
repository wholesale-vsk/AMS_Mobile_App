import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerController extends GetxController {
  var selectedImage = Rxn<File>();  // ✅ Null-safe reactive variable
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        selectedImage.value = File(image.path);
      } else {
        Get.snackbar("No Image Selected", "You didn't select any image.",
            snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 2));
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: ${e.toString()}",
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 3));
    }
  }

  void clearImage() {
    selectedImage.value = null;
  }
}

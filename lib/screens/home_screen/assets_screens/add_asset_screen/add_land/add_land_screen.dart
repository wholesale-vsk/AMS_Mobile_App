import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/controllers/land_controller/land_controller.dart';
import 'package:hexalyte_ams/controllers/image_picker_controller/image_picker_controller.dart';
import 'package:hexalyte_ams/utils/widgets/calander/calender_field.dart';
import 'package:hexalyte_ams/utils/widgets/drop_down_field/custom_drop_down.dart';
import 'package:image_picker/image_picker.dart';

class AddLandScreen extends StatelessWidget {
  final LandController landController = Get.put(LandController());
  final ImagePickerController imagePickerController = Get.put(ImagePickerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Add Land',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: landController.landFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader(context, "Land Details", Icons.landscape),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  Column(
                    children: [
                      _buildTextField('Land Name', landController.landNameController,
                          prefixIcon: Icons.title),
                      const SizedBox(height: 16),

                      CustomDropdown(
                        label: 'Land Type',
                        options: const ['RESIDENTIAL', 'COMMERCIAL', 'INDUSTRIAL', 'AGRICULTURAL'],
                        controller: landController.landTypeController,
                        onChanged: (value) {
                          landController.landTypeController.text = value!;
                        },
                        selectedItem: landController.landTypeController.text,
                      ),
                      

                      // CustomDropdown(
                      //   label: 'Land Type',
                      //   options: const ['RESIDENTIAL', 'COMMERCIAL', 'INDUSTRIAL', 'AGRICULTURAL'],
                      //   controller: landController.landTypeController,
                      //   onChanged: (value) {
                      //     landController.landTypeController.text = value!;
                      //   },
                      //   selectedItem: landController.landTypeController.text,
                      // ),
                      const SizedBox(height: 16),
                      _buildTextField('Land Size (in sq. ft.)', landController.landSizeController,
                          isNumeric: true, prefixIcon: Icons.square_foot),
                      const SizedBox(height: 16),
                      _buildTextField('Address', landController.landAddressController,
                          prefixIcon: Icons.location_on),
                      const SizedBox(height: 16),
                      _buildTextField('City', landController.landCityController,
                          prefixIcon: Icons.location_city),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader(context, "Purchase Details", Icons.shopping_cart),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  Column(
                    children: [
                      CalendarField(
                        controller: landController.purchaseDateController,
                        hintText: 'Purchase Date',
                        icon: Icons.calendar_month,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Purchase Price (GBP)', landController.purchasePriceController,
                          isNumeric: true, prefixIcon: Icons.attach_money),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader(context, "Leasing Details", Icons.receipt_long),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  Column(
                    children: [
                      CalendarField(
                        controller: landController.leaseDateController,
                        hintText: 'Leasing Date',
                        icon: Icons.calendar_month,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Leasing Value (GBP)', landController.leaseValueController,
                          isNumeric: true, prefixIcon: Icons.payments),
                    ],
                  ),
                ),

                // Uncomment to add Council Tax section
                // const SizedBox(height: 24),
                // _buildSectionHeader(context, "Council Tax Details", Icons.account_balance),
                // const SizedBox(height: 16),
                // _buildCard(
                //   context,
                //   Column(
                //     children: [
                //       CalendarField(
                //         controller: landController.councilTaxDateController,
                //         hintText: 'Council Tax Date',
                //         icon: Icons.calendar_month,
                //       ),
                //       const SizedBox(height: 16),
                //       _buildTextField('Council Tax Value (GBP)', landController.councilTaxValueController,
                //           isNumeric: true, prefixIcon: Icons.account_balance_wallet),
                //     ],
                //   ),
                // ),

                // Uncomment to add image picker functionality
                // const SizedBox(height: 24),
                // _buildSectionHeader(context, "Land Image", Icons.image),
                // const SizedBox(height: 16),
                // _buildCard(context, _buildImagePickerField()),

                const SizedBox(height: 32),
                Obx(() => ElevatedButton(
                  onPressed: landController.isLoading.value
                      ? null
                      : () async {
                    if (landController.landFormKey.currentState?.validate() ?? false) {
                      await landController.addLand();
                    } else {
                      Get.snackbar(
                        "Validation Error",
                        "Please fill all required fields.",
                        backgroundColor: Colors.red[100],
                        colorText: Colors.red[800],
                        snackPosition: SnackPosition.BOTTOM,
                        margin: EdgeInsets.all(16),
                        borderRadius: 10,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      landController.isLoading.value
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Icon(Icons.save),
                      SizedBox(width: 10),
                      Text(
                        landController.isLoading.value ? 'Saving...' : 'Save Land',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700], size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumeric = false, IconData? prefixIcon}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      cursorColor: Colors.blue[700],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey[600]) : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter $label';
        if (isNumeric && double.tryParse(value) == null) return '$label must be a valid number';
        return null;
      },
    );
  }

// Uncomment to add image picker functionality
// Widget _buildImagePickerField() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.stretch,
//     children: [
//       GestureDetector(
//         onTap: () async {
//           await imagePickerController.pickImage(ImageSource.gallery);
//           if (imagePickerController.selectedImage.value != null) {
//             landController.landImageController.text = imagePickerController.selectedImage.value!.path;
//             landController.update();
//           }
//         },
//         child: Container(
//           height: 150,
//           decoration: BoxDecoration(
//             color: Colors.grey[100],
//             border: Border.all(color: Colors.grey[300]!),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Obx(() {
//             return imagePickerController.selectedImage.value != null
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.file(
//                       imagePickerController.selectedImage.value!,
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                     ),
//                   )
//                 : Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.add_a_photo, size: 40, color: Colors.grey[600]),
//                       SizedBox(height: 8),
//                       Text(
//                         "Tap to select land image",
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                     ],
//                   );
//           }),
//         ),
//       ),
//       const SizedBox(height: 10),
//       Obx(() {
//         return imagePickerController.selectedImage.value != null
//             ? TextButton.icon(
//                 icon: Icon(Icons.check_circle, color: Colors.green[700]),
//                 label: Text("Image Selected", style: TextStyle(color: Colors.green[700])),
//                 onPressed: null,
//                 style: TextButton.styleFrom(
//                   backgroundColor: Colors.green[50],
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               )
//             : const SizedBox.shrink();
//       }),
//     ],
//   );
// }
}
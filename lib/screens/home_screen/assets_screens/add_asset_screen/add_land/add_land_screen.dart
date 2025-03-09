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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Add Land',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: landController.landFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Lands  Deteails", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              _buildTextField('Land Name', landController.landNameController),
              CustomDropdown(
                label: 'Land Type',
                options: const ['RESIDENTIAL', 'COMMERCIAL', 'INDUSTRIAL', 'AGRICULTURAL'],
                controller: landController.landTypeController,
                onChanged: (value) {
                  landController.landTypeController.text = value!;
                },
                selectedItem: landController.landTypeController.text,
              ),
              _buildTextField('Land Size (in sq. ft.)', landController.landSizeController, isNumeric: true),
              _buildTextField('Address', landController.landAddressController),
              _buildTextField('City', landController.landCityController),

              const Text("Purchase Deteails", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              CalendarField(
                controller: landController.purchaseDateController,
                hintText: 'Purchase Date',
                icon: Icons.calendar_month,
              ),
              _buildTextField('Purchase Price (GBP)', landController.purchasePriceController, isNumeric: true),


              const Text("Leaseing Deteails", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              CalendarField(
                controller: landController.councilTaxDateController,
                hintText: 'Leaseing  Date',
                icon: Icons.calendar_month,
              ),
              _buildTextField('Leaseing Tax Value (GBP)', landController.councilTaxValueController, isNumeric: true),


              // const Text("Council Deteails", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              // CalendarField(
              //   controller: landController.councilTaxDateController,
              //   hintText: 'Council Tax Date',
              //   icon: Icons.calendar_month,
              // ),
              // _buildTextField('Council Tax Value (GBP)', landController.councilTaxValueController, isNumeric: true),

              // _buildImagePickerField(),
              const SizedBox(height: 20),
              Obx(() => ElevatedButton(
                onPressed: landController.isLoading.value
                    ? null // Disable button while processing
                    : () async {
                  await landController.addLand();
                },
                child: Text(landController.isLoading.value ? 'Saving...' : 'Save Land'),
              )),
            ],
          ),
        ),
      ),
    );
  }

  //:::::::::::::::::::::::::::::::::<< BUILD TEXT FIELD >>::::::::::::::::::::::::::::::::://
  Widget _buildTextField(String label, TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        cursorColor: Colors.blueAccent,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter $label';
          if (isNumeric && double.tryParse(value) == null) return '$label must be a valid number';
          return null;
        },
      ),
    );
  }

//   //:::::::::::::::::::::::::::::::::<< IMAGE PICKER FIELD >>::::::::::::::::::::::::::::::::://
//   Widget _buildImagePickerField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         const Text("Land Image", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
//         const SizedBox(height: 8),
//         GestureDetector(
//           onTap: () async {
//             await imagePickerController.pickImage(ImageSource.gallery);
//             if (imagePickerController.selectedImage.value != null) {
//               landController.landImageController.text = imagePickerController.selectedImage.value!.path;
//               landController.update();
//             }
//           },
//           child: Container(
//             height: 150,
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Obx(() {
//               return imagePickerController.selectedImage.value != null
//                   ? ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: Image.file(
//                   imagePickerController.selectedImage.value!,
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                 ),
//               )
//                   : const Center(
//                 child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
//               );
//             }),
//           ),
//         ),
//         const SizedBox(height: 10),
//         Obx(() {
//           return imagePickerController.selectedImage.value != null
//               ? ElevatedButton(
//             onPressed: () {
//               Get.snackbar("Image Selected", "Land image added successfully.");
//             },
//             child: const Text("Use This Image"),
//           )
//               : const SizedBox.shrink();
//         }),
//       ],
//     );
//   }
 }

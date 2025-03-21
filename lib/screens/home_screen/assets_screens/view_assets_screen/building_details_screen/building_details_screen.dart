import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/models/assets/building/building_model.dart';
import 'package:hexalyte_ams/utils/theme/font_size.dart';
import 'package:hexalyte_ams/utils/theme/responsive_size.dart';
import '../../../../../controllers/Building_Controller/building_controller.dart';
import '../../update_screen/building_update_screen.dart';

class BuildingDetailsScreen extends StatefulWidget {
  final dynamic asset;

  const BuildingDetailsScreen({super.key, required this.asset});

  @override
  _BuildingDetailsScreenState createState() => _BuildingDetailsScreenState();
}

class _BuildingDetailsScreenState extends State<BuildingDetailsScreen> {
  Building? building; // Nullable to prevent crashes
  late BuildingController _buildingController;

  @override
  void initState() {
    super.initState();

    // Initialize the building controller
    _buildingController = Get.put(BuildingController());

    // Initialize building from arguments safely
    try {
      if (Get.arguments != null) {
        if (Get.arguments is Building) {
          building = Get.arguments;
        } else if (Get.arguments is Map<String, dynamic>) {
          building = Building.fromJson(Get.arguments);
        } else if (Get.arguments is Map && Get.arguments['building'] != null) {
          var buildingArg = Get.arguments['building'];
          if (buildingArg is Building) {
            building = buildingArg;
          } else if (buildingArg is Map<String, dynamic>) {
            building = Building.fromJson(buildingArg);
          }
        }
      }
    } catch (e) {
      print("Error parsing building data: $e");
      building = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final Color cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: building == null
            ? _buildErrorScreen() // Show error screen if data is missing
            : Column(
          children: [
            _buildBuildingImage(context),
            SizedBox(height: ResponsiveSize.getHeight(size: 20)),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveSize.getWidth(size: 16),
                  vertical: ResponsiveSize.getHeight(size: 16),
                ),
                child: _buildBuildingDetails(cardColor, primaryColor, textColor),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: building != null
          ? FloatingActionButton(
        onPressed: () async {
          try {
            // Prepare building data for the controller
            if (building != null) {
              var buildingData = _buildingToMap(building!);

              // Populate controller with current building data
              _buildingController.populateFormForEditing(buildingData);

              // Import the BuildingUpdatePage class
              // Add this import at the top of your file:
              // import 'package:hexalyte_ams/pages/buildings/building_update_page.dart';

              // Navigate to the BuildingUpdatePage
              final result = await Get.to(
                    () => BuildingUpdatePage(
                  building: building,
                  asset: widget.asset,
                ),
                transition: Transition.rightToLeft,
              );

              if (result != null) {
                // Update local building with returned data
                setState(() {
                  if (result is Building) {
                    building = result;
                  } else if (result is Map<String, dynamic>) {
                    try {
                      // Try to update the building from the returned map
                      building = Building.fromJson(result);

                      // Also update the controller with this data for consistency
                      _buildingController.populateFormForEditing(result);
                    } catch (e) {
                      print("Error parsing building data: $e");
                    }
                  }
                });

                Get.snackbar(
                  'Success',
                  'Building details updated successfully!',
                  snackPosition: SnackPosition.TOP,
                );
              }
            }
          } catch (e) {
            print("Error updating building: $e");
            Get.snackbar(
              'Error',
              'Failed to update building details: $e',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red.withOpacity(0.1),
              colorText: Colors.red,
            );
          }
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.edit, color: Colors.white),
      )
          : null, // Hide button if no building data
    );
  }

  // Convert Building model to Map for controller
  Map<String, dynamic> _buildingToMap(Building building) {
    return {

      'name': building.name,
      'buildingType': building.buildingType,
      'numberOfFloors': building.numberOfFloors?.toString(),
      'totalArea': building.totalArea?.toString(),
      'address': building.address,
      'city': building.city,

      'ownerName': building.ownerName,
      'purposeOfUse': building.purposeOfUse,

      'councilTaxDate': building.councilTaxDate,
      'councilTaxValue': building.councilTaxValue?.toString(),
      'lease_date': building.leaseDate, // Note: the controller expects 'lease_date' not 'leaseDate'
      'leaseValue': building.leaseValue?.toString(),
      'purchaseDate': building.purchaseDate,
      'purchasePrice': building.purchasePrice?.toString(),
      'buildingImage': building.imageURL,
    };
  }

  /// **🔹 Error Screen (Handles Null Building)**
  Widget _buildErrorScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 50),
          const SizedBox(height: 10),
          Text(
            "Error: No building data available",
            style: TextStyle(fontSize: FontSizes.large, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text("Go Back"),
          ),
        ],
      ),
    );
  }

  /// **🔹 Building Image**
  Widget _buildBuildingImage(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: Image.network(
            building?.imageURL ?? 'assets/images/building.jpg', // Safe access
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.45,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/building.jpg',
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.45,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                building?.name ?? 'Building Name',
                style: const TextStyle(
                  fontSize: FontSizes.extraLarge,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                building?.buildingType ?? 'Building Type',
                style: TextStyle(
                  fontSize: FontSizes.large,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.6),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// **🔹 Building Details**
  Widget _buildBuildingDetails(Color cardColor, Color primaryColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: primaryColor),
          _buildDetailRow('📛 Name:', building?.name, primaryColor, textColor),
          _buildDetailRow('🏢 Type:', building?.buildingType, primaryColor, textColor),
          _buildDetailRow('🏗 Floors:', building?.numberOfFloors, primaryColor, textColor),
          _buildDetailRow('📍 Address:', building?.address, primaryColor, textColor),
          _buildDetailRow('🏙 City:', building?.city, primaryColor, textColor),

          _buildDetailRow('👤 Owner:', building?.ownerName, primaryColor, textColor),
          _buildDetailRow('🗓 Purchase Date:', building?.purchaseDate, primaryColor, textColor),
          _buildDetailRow('💰 Purchase Price:', building?.purchasePrice, primaryColor, textColor),
          _buildDetailRow('💼 Lease Value:', building?.leaseValue, primaryColor, textColor),
          _buildDetailRow('📅 Lease Date:', building?.leaseDate, primaryColor, textColor),
          _buildDetailRow('🏠 Total Area:', building?.totalArea, primaryColor, textColor),

          _buildDetailRow('📅 Council Tax Date:', building?.councilTaxDate, primaryColor, textColor),
          _buildDetailRow('💸 Tax Value:', building?.councilTaxValue, primaryColor, textColor),
          _buildDetailRow('🎯 Purpose:', building?.purposeOfUse, primaryColor, textColor),

          SizedBox(height: ResponsiveSize.getHeight(size: 16)),
          Divider(color: primaryColor),
        ],
      ),
    );
  }

  /// **🔹 Detail Row Widget**
  Widget _buildDetailRow(String label, dynamic value, Color primaryColor, Color textColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveSize.getHeight(size: 10)),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: FontSizes.medium,
                color: primaryColor,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value?.toString() ?? 'N/A',
              style: TextStyle(fontSize: FontSizes.medium, color: textColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
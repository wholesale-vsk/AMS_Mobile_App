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
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                // Share functionality
              },
            ),
          ),
        ],
      ),
      body: building == null
          ? _buildErrorScreen()
          : Stack(
        children: [
          // Hero Image Section
          _buildBuildingHeroImage(context),

          // Details Section with Draggable Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 16),
                          height: 4,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      // Building name and type
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    building?.name ?? 'Unknown Building',
                                    style: const TextStyle(
                                      fontSize: FontSizes.extraLarge,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    building?.buildingType ?? 'Unknown Type',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              building?.city ?? 'Unknown Location',
                              style: TextStyle(
                                fontSize: FontSizes.medium,
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),

                      // Key building stats
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _buildStatCard(
                              context,
                              Icons.apartment,
                              'Floors',
                              building?.numberOfFloors?.toString() ?? 'N/A',
                              primaryColor,
                            ),
                            _buildStatCard(
                              context,
                              Icons.square_foot_outlined,
                              'Total Area',
                              building?.totalArea?.toString() ?? 'N/A',
                              primaryColor,
                            ),
                            _buildStatCard(
                              context,
                              Icons.business_center_outlined,
                              'Purpose',
                              building?.purposeOfUse?.toString() ?? 'N/A',
                              primaryColor,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Details sections
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Building Information',
                          style: TextStyle(
                            fontSize: FontSizes.large,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildDetailsSection(
                        'Property Information',
                        [
                          {'label': 'Building Name', 'value': building?.name},
                          {'label': 'Building Type', 'value': building?.buildingType},
                          {'label': 'Number of Floors', 'value': building?.numberOfFloors},
                          {'label': 'Total Area', 'value': building?.totalArea},
                          {'label': 'Purpose of Use', 'value': building?.purposeOfUse},
                        ],
                        context,
                      ),

                      _buildDetailsSection(
                        'Location Information',
                        [
                          {'label': 'Address', 'value': building?.address},
                          {'label': 'City', 'value': building?.city},
                          {'label': 'Owner', 'value': building?.ownerName},
                        ],
                        context,
                      ),

                      _buildDetailsSection(
                        'Financial Information',
                        [
                          {'label': 'Purchase Date', 'value': building?.purchaseDate},
                          {'label': 'Purchase Price', 'value': building?.purchasePrice},
                          {'label': 'Lease Date', 'value': building?.leaseDate},
                          {'label': 'Lease Value', 'value': building?.leaseValue},
                          {'label': 'Council Tax Date', 'value': building?.councilTaxDate},
                          {'label': 'Council Tax Value', 'value': building?.councilTaxValue},
                        ],
                        context,
                      ),

                      // Additional information section - can be customized
        //               Padding(
        //                 padding: const EdgeInsets.all(16),
        //                 child: Container(
        //                   width: double.infinity,
        //                   padding: const EdgeInsets.all(16),
        //                   decoration: BoxDecoration(
        //                     color: primaryColor.withOpacity(0.1),
        //                     borderRadius: BorderRadius.circular(16),
        //                   ),
        //                   child: Column(
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     children: [
        //                       Row(
        //                         children: [
        //                           Icon(Icons.info_outline, color: primaryColor),
        //                           const SizedBox(width: 8),
        //                           Text(
        //                             'Additional Information',
        //                             style: TextStyle(
        //                               fontWeight: FontWeight.bold,
        //                               color: primaryColor,
        //                             ),
        //                           ),
        //                         ],
        //                       ),
        //                       const SizedBox(height: 8),
        //                       Text(
        //                         'This building is part of the organization\'s asset inventory. Tap the edit button to update details or add more information.',
        //                         style: TextStyle(
        //                           color: textColor.withOpacity(0.7),
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //               ),
                     ],
                   ),
                ),
               );
             },
          ),
        ],
      ),
      floatingActionButton: building != null
          ? FloatingActionButton.extended(
        onPressed: () async {
          try {
            // Prepare building data for the controller
            if (building != null) {
              var buildingData = _buildingToMap(building!);

              // Populate controller with current building data
              _buildingController.populateFormForEditing(buildingData);

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
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text("Edit Building"),
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

  /// Error Screen (Handles Null Building)
  Widget _buildErrorScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            "No building data available",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back),
            label: const Text("Go Back"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingHeroImage(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Building Image
          building?.imageURL != null && building!.imageURL.isNotEmpty
              ? Image.network(
            building!.imageURL,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _defaultBuildingImage(),
          )
              : _defaultBuildingImage(),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // Building info at bottom of the hero image
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        building?.name ?? 'Unknown Building',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: FontSizes.extraLarge,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        building?.buildingType ?? 'Unknown Type',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: FontSizes.medium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultBuildingImage() {
    return Image.asset(
      'assets/images/building.jpg',
      fit: BoxFit.cover,
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String label, String value, Color primaryColor) {
    return Expanded(
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: primaryColor),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(String title, List<Map<String, dynamic>> details, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: FontSizes.medium,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const Divider(),
          ...details.map((detail) => _buildDetailItem(
            detail['label'] ?? '',
            detail['value']?.toString() ?? 'N/A',
            context,
          )),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
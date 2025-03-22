import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/utils/theme/font_size.dart';
import 'package:hexalyte_ams/utils/theme/responsive_size.dart';
import '../../update_screen/vehicle_update_screen.dart';

class VehicleDetailsScreen extends StatelessWidget {
  VehicleDetailsScreen({super.key, required asset, required Map vehicle});

  final Map<String, dynamic>? vehicle = Get.arguments as Map<String, dynamic>?;

  @override
  Widget build(BuildContext context) {
    if (vehicle == null) {

      return Scaffold(
        appBar: AppBar(
          title: const Text("Vehicle Details"),
          elevation: 0,
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
              const SizedBox(height: 16),
              const Text(
                "No vehicle data available",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
        ),
      );
    }

    final Color primaryColor = Theme.of(context).primaryColor;
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // print("Vehicle Details Screen: $vehicle");
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
      body: Stack(
        children: [
          // Hero Image Section
          _buildVehicleHeroImage(context),

          // Details Section
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

                      // Vehicle name and model
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
                                    vehicle?['vrn'] ?? 'Unknown Vehicle',
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
                                    vehicle?['vehicle_type'] ?? 'Unknown',
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
                              vehicle?['model'] ?? 'Unknown Model',
                              style: TextStyle(
                                fontSize: FontSizes.medium,
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),

                      // Key vehicle stats
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _buildStatCard(
                              context,
                              Icons.speed_outlined,
                              'Mileage',
                              vehicle?['mileage']?.toString() ?? 'N/A',
                              primaryColor,
                            ),
                            _buildStatCard(
                              context,
                              Icons.calendar_month_outlined,
                              'MOT Expiry',
                              vehicle?['motExpiredDate']?.toString() ?? 'N/A',
                              primaryColor,
                            ),
                            _buildStatCard(
                              context,
                              Icons.shield_outlined,
                              'Insurance',
                              vehicle?['insuranceDate']?.toString() ?? 'N/A',
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
                          'Vehicle Details',
                          style: TextStyle(
                            fontSize: FontSizes.large,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildDetailsSection(
                        'Registration Information',
                        [
                          {'label': 'Registration Number', 'value': vehicle?['vrn']},
                          {'label': 'Owner', 'value': vehicle?['owner_name']},
                          {'label': 'Vehicle Type', 'value': vehicle?['vehicle_type']},
                          {'label': 'Model', 'value': vehicle?['model']},
                        ],
                        context,
                      ),

                      _buildDetailsSection(
                        'Financial Information',
                        [
                          {'label': 'Purchase Date', 'value': vehicle?['purchaseDate']},
                          {'label': 'Purchase Price', 'value': _formatCurrency(vehicle?['purchasePrice'])},
                          {'label': 'MOT Value', 'value': _formatCurrency(vehicle?['motValue'])},
                          {'label': 'Insurance Value', 'value': _formatCurrency(vehicle?['insuranceValue'])},
                        ],
                        context,
                      ),

                      _buildDetailsSection(
                        'Compliance Dates',
                        [
                          {'label': 'MOT Date', 'value': vehicle?['motDate']},
                          {'label': 'MOT Expiry', 'value': vehicle?['motExpiredDate']},
                          {'label': 'Insurance Date', 'value': vehicle?['insuranceDate']},
                        ],
                        context,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => VehicleUpdatePage(
            vehicleData: vehicle,
            vehicle: vehicle!,

            asset: null, land: {},
          ));
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text("Edit Vehicle"),
      ),
    );
  }

  Widget _buildVehicleHeroImage(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Vehicle Image
          vehicle?['imageURL'] != null && vehicle?['imageURL'].isNotEmpty
              ? Image.network(
            vehicle?['imageURL'] ?? '',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _defaultVehicleImage(),
          )
              : _defaultVehicleImage(),

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

          // Vehicle info at bottom of the hero image
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle?['vrn'] ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: FontSizes.extraLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle?['model'] ?? 'Unknown Model',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: FontSizes.medium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultVehicleImage() {
    return Image.asset(
      'assets/images/car.webp',
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
      margin: const EdgeInsets.only(bottom: 16),
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

  String _formatCurrency(dynamic value) {
    return value == null ? 'N/A' : '${value.toString()}';
  }
}
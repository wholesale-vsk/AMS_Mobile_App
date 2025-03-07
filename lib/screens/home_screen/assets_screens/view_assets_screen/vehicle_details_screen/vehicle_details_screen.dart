import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/utils/theme/font_size.dart';
import 'package:hexalyte_ams/utils/theme/responsive_size.dart';

class VehicleDetailsScreen extends StatelessWidget {
  VehicleDetailsScreen({super.key, required asset, required Map vehicle});

  final Map<String, dynamic>? vehicle = Get.arguments as Map<String, dynamic>?; // ✅ Receive full vehicle details

  @override
  Widget build(BuildContext context) {
    if (vehicle == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Vehicle Details")),
        body: const Center(
          child: Text("No vehicle data available.", style: TextStyle(fontSize: 18, color: Colors.red)),
        ),
      );
    }

    final Color primaryColor = Theme.of(context).primaryColor;
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final Color cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildVehicleImage(context),
            SizedBox(height: ResponsiveSize.getHeight(size: 20)),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveSize.getWidth(size: 16),
                  vertical: ResponsiveSize.getHeight(size: 16),
                ),
                child: _buildVehicleDetails(cardColor, primaryColor, textColor),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/edit-vehicle', arguments: vehicle); // ✅ Navigate to Edit Screen
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  /// **🔹 Vehicle Image with Back Button**
  Widget _buildVehicleImage(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: vehicle?['imageURL'] != null && vehicle?['imageURL'].isNotEmpty
              ? Image.network(
            vehicle?['imageURL'] ?? '',
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.45,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _defaultVehicleImage(context),
          )
              : _defaultVehicleImage(context),
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
                vehicle?['vrn'] ?? 'Vehicle Registration',
                style: const TextStyle(
                  fontSize: FontSizes.extraLarge,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                vehicle?['model'] ?? 'Vehicle Model',
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

  /// **🔹 Default Placeholder Image**
  Widget _defaultVehicleImage(BuildContext context) {
    return Image.asset(
      'assets/images/car.webp',
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45,
      fit: BoxFit.cover,
    );
  }

  /// **🔹 Vehicle Details Section**
  Widget _buildVehicleDetails(Color cardColor, Color primaryColor, Color textColor) {
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
          _buildDetailRow('🚘 Registration:', vehicle?['vrn'], primaryColor, textColor),
          _buildDetailRow('🚗 Vehicle Type:', vehicle?['vehicleCategory'], primaryColor, textColor),
          _buildDetailRow('📍 Model:', vehicle?['model'], primaryColor, textColor),
          _buildDetailRow('👤 Owner:', vehicle?['ownerName'], primaryColor, textColor),
          _buildDetailRow('💰 MOT Value:', _formatCurrency(vehicle?['motValue']), primaryColor, textColor),
          _buildDetailRow('📅 MOT Date:', vehicle?['motDate'], primaryColor, textColor),
          _buildDetailRow('🔒 Insurance Value:', _formatCurrency(vehicle?['insuranceValue']), primaryColor, textColor),
          _buildDetailRow('🗓 Insurance Date:', vehicle?['insuranceDate'], primaryColor, textColor),
          _buildDetailRow('🛒 Purchase Date:', vehicle?['purchaseDate'], primaryColor, textColor),
          _buildDetailRow('💵 Value:', _formatCurrency(vehicle?['purchasePrice']), primaryColor, textColor),
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
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: FontSizes.medium, color: primaryColor)),
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

  /// **🔹 Format Currency**
  String _formatCurrency(dynamic value) {
    return value == null ? 'N/A' : 'LKR ${value.toString()}';
  }
}

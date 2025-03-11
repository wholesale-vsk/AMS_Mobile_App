import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/models/assets/building/building_model.dart';
import 'package:hexalyte_ams/utils/theme/font_size.dart';
import 'package:hexalyte_ams/utils/theme/responsive_size.dart';

class BuildingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data = Get.arguments as Map<String, dynamic>; // ✅ Receive raw Map
  late final Building building;

  BuildingDetailsScreen({super.key, required asset}) {
    building = Building.fromJson(data); // ✅ Convert Map to Building Object
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final Color cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
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
    );
  }

  /// **🔹 Building Image with Back Button**
  Widget _buildBuildingImage(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: Image.network(
            _getValidImageUrl(building.imageURL),
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.45,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/building.jpg', // ✅ Fallback Image
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
                building.name?? 'Building Details',
                style: const TextStyle(
                  fontSize: FontSizes.extraLarge,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                building.city ?? 'Unknown City',
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

  /// **🔹 Building Details Section**
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
          _buildDetailRow('📛 Name:', (building.name), primaryColor, textColor),
          _buildDetailRow('🏢 Building Type:', (building.buildingType), primaryColor, textColor),
          _buildDetailRow('🏗 Number of Floors:', (building.numberOfFloors), primaryColor, textColor),
          _buildDetailRow('📍 Address:', (building.address), primaryColor, textColor),
          _buildDetailRow('🏙 City:', (building.city), primaryColor, textColor),
          _buildDetailRow('👤 Owner:', (building.ownerName), primaryColor, textColor),
          _buildDetailRow('🗓 Purchase Date:', (building.purchaseDate), primaryColor, textColor),
          _buildDetailRow('💰 Purchase Price:', (building.purchasePrice), primaryColor, textColor),
          _buildDetailRow('💼 Lease Value:', (building.leaseValue), primaryColor, textColor),
          _buildDetailRow('🗓 Lease Date:', (building.leaseDate), primaryColor, textColor),
          _buildDetailRow('🏠 Total Area:', (building.totalArea), primaryColor, textColor),
          _buildDetailRow('📅 Council Tax Date:', (building.councilTaxDate), primaryColor, textColor),
          _buildDetailRow('💸 Council Tax Value:', (building.councilTaxValue), primaryColor, textColor),
          _buildDetailRow('🎯 Purpose of Use:', (building.purposeOfUse), primaryColor, textColor),





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

  /// **🔹 Format Currency**
  String _formatCurrency(dynamic value) {
    return value == null ? 'N/A' : 'LKR ${value.toString()}';
  }

  /// **🔹 Image URL Validation**
  String _getValidImageUrl(String? url) {
    return (url != null && url.isNotEmpty) ? url : 'assets/images/building.jpg';
  }
}

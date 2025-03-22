import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/utils/theme/font_size.dart';
import 'package:hexalyte_ams/utils/theme/responsive_size.dart';

import '../../update_screen/lnad_update_screen.dart';

class LandDetailsScreen extends StatelessWidget {
  LandDetailsScreen({super.key, required asset, required Map land});

  final Map<String, dynamic>? land = Get.arguments as Map<String, dynamic>?; // ✅ Fetch data from GetX

  @override
  Widget build(BuildContext context) {
    // **Debugging: Print received data**
    print("Received Land Data: $land");

    if (land == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Land Details")),
        body: const Center(
          child: Text("No land data available.", style: TextStyle(fontSize: 18, color: Colors.red)),
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
            _buildLandImage(context),
            SizedBox(height: ResponsiveSize.getHeight(size: 20)),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveSize.getWidth(size: 16),
                  vertical: ResponsiveSize.getHeight(size: 16),
                ),
                child: _buildLandDetails(cardColor, primaryColor, textColor),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to LandUpdatePage and pass all land data
          Get.to(() => LandUpdatePage(
            landData: land,
            land: land!, // Pass the land map
            vehicle: {}, // Pass an empty map for the required vehicle parameter
            asset: null, // Pass null for the asset parameter
          ));
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  /// **🔹 Land Image with Back Button**
  Widget _buildLandImage(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: land!['imageURL'] != null && land!['imageURL'].isNotEmpty
              ? Image.network(
            land!['imageURL'],
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.45,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _defaultLandImage(context),
          )
              : _defaultLandImage(context),
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
                land!['name'] ?? 'Land Name',
                style: const TextStyle(
                  fontSize: FontSizes.extraLarge,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                land!['city'] ?? 'City Name',
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
  Widget _defaultLandImage(BuildContext context) {
    return Image.asset(
      'assets/images/land.jpg',
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45,
      fit: BoxFit.cover,
    );
  }

  /// **🔹 Land Details Section**
  Widget _buildLandDetails(Color cardColor, Color primaryColor, Color textColor) {
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
          _buildDetailRow('🏡 Land Type:', land!['type'], primaryColor, textColor), // ✅ Fixed Key
          _buildDetailRow('📏 Size:', "${land!['landSize']} acres", primaryColor, textColor), // ✅ Added unit
          _buildDetailRow('📍 Address:', land!['address'], primaryColor, textColor),
          _buildDetailRow('🏙 City:', land!['city'], primaryColor, textColor),
          _buildDetailRow('🗓 Purchase Date:', land!['purchaseDate'], primaryColor, textColor), // ✅ Fixed Key
          _buildDetailRow('💰 purchase Price:', _formatCurrency(land!['purchasePrice']), primaryColor, textColor), // ✅ Fixed Key
          _buildDetailRow('📅 Lease Date:', land!['lease_date'], primaryColor, textColor), // ✅ Fixed Key
          _buildDetailRow('💸 Lease Value:', _formatCurrency(land!['leaseValue']), primaryColor, textColor), // ✅ Fixed Key
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
              style: TextStyle(
                fontSize: FontSizes.medium,
                color: textColor,
              ),
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
    return value == null ? 'N/A' : 'GBP ${value.toString()}';
  }
}

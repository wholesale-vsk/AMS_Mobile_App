import 'package:flutter/material.dart';
import 'package:hexalyte_ams/utils/theme/responsive_size.dart';

import '../../../controllers/vehicle_controller/load_vehicle_controller.dart';

class SearchFieldCard extends StatelessWidget {
  final Color primaryColor;
  final String hintText;
  final Function(String)? onChanged;

  const SearchFieldCard({
    Key? key,
    required this.primaryColor,
    this.hintText = 'Search',
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveSize.getHeight(size: 64),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          // Ensures vertical centering
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveSize.getWidth(size: 16),
            ),
            child: TextField(
              cursorColor: primaryColor,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: primaryColor),
                prefixIcon: IconButton(
                    onPressed: () {
                      loadVehicleController().fetchVehicles();
                      print('Tap');
                    },
                    icon: Icon(Icons.search, color: primaryColor)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}

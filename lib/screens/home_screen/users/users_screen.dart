import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/utils/theme/font_size.dart';
import 'package:hexalyte_ams/utils/theme/responsive_size.dart';
import 'package:hexalyte_ams/utils/theme/app_theme_management.dart';
import 'package:hexalyte_ams/utils/widgets/app_bar/appbar_component.dart';
import '../../../controllers/users_controller/users_controller.dart';

class UserScreen extends StatelessWidget {
  final AppThemeManager themeManager = Get.find();
  final AddUserController controller = Get.put(AddUserController());

  final List<String> categories = ['All', 'Super Admin', 'Admin', 'Manager'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Soft background color
      appBar: AppBarComponent(
        appBarTitle: 'User Management',
        screenWidth: ResponsiveSize.width,
        screenHeight: ResponsiveSize.height,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveSize.getWidth(size: 16),
          vertical: ResponsiveSize.getHeight(size: 10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔘 Modern User Categories
            _buildCategories(),
            SizedBox(height: ResponsiveSize.getHeight(size: 20)),

            // 👥 User List
            Expanded(child: _buildUserList()),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map(
              (category) => Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Obx(
                  () => GestureDetector(
                onTap: () {
                  controller.selectedCategory.value = category;
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveSize.getWidth(size: 20),
                    vertical: ResponsiveSize.getHeight(size: 10),
                  ),
                  decoration: BoxDecoration(
                    color: controller.selectedCategory.value == category
                        ? themeManager.primaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: themeManager.primaryColor, width: 1.5),
                    boxShadow: [
                      if (controller.selectedCategory.value == category)
                        BoxShadow(
                          color: themeManager.primaryColor.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: controller.selectedCategory.value == category
                          ? Colors.white
                          : themeManager.primaryColor,
                      fontSize: FontSizes.small,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ).toList(),
      ),
    );
  }

  Widget _buildUserList() {
    return Obx(
          () => controller.filteredUsers.isEmpty
          ? Center(
        child: Text(
          "No users found",
          style: TextStyle(fontSize: FontSizes.medium, color: Colors.grey[600]),
        ),
      )
          : ListView.separated(
        itemCount: controller.filteredUsers.length,
        separatorBuilder: (_, __) => SizedBox(height: 10),
        itemBuilder: (context, index) {
          final user = controller.filteredUsers[index];

          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: themeManager.primaryColor.withOpacity(0.1),
          child: Text(
            user['name'][0].toUpperCase(), // First letter of name as avatar
            style: TextStyle(
              fontSize: FontSizes.large,
              fontWeight: FontWeight.bold,
              color: themeManager.primaryColor,
            ),
          ),
        ),
        title: Text(
          user['name'],
          style: TextStyle(
            color: themeManager.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: FontSizes.medium,
          ),
        ),
        subtitle: Text(
          '${user['email']}\n${user['role']}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: FontSizes.small,
          ),
        ),
        trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey[400], size: 24),
        onTap: () {
          print("User selected: ${user['name']}");
        },
      ),
    );
  }
}

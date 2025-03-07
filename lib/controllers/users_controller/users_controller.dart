import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class AddUserController extends GetxController {
  RxString selectedCategory = 'All'.obs;

  final List<Map<String, dynamic>> users = [
    {
      'name': 'Joel James',
      'email': 'example@domain.com',
      'role': 'Super Admin',
      'image': 'assets/images/1.webp',
    },
    {
      'name': 'Anna Smith',
      'email': 'example@domain.com',
      'role': 'Super Admin',
      'image': 'assets/images/2.webp',
    },
    {
      'name': 'Joel James',
      'email': 'example@domain.com',
      'role': 'Super Admin',
      'image': 'assets/images/1.webp',
    },
    {
      'name': 'Anna Smith',
      'email': 'example@domain.com',
      'role': 'Super Admin',
      'image': 'assets/images/2.webp',
    },
    {
      'name': 'Michael Brown',
      'email': 'example@domain.com',
      'role': 'Admin',
      'image': 'assets/images/3.webp',
    },
    {
      'name': 'Michael Brown',
      'email': 'example@domain.com',
      'role': 'Admin',
      'image': 'assets/images/3.webp',
    },
    {
      'name': 'John Doe',
      'email': 'example@domain.com',
      'role': 'Manager',
      'image': 'assets/images/2.webp',
    },
    {
      'name': 'Michael Brown',
      'email': 'example@domain.com',
      'role': 'Admin',
      'image': 'assets/images/3.webp',
    },
    {
      'name': 'John Doe',
      'email': 'example@domain.com',
      'role': 'Manager',
      'image': 'assets/images/2.webp',
    },
  ];

  List<Map<String, dynamic>> get filteredUsers {
    if (selectedCategory.value == 'All') return users;
    return users
        .where((user) => user['role'] == selectedCategory.value)
        .toList();
  }
}

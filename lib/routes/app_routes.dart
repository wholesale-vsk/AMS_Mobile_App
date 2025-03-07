// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_navigation/src/routes/get_route.dart';
// import 'package:get/get_navigation/src/routes/transitions_type.dart';
// import 'package:hexalyte_ams/screens/home_screen/app_settigns/app_settings.dart';
// import 'package:hexalyte_ams/screens/home_screen/assets_screens/add_asset_screen/add_asset_screen.dart';
// import 'package:hexalyte_ams/screens/home_screen/assets_screens/add_asset_screen/add_land/add_building_screen.dart';
// import 'package:hexalyte_ams/screens/home_screen/assets_screens/view_assets_screen/building_details_screen/building_details_screen.dart';
// import 'package:hexalyte_ams/screens/home_screen/assets_screens/view_assets_screen/vehicle_details_screen/vehicle_details_screen.dart';
// import 'package:hexalyte_ams/screens/home_screen/assets_screens/view_assets_screen/view_assets_screen.dart';
// import 'package:hexalyte_ams/screens/home_screen/chat_screen/chat_screen.dart';
// import 'package:hexalyte_ams/screens/home_screen/dashboard_screen/dashboard_screen.dart';
// import 'package:hexalyte_ams/screens/home_screen/home_screen.dart';
// import 'package:hexalyte_ams/screens/home_screen/user_support_screen/submit_ticket_screen/submit_ticket_screen.dart';
// import 'package:hexalyte_ams/screens/home_screen/users/add_user_screen/add_user_screen.dart';
// import 'package:hexalyte_ams/screens/home_screen/users/users_screen.dart';
// import '../screens/home_screen/assets_screens/add_asset_screen/add_building/add_building_screen.dart';
// import '../screens/home_screen/assets_screens/add_asset_screen/add_vehicle/add_vehicle_screen.dart';
// import '../screens/home_screen/assets_screens/view_assets_screen/land_details_screen/land_details_screen.dart';
// import '../screens/home_screen/report_screens/assets_select_screen.dart';
// import '../screens/home_screen/report_screens/building_report_screens/build_report_screen.dart';
// import '../screens/home_screen/user_support_screen/user_support_screen.dart';
// import '../screens/login_screen/login_screen.dart';
//
// class AppRoutes {
//   static const String LOGIN_SCREEN = '/login';
//   static const String HOME_SCREEN = '/home';
//   static const String ADD_ASSET_SCREEN = '/add_asset_screen';
//   static const String ADD_VEHICLE_SCREEN = '/add_vehicle_screen';
//   static const String ADD_LAND_SCREEN = '/add_land_screen';
//   static const String ADD_BUILDING_SCREEN = '/add_building_screen';
//   static const String HELP_AND_SUPPORT_SCREEN = '/help_and_support';
//   static const String TICKET_SUBMIT_SCREEN = '/ticket_submit_screen';
//   static const String VIEW_ALL_ASSETS_SCREEN = '/view_all_assets_screen';
//   static const String VEHICLE_DETAILS_SCREEN = '/vehicle_details_screen';
//   static const String LAND_DETAILS_SCREEN = '/land_details_screen';
//   static const String BUILDING_DETAILS_SCREEN = '/building_details_screen';
//   static const String USERS_SCREEN = '/users_screen';
//   static const String ADD_USERS_SCREEN = '/add_users_screen';
//   static const String DASHBOARD_SCREEN = '/dashboard_screen';
//   static const String APP_SETTINGS_SCREEN = '/app_settings_screen';
//   static const String APP_CHAT_SCREEN = '/app_chat_screen';
//   static const String ASSETS_SELECT_FOR_REPORT_SCREEN = '/assets_select_for_report_screen';
//   static const String BUILDING_REPORT_SCREEN = '/building_report_screen';
//
//
//   static final List<GetPage> routes = [
//     GetPage(name: LOGIN_SCREEN, page: () => LoginScreen()),
//     GetPage(
//       name: HOME_SCREEN,
//       page: () => HomeScreen(),
//       transition: Transition.leftToRight,
//       transitionDuration: Duration(milliseconds: 550),
//     ),
//     GetPage(
//       name: ADD_ASSET_SCREEN,
//       page: () => AddAssetScreen(),
//       transition: Transition.rightToLeft,
//       transitionDuration: Duration(milliseconds: 550),
//     ),
//     GetPage(
//       name: ADD_VEHICLE_SCREEN,
//       page: () => AddVehicleScreen(),
//       transition: Transition.rightToLeft,
//       transitionDuration: Duration(milliseconds: 550),
//     ),
//     GetPage(
//       name: ADD_LAND_SCREEN,
//       page: () => AddLandScreen(),
//       transition: Transition.rightToLeft,
//       transitionDuration: Duration(milliseconds: 550),
//     ),
//     GetPage(
//       name: ADD_BUILDING_SCREEN,
//       page: () => AddBuildingScreen(),
//       transition: Transition.rightToLeft,
//       transitionDuration: Duration(milliseconds: 550),
//     ),
//     GetPage(
//       name: HELP_AND_SUPPORT_SCREEN,
//       page: () => SupportScreen(),
//       transition: Transition.rightToLeft,
//       transitionDuration: Duration(milliseconds: 550),
//     ),
//     GetPage(
//       name: TICKET_SUBMIT_SCREEN,
//       page: () => TicketSubmissionForm(),
//       transition: Transition.rightToLeft,
//       transitionDuration: Duration(milliseconds: 550),
//     ),
//     GetPage(
//       name: VIEW_ALL_ASSETS_SCREEN,
//       page: () => AssetsViewScreen(),
//       transition: Transition.rightToLeft,
//       transitionDuration: Duration(milliseconds: 550),
//     ),
//     GetPage(
//       name: VEHICLE_DETAILS_SCREEN,
//       page: () => VehicleDetailsScreen(asset:  Get.arguments,),
//       transition: Transition.rightToLeft,
//       transitionDuration: Duration(milliseconds: 550),
//     ),
//     GetPage(
//       name: LAND_DETAILS_SCREEN,
//       page: () => LandDetailsScreen(asset:  Get.arguments,),
//       transition: Transition.rightToLeft,
//       transitionDuration: Duration(milliseconds: 550),
//     ),
//     GetPage(
//       name: BUILDING_DETAILS_SCREEN,
//       page: () => BuildingDetailsScreen(building: Get.arguments),
//       transition: Transition.rightToLeft,
//       transitionDuration: Duration(milliseconds: 550),
//     ),
//     GetPage(
//       name: USERS_SCREEN,
//       page: () => UserScreen(),
//       transition: Transition.rightToLeft,
//       transitionDuration: Duration(milliseconds: 550),
//     ),
//     GetPage(
//       name: ADD_USERS_SCREEN,
//       page: () => AddUserFormScreen(),
//       transition: Transition.rightToLeft,
//       transitionDuration: Duration(milliseconds: 550),
//     ),
//     GetPage(
//       name: DASHBOARD_SCREEN,
//       page: () => DashboardScreen(),
//       transition: Transition.rightToLeft,
//       transitionDuration: Duration(milliseconds: 550),
//     ),
//     GetPage(
//       name: APP_SETTINGS_SCREEN,
//       page: () => AppSettings(),
//       transition: Transition.rightToLeft,
//       transitionDuration: Duration(milliseconds: 550),
//     ),
//     GetPage(
//       name: APP_CHAT_SCREEN,
//       page: () => ChatScreen(),
//       transition: Transition.rightToLeft,
//       transitionDuration: Duration(milliseconds: 550),
//     ),
//     GetPage(
//       name: ASSETS_SELECT_FOR_REPORT_SCREEN,
//       page: () => AssetsSelectForReports(),
//       transition: Transition.rightToLeft,
//       transitionDuration: Duration(milliseconds: 550),
//     ),
//     GetPage(
//       name: BUILDING_REPORT_SCREEN,
//       page: () => BuildingReportScreen(),
//       transition: Transition.rightToLeft,
//       transitionDuration: Duration(milliseconds: 550),
//     ),
//   ];
// }
import 'package:get/get.dart';
import 'package:hexalyte_ams/screens/home_screen/app_settigns/app_settings.dart';
import 'package:hexalyte_ams/screens/home_screen/assets_screens/add_asset_screen/add_asset_screen.dart';
import 'package:hexalyte_ams/screens/home_screen/assets_screens/add_asset_screen/add_land/add_land_screen.dart';
import 'package:hexalyte_ams/screens/home_screen/assets_screens/view_assets_screen/building_details_screen/building_details_screen.dart';
import 'package:hexalyte_ams/screens/home_screen/assets_screens/view_assets_screen/land_details_screen/land.dart';
import 'package:hexalyte_ams/screens/home_screen/assets_screens/view_assets_screen/vehicle_details_screen/vehicle.dart';
import 'package:hexalyte_ams/screens/home_screen/assets_screens/view_assets_screen/vehicle_details_screen/vehicle_details_screen.dart';
import 'package:hexalyte_ams/screens/home_screen/assets_screens/view_assets_screen/view_assets_screen.dart';
import 'package:hexalyte_ams/screens/home_screen/chat_screen/chat_screen.dart';
import 'package:hexalyte_ams/screens/home_screen/dashboard_screen/dashboard_screen.dart';
import 'package:hexalyte_ams/screens/home_screen/notifications_screen/notification_screen.dart';


import 'package:hexalyte_ams/screens/home_screen/home_screen.dart';
import 'package:hexalyte_ams/screens/home_screen/report_screens/land_report_screens/land_report_screen.dart';
import 'package:hexalyte_ams/screens/home_screen/report_screens/total_assets_report/total_assets_report.dart';
import 'package:hexalyte_ams/screens/home_screen/report_screens/vehicle_report_screens/vehicle_report_screen.dart';
import 'package:hexalyte_ams/screens/home_screen/user_support_screen/submit_ticket_screen/submit_ticket_screen.dart';
import 'package:hexalyte_ams/screens/home_screen/users/add_user_screen/add_user_screen.dart';
import 'package:hexalyte_ams/screens/home_screen/users/users_screen.dart';
import 'package:hexalyte_ams/services/data/load_land.dart.';
import '../screens/home_screen/assets_screens/add_asset_screen/add_building/add_building_screen.dart';
import '../screens/home_screen/assets_screens/add_asset_screen/add_vehicle/add_vehicle_screen.dart';
import '../screens/home_screen/assets_screens/view_assets_screen/building_details_screen/building.dart';
import '../screens/home_screen/assets_screens/view_assets_screen/land_details_screen/land_details_screen.dart';
import '../screens/home_screen/chat_screen/user_selection_screen.dart';
import '../screens/home_screen/faqs_screen/faqs_screen.dart';
import '../screens/home_screen/notification_screens/notification_screens.dart';
import '../screens/home_screen/report_screens/assets_select_screen.dart';
import '../screens/home_screen/report_screens/building_report_screens/build_report_screen.dart';
import '../screens/home_screen/user_support_screen/user_support_screen.dart';
import '../screens/login_screen/login_screen.dart';
import 'package:hexalyte_ams/screens/loading_screen/loading_screen.dart';





class AppRoutes {
  static const String LOADING_SCREEN = '/loading_screen';
  static const String LOGIN_SCREEN = '/login';
  static const String HOME_SCREEN = '/home';
  static const String ADD_ASSET_SCREEN = '/add_asset_screen';
  static const String ADD_VEHICLE_SCREEN = '/add_vehicle_screen';
  static const String ADD_LAND_SCREEN = '/add_land_screen';
  static const String ADD_BUILDING_SCREEN = '/add_building_screen';
  static const String HELP_AND_SUPPORT_SCREEN = '/help_and_support';
  static const String TICKET_SUBMIT_SCREEN = '/ticket_submit_screen';
  static const String NOTIFICATION_SCREEN = '/app_notification_screen';
  static const String VIEW_ALL_ASSETS_SCREEN = '/view_all_assets_screen';
  static const String VEHICLE_DETAILS_SCREEN = '/vehicle_details_screen';
  static const String LAND_DETAILS_SCREEN = '/land_details_screen';
  static const String BUILDING_DETAILS_SCREEN = '/building_details_screen';
  static const String USERS_SCREEN = '/users_screen';
  static const String ADD_USERS_SCREEN = '/add_users_screen';
  static const String DASHBOARD_SCREEN = '/dashboard_screen';
  static const String APP_SETTINGS_SCREEN = '/app_settings_screen';
  static const String APP_CHAT_SCREEN = '/app_chat_screen';
  static const String user_selection_screen = '/app_chat_screen';
  static const String ASSETS_SELECT_FOR_REPORT_SCREEN = '/assets_select_for_report_screen';
  static const String BUILDING_REPORT_SCREEN = '/building_report_screen';
  static const String LAND_REPORT_SCREEN = '/land_report_screen';
  static const String VEHICLE_REPORT_SCREEN = '/vehicle_report_screen';
  static const String TOTAL_ASSETS_REPORT_SCREEN = '/total_assets_report_screen';
  static const String VEHIVLE_SCREEN = '/vehicle_screen';
  static const String LAND_SCREEN = '/land_screen';
  static const String BUILDING_SCREEN = '/building_screen';
  static const String FAQ_SCREEN = '/FAQ_screen';

  static final List<GetPage> routes = [



  // GetPage(
  // name: LOADING_SCREEN,
  // page: () => LoadingScreen(), // ✅ Correct! This returns an instance of the widget
  // transition: Transition.fadeIn,
  // transitionDuration: Duration(milliseconds: 100),
  // ),




  GetPage(
      name: LOGIN_SCREEN,
      page: () => LoginScreen(),
      transitionDuration: Duration(milliseconds: 100),
    ),
    GetPage(
      name: HOME_SCREEN,
      page: () => HomeScreen(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 100),
    ),

    GetPage(
      name: user_selection_screen,
      page: () => UserSelectionScreen(),
      transitionDuration: Duration(milliseconds: 100),
    ),

    GetPage(
      name: ADD_ASSET_SCREEN,
      page: () => AddAssetScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 100),
    ),
    GetPage(
      name: ADD_VEHICLE_SCREEN,
      page: () => AddVehicleScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 100),
    ),
    GetPage(
      name: ADD_LAND_SCREEN,
      page: () => AddLandScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 100),
    ),
    GetPage(
      name: ADD_BUILDING_SCREEN,
      page: () => AddBuildingScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 100),
    ),
    GetPage(
      name: HELP_AND_SUPPORT_SCREEN,
      page: () => SupportScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 100),
    ),
    GetPage(
      name: TICKET_SUBMIT_SCREEN,
      page: () => TicketSubmissionForm(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 100),
    ),


    GetPage(
      name: VIEW_ALL_ASSETS_SCREEN,
      page: () => AssetsViewScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 100),
    ),
     GetPage(
      name: VEHICLE_DETAILS_SCREEN,
      page: () => VehicleDetailsScreen(asset: Get.arguments, vehicle: {},),
      transition: Transition.rightToLeft,
       transitionDuration: Duration(milliseconds: 100),
    ),
     GetPage(
       name: LAND_DETAILS_SCREEN,
       page: () => LandDetailsScreen(asset: Get.arguments, land: {},),
       transition: Transition.rightToLeft,
       transitionDuration: Duration(milliseconds: 100),
     ),
    GetPage(
      name: BUILDING_DETAILS_SCREEN,
      page: () => BuildingDetailsScreen(asset: Get.arguments),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 100),
    ),


    GetPage(
      name: NOTIFICATION_SCREEN,
      page: () => NotificationScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 550),
    ),

    GetPage(
      name: USERS_SCREEN,
      page: () => UserScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 100),
    ),
    GetPage(
      name: ADD_USERS_SCREEN,
      page: () => AddUserFormScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 100),
    ),
    GetPage(
      name: DASHBOARD_SCREEN,
      page: () => DashboardScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 100),
    ),
    GetPage(
      name: APP_SETTINGS_SCREEN,
      page: () => AppSettings(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 100),
    ),
    GetPage(
      name: APP_CHAT_SCREEN,
      page: () => ChatScreen(user: {},),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 100),
    ),

    GetPage(
      name: user_selection_screen,
      page: () => UserSelectionScreen(),
      transitionDuration: Duration(milliseconds: 100),
    ),

    GetPage(
      name: ASSETS_SELECT_FOR_REPORT_SCREEN,
      page: () => AssetsSelectForReports(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 100),
    ),
    GetPage(
      name: BUILDING_REPORT_SCREEN,
      page: () => BuildingReportScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 100),
    ),
    GetPage(
      name: LAND_REPORT_SCREEN,
      page: () => LandReportScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 100),
    ),
    GetPage(
      name: VEHICLE_REPORT_SCREEN,
      page: () => VehicleReportScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 100),
    ),
    GetPage(
      name: TOTAL_ASSETS_REPORT_SCREEN,
      page: () => TotalAssetsReportScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 100),
    ),
    // GetPage(
    //   name: VEHIVLE_SCREEN,
    //   page: () => VehicleScreen(),
    //   transition: Transition.rightToLeft,
    //   transitionDuration: Duration(milliseconds: 100),
    // ),

    // GetPage(
    //   name: LAND_SCREEN,
    //   page: () => landScreen(),
    //   transition: Transition.rightToLeft,
    //   transitionDuration: Duration(milliseconds: 100),
    // ),

    // GetPage(
    //   name: BUILDING_SCREEN,
    //   page: () => buildingScreen(),
    //   transition: Transition.rightToLeft,
    //   transitionDuration: Duration(milliseconds: 100),
    // ),

    GetPage(
      name: HELP_AND_SUPPORT_SCREEN,
      page: () => SupportScreen(),
      transitionDuration: Duration(milliseconds: 100),
    ),
    GetPage(
      name: FAQ_SCREEN,
      page: () => FAQScreen(),
      transitionDuration: Duration(milliseconds: 100),
    ),

  ];

  static notificationscreens() {}




}

class LoadingScreen {
}

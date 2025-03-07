import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  var connectionStatus = 0.obs;
  final Connectivity _connectivity = Connectivity();

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void onInit() {
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateInternetStatus);
    super.onInit();
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
      print("init hit");
      print(result.name);
      _updateInternetStatus(result);
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  void _updateInternetStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.wifi) {
      connectionStatus.value = 1;
    } else if (result == ConnectivityResult.mobile) {
      connectionStatus.value = 1;
    } else {
      connectionStatus.value = -1;
    }
  }
}

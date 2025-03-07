import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ChatController extends GetxController {
  var messages = <Map<String, dynamic>>[].obs;
  ScrollController scrollController = ScrollController();

  void sendMessage(String text) {
    messages.add({'text': text, 'isMine': true});
    messages.add({'text': "Reply to: $text", 'isMine': false}); // Fake reply
    update();

    Future.delayed(const Duration(milliseconds: 300), () {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }
}

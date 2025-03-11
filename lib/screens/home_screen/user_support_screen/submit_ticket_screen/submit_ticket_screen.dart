import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TicketSubmissionForm());
}

class TicketSubmissionForm extends StatelessWidget {
  const TicketSubmissionForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Customer Support Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const ChatHomePage(),
    );
  }
}

class ChatHomePage extends StatelessWidget {
  const ChatHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Support'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: const TawkChatWidget(),
    );
  }
}

class TawkChatWidget extends StatefulWidget {
  const TawkChatWidget({Key? key}) : super(key: key);

  @override
  State<TawkChatWidget> createState() => _TawkChatWidgetState();
}

class _TawkChatWidgetState extends State<TawkChatWidget> {
  late InAppWebViewController webViewController;
  final String chatUrl = 'https://tawk.to/chat/67d048299407921907b356ce/1im2pjp2l';
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(chatUrl)),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadStart: (controller, url) {
            setState(() {
              isLoading = true;
            });
          },
          onLoadStop: (controller, url) {
            setState(() {
              isLoading = false;
            });
          },
          onLoadError: (controller, url, code, message) {
            debugPrint('Failed to load $url: $message');
          },
        ),
        if (isLoading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

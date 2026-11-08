import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const AlikuryerApp());

class AlikuryerApp extends StatelessWidget {
  const AlikuryerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Alikuryer',
    theme: ThemeData(colorSchemeSeed: const Color(0xFFD71920)),
    home: const AlikuryerWebsite(),
  );
}

class AlikuryerWebsite extends StatefulWidget {
  const AlikuryerWebsite({super.key});
  @override
  State<AlikuryerWebsite> createState() => _AlikuryerWebsiteState();
}

class _AlikuryerWebsiteState extends State<AlikuryerWebsite> {
  late final WebViewController controller;
  int progress = 0;
  bool error = false;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (value) => setState(() => progress = value),
        onPageStarted: (_) => setState(() => error = false),
        onWebResourceError: (e) {
          if (e.isForMainFrame == true) setState(() => error = true);
        },
      ))
      ..loadRequest(Uri.parse('https://alikuryer-flavor-trail.lovable.app'));
  }
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) async {
      if (!didPop && await controller.canGoBack()) {
        await controller.goBack();
      } else if (!didPop) {
        SystemNavigator.pop();
      }
    },
    child: Scaffold(
      body: SafeArea(
        child: error
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Internetga ulanishni tekshiring'),
              const SizedBox(height: 12),
              FilledButton(onPressed: () => controller.reload(), child: const Text('Qayta urinish')),
            ]))
          : Column(children: [
              if (progress < 100) LinearProgressIndicator(value: progress / 100),
              Expanded(child: WebViewWidget(controller: controller)),
            ]),
      ),
    ),
  );
}

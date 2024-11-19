import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:touna/main.dart';

class OpenWeb extends StatefulWidget {
  const OpenWeb({super.key});
  @override
  OpenWebState createState() => OpenWebState();
}

class OpenWebState extends State<OpenWeb> {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: 'Web',
      body: InAppWebView(
        onLoadResource: (controller, resource) {},
        initialUrlRequest:
            URLRequest(url: WebUri('https://absensi.kejaksaan.go.id')),
      ),
    );
  }
}

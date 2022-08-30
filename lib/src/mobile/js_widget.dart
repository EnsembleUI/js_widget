import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

///
///A generic library for exposing javascript widgets in Flutter webview.
///Took https://github.com/senthilnasa/high_chart as a start and genericized it
///
class JsWidget extends StatefulWidget {
  const JsWidget(
      { required this.id,
        required this.createHtmlTag,
        required this.data,
        required this.scriptToInstantiate,
        required this.size,
        this.loader = const Center(child: CircularProgressIndicator()),
        this.scripts = const [],
        Key? key})
      : super(key: key);

  ///Custom `loader` widget, until script is loaded
  ///
  ///Has no effect on Web
  ///
  ///Defaults to `CircularProgressIndicator`
  final Widget loader;
  final String id;
  final Function scriptToInstantiate;
  final Function createHtmlTag;
  final String data;

  ///Widget size
  ///
  ///Height and width of the widget is required
  ///
  ///```dart
  ///Size size = Size(400, 300);
  ///```
  final Size size;

  ///Scripts to be loaded
  final List<String> scripts;
  @override
  JsWidgetState createState() => JsWidgetState();
}

class JsWidgetState extends State<JsWidget> {
  bool _isLoaded = false;

  WebViewController? _controller;

  @override
  void didUpdateWidget(covariant JsWidget oldWidget) {
    if (oldWidget.data != widget.data ||
        oldWidget.size != widget.size ||
        oldWidget.scripts != widget.scripts) {
      _loadHtmlContent(_controller!);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size.height,
      width: widget.size.width,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          !_isLoaded ? widget.loader : const SizedBox.shrink(),
          WebView(
            debuggingEnabled: kDebugMode,
            allowsInlineMediaPlayback: true,
            javascriptMode: JavascriptMode.unrestricted,
            zoomEnabled: false,
            initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
            backgroundColor: Colors.transparent,
            onWebViewCreated: (WebViewController _) {
              _controller = _;
              _loadHtmlContent(_);
            },
            onWebResourceError: (error) {
              debugPrint(error.toString());
            },
            onPageFinished: (String url) {
              _loadData();
            },
            navigationDelegate: (NavigationRequest request) async {
              if (await canLaunchUrlString(request.url)) {
                try {
                  launchUrlString(request.url);
                } catch (e) {
                  debugPrint('JsWidget Error ->$e');
                }
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        ],
      ),
    );
  }

  void _loadHtmlContent(WebViewController _) {
    String html = "";
    html +=
    '<!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=0"/> </head> <body>${widget.createHtmlTag()}';
    for (String src in widget.scripts) {
      html += '<script async="false" src="$src"></script>';
    }
    html += '</body></html>';
    _.loadHtmlString(html);
  }

  void _loadData() {
    setState(() {
      _isLoaded = true;
    });
    _controller!.runJavascript('''
      ${widget.scriptToInstantiate(widget.data)}
   ''');
  }
}
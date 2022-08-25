import 'dart:html' as html;
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'js.dart';
///
///A generic library for exposing javascript widgets in Flutter webview.
///Took https://github.com/senthilnasa/high_chart as a start and genericized it
///
class HighCharts extends StatefulWidget {
  const HighCharts(
      {required this.createHtmlTag,
        required this.data,
        required this.scriptToInstantiate,
        required this.size,
        this.loader = const CircularProgressIndicator(),
        this.scripts = const [],
        Key? key})
      : super(key: key);

  ///Custom `loader` widget, until script is loaded
  ///
  ///Has no effect on Web
  ///
  ///Defaults to `CircularProgressIndicator`
  final Widget loader;

  ///Widget data
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
  _HighChartsState createState() => _HighChartsState();
}

class _HighChartsState extends State<HighCharts> {
  final String _htmlId =
      "JsWidgetId" + (Random().nextInt(900000) + 100000).toString();
  @override
  void didUpdateWidget(covariant HighCharts oldWidget) {
    if (oldWidget.data != widget.data ||
        oldWidget.size != widget.size ||
        oldWidget.scripts != widget.scripts ||
        oldWidget.loader != widget.loader) {
      _load();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_htmlId, (int viewId) {
      final html.Element element = html.Element.html(widget.createHtmlTag(_htmlId));
      return element;
    });

    return SizedBox(
      height: widget.size.height,
      width: widget.size.width,
      child: HtmlElementView(viewType: _htmlId),
    );
  }

  void _load() {
    Future.delayed(const Duration(milliseconds: 250), () {
      eval('${widget.scriptToInstantiate(_htmlId)}');
    });
  }
}
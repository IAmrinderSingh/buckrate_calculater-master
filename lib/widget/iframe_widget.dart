import 'dart:html' as h;
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';

class IframeView extends StatefulWidget {
  final String source;
  final String? allow;
  const IframeView({super.key, required this.source, this.allow});

  @override
  _IframeViewState createState() => _IframeViewState();
}

class _IframeViewState extends State<IframeView> {
  final h.IFrameElement _iframeElement = h.IFrameElement();

  @override
  void initState() {
    super.initState();
    _iframeElement.src = widget.source;
    _iframeElement.style.border = 'none';
    _iframeElement.allow = 'none';

    ui.platformViewRegistry.registerViewFactory(
      widget.source, //use source as registered key to ensure uniqueness
      (viewId) => _iframeElement,
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      key: UniqueKey(),
      viewType: widget.source,
    );
  }
}

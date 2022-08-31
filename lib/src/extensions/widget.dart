import 'dart:math';

import 'package:flutter/material.dart';

/// Extensions on top of the [Widget] class
extension WidgetExtensions on Widget {
  /// Transform your widget and make it mirrored
  Widget makeMirror(bool enableMirror) {
    return enableMirror
        ? Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(pi),
            child: this,
          )
        : this;
  }
}

import 'dart:math';

import 'package:flutter/material.dart';

extension WidgetExtensions on Widget {
  /// enable Mirror widget
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

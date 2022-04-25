import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'qoi.dart';

/// Use [QOI] with extra functions targeted for Flutter users
extension FlutterQOIExts on QOI {
  /// Create an image from this QOI data
  ///
  /// Returned image may be used inside a [RawImage], for example.
  Future<ui.Image> toImage() {
    final c = Completer<ui.Image>();

    ui.decodeImageFromPixels(
      toRaw(),
      width,
      height,
      ui.PixelFormat.rgba8888,
      c.complete,
    );
    return c.future;
  }

  FutureBuilder<ui.Image> toImageWidget({
    Widget? loadingWidget,
  }) {
    return FutureBuilder<ui.Image>(
      future: toImage(),
      builder: (_, img) {
        if (img.hasData) {
          return RawImage(
            image: img.data,
          );
        } else {
          return loadingWidget ?? Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

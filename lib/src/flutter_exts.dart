import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'qoi.dart';

/// Extends [QOI] with extra methods targeted for Flutter users
///
/// Automatically exported by `package:dqoi/dqoi.dart`.
extension FlutterQOIExts on QOI {
  /// Create an [ui.Image] from this QOI data, in future
  ///
  /// Alternatively, use [toImageWidget] for a more complete solution using [FutureBuilder] to await the rendering.
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

  /// Using QOI data, create a [FutureBuilder] which will show an [ui.Image] once ready
  ///
  /// Supply [loadingWidget] to show a custom widget whilst rendering the image. The default is a centered [CircularProgressIndicator]. Note that in the unlikely event of a decoding error, this widget will also be shown.
  FutureBuilder<ui.Image> toImageWidget({
    Widget? loadingWidget,
  }) =>
      FutureBuilder<ui.Image>(
        future: toImage(),
        builder: (_, img) => img.hasData
            ? RawImage(image: img.data)
            : (loadingWidget ?? Center(child: CircularProgressIndicator())),
      );
}

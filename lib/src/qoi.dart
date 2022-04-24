import 'dart:typed_data';

import 'package:image/image.dart';
export 'package:image/image.dart' show Channels;

import 'interpreters/decode.dart' as decoder;
import 'interpreters/encode.dart' as encoder;

/// Represents a QOI file that has just been decoded or needs to be encoded, as listed below
///
/// Can be constructed from a:
/// * raw binary file, with the [QOI.fromRaw] constructor
/// * PNG image, with the [QOI.fromPNG] constructor
/// * QOI image, with the [QOI.fromQOI] constructor
///
/// Can be converted to a:
/// * raw binary file, with the [toRaw] method
/// * PNG image, with the [toPNG] method
/// * QOI image, with the [toQOI] method
class QOI {
  /// Represents any bytes, not necessarily just QOI format bytes
  ///
  /// Always represents QOI bytes after decoding, and unknown bytes before encoding.
  final Uint8List _bytes;

  /// Image width in pixels
  final int _width;

  /// Image height in pixels
  final int _height;

  /// Channels in image (RGB or RGBA)
  ///
  /// Will always be RGBA formatted after decoding.
  final Channels _channels;

  /// Colorspace number of image
  ///
  /// 0 represents sRGB with linear alpha; 1 represents all channels alpha.
  final int _colorspace;

  /// Constructor that does do any automatic decoding
  ///
  /// The input bytes must just be unformatted pixel data (eg. no headers).
  QOI.fromRaw({
    required Uint8List bytes,
    required int width,
    required int height,
    Channels channels = Channels.rgba,
    int colorspace = 0,
  })  : _bytes = bytes,
        _width = width,
        _height = height,
        _channels = channels,
        _colorspace = colorspace;

  /// Decode from a PNG image, using the [Image] library
  static QOI fromPNG(
    Uint8List raw, {
    Channels? overrideChannels,
    int? overrideColorspace,
  }) {
    final Image image = PngDecoder().decodeImage(raw)!;

    return QOI.fromRaw(
      bytes: image.getBytes(),
      width: image.width,
      height: image.height,
      channels: overrideChannels ?? image.channels,
      colorspace: overrideColorspace ?? 0,
    );
  }

  /// Decode from a QOI image, using the built-in decoder
  static QOI fromQOI(Uint8List raw) => decoder.decode(data: raw);

  /// Encode to a QOI image, using the built-in encoder
  Uint8List toQOI() => encoder.encode(
        data: _bytes,
        width: _width,
        height: _height,
        channels: _channels == Channels.rgb ? 3 : 4,
        colorspace: _colorspace,
      );

  /// Encode to a PNG image, using the [Image] library
  Uint8List toPNG() => Uint8List.fromList(
        PngEncoder().encodeImage(
          Image.fromBytes(
            _width,
            _height,
            _bytes,
            channels: _channels,
          ),
        ),
      );

  /// Dump to a raw binary image, without any conversions
  ///
  /// The output just represents the pixel data (eg. no headers).
  Uint8List toRaw() => _bytes;
}

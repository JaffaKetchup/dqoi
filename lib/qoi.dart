library dqoi;

import 'dart:typed_data';

import 'decode.dart' as decoder;

class QOI {
  final int width;
  final int height;
  final int channels;
  final int colorSpace;
  final Uint8List bytes;

  QOI({
    required this.width,
    required this.height,
    required this.channels,
    required this.colorSpace,
    required this.bytes,
  });

  static QOI decode(Uint8List raw) => decoder.decode(data: raw);
}

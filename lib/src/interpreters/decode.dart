import 'dart:typed_data';

import 'shared.dart';
import '../qoi.dart';

class Diff {
  static const int red = 0x30;
  static const int green = 0x0c;
  static const int blue = 0x03;
}

class Luma {
  static const int green = 0x3f;
  static const int rg = 0xf0;
  static const int bg = 0x0f;
}

QOI decode({
  required Uint8List data,
}) {
  final List<Color> seenPixels = List.filled(64, Color.zero);

  Color prevColor = Color(0, 0, 0, 255);
  int readIndex = 0;
  int writeIndex = 0;

  int readByte() => data[readIndex++];
  int read32() =>
      (readByte() << 24) | (readByte() << 16) | (readByte() << 8) | readByte();

  if (data.lengthInBytes < 22 || read32() != 0x716f6966) {
    throw ArgumentError(
      'Invalid QOI data\nCheck the size and header of the data are correct',
    );
  }

  // Retrieve headers
  final int width = read32();
  final int height = read32();
  readByte();
  final int channels = 4; // Fix channels to RGBA regardless of headers
  final int colorspace = readByte();
  final Uint8List bytes = Uint8List(width * height * channels);

  void writeColor(Color color) {
    bytes[writeIndex++] = color.red;
    bytes[writeIndex++] = color.green;
    bytes[writeIndex++] = color.blue;
    bytes[writeIndex++] = color.alpha;
  }

  while (readIndex < data.lengthInBytes - 8) {
    final int byte = readByte();

    if (byte == IDTag.rgb || byte == IDTag.rgba) {
      prevColor = Color(
        readByte(),
        readByte(),
        readByte(),
        byte == IDTag.rgba ? readByte() : prevColor.alpha,
      );

      writeColor(prevColor);
      seenPixels[prevColor.hashCode] = prevColor;
      continue;
    }

    switch (byte & 0xc0) {
      case IDTag.run:
        for (int i = 0; i <= (byte & 0x3f); i++) {
          writeColor(prevColor);
          seenPixels[prevColor.hashCode] = prevColor;
        }
        break;
      case IDTag.index:
        writeColor(seenPixels[byte & 0x3f]);
        prevColor = seenPixels[byte & 0x3f];
        break;
      case IDTag.diff:
        prevColor = Color(
          (prevColor.red + ((byte & Diff.red) >> 4) - 2) & 0xff,
          (prevColor.green + ((byte & Diff.green) >> 2) - 2) & 0xff,
          (prevColor.blue + (byte & Diff.blue) - 2) & 0xff,
          prevColor.alpha,
        );
        writeColor(prevColor);
        seenPixels[prevColor.hashCode] = prevColor;
        break;
      case IDTag.luma:
        final dg = (byte & Luma.green) - 32;

        final byte2 = readByte();
        final drdg = ((byte2 & Luma.rg) >> 4) - 8;
        final dbdg = (byte2 & Luma.bg) - 8;

        prevColor = Color(
          (prevColor.red + drdg + dg) & 0xff,
          (prevColor.green + dg) & 0xff,
          (prevColor.blue + dbdg + dg) & 0xff,
          prevColor.alpha,
        );

        writeColor(prevColor);
        seenPixels[prevColor.hashCode] = prevColor;
        break;
    }
  }

  return QOI.fromRaw(
    width: width,
    height: height,
    channels: channels == 3 ? Channels.rgb : Channels.rgba,
    colorspace: colorspace,
    bytes: bytes,
  );
}

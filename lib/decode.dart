import 'dart:typed_data';

import 'shared/color.dart';
import 'shared/consts.dart';
import 'qoi.dart';

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

  if (data.lengthInBytes < headerSize + 8 || read32() != 0x716f6966) {
    throw ArgumentError(
      'Invalid QOI data\nCheck the size and header of the data are correct',
    );
  }

  final int width = read32();
  final int height = read32();
  final int channels = readByte();
  final int colorSpace = readByte();
  final Uint8List bytes = Uint8List(width * height * channels);

  void writeColor(Color color) {
    bytes[writeIndex++] = color.red;
    bytes[writeIndex++] = color.green;
    bytes[writeIndex++] = color.blue;
    bytes[writeIndex++] = color.alpha;
  }

  while (readIndex < data.lengthInBytes - 8) {
    final int byte = readByte();

    if (byte == opRGB || byte == opRGBA) {
      prevColor = Color(
        readByte(),
        readByte(),
        readByte(),
        byte == opRGBA ? readByte() : prevColor.alpha,
      );

      writeColor(prevColor);
      seenPixels[prevColor.hashCode] = prevColor;
      continue;
    }

    switch (byte & chunkMask) {
      case opRUN:
        for (int i = 0; i <= (byte & runLength); i++) {
          writeColor(prevColor);
          seenPixels[prevColor.hashCode] = prevColor;
        }
        break;
      case opINDEX:
        writeColor(seenPixels[byte & index]);
        prevColor = seenPixels[byte & index];
        break;
      case opDIFF:
        prevColor = Color(
          (prevColor.red + ((byte & diffRed) >> 4) - 2) & 0xff,
          (prevColor.green + ((byte & diffGreen) >> 2) - 2) & 0xff,
          (prevColor.blue + (byte & diffBlue) - 2) & 0xff,
          prevColor.alpha,
        );

        writeColor(prevColor);
        seenPixels[prevColor.hashCode] = prevColor;
        break;
      case opLUMA:
        final dg = (byte & lumaGreen) - 32;

        final byte2 = readByte();
        final drdg = ((byte2 & lumaDiffRG) >> 4) - 8;
        final dbdg = (byte2 & lumaDiffBG) - 8;

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

  return QOI(
    width: width,
    height: height,
    channels: channels,
    colorSpace: colorSpace,
    bytes: bytes,
  );
}

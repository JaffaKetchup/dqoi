import 'dart:typed_data';

import 'shared.dart';

Uint8List encode({
  required Uint8List data,
  required int width,
  required int height,
  required int channels,
  required int colorspace,
}) {
  // Fix channels to RGBA regardless of argument
  final int fixedRGBA = 4;

  final int lastPixel = data.lengthInBytes - fixedRGBA;
  final seenPixels = List<Color>.filled(64, Color.zero);
  final bytes = Uint8List(width * height * (fixedRGBA + 1) +
      22); // `width * height * (RGBA number of color channels + identification tag byte) + header length + end marker size`

  var prevColor = Color(0, 0, 0, 255);
  var run = 0;
  var index = 0;

  void write32(int value) {
    bytes[index++] = (value & 0xff000000) >> 24;
    bytes[index++] = (value & 0x00ff0000) >> 16;
    bytes[index++] = (value & 0x0000ff00) >> 8;
    bytes[index++] = (value & 0x000000ff) >> 0;
  }

  void resetRun() {
    bytes[index++] = IDTag.run | (run - 1);
    run = 0;
  }

  // Write headers to the file
  write32(0x716f6966);
  write32(width);
  write32(height);
  bytes[index++] = channels;
  bytes[index++] = colorspace;

  for (int offset = 0; offset <= lastPixel; offset += fixedRGBA) {
    final Color color = Color(
      data[offset + 0],
      data[offset + 1],
      data[offset + 2],
      fixedRGBA == 4 ? data[offset + 3] : prevColor.alpha,
    );

    if (color == prevColor) {
      run++;
      if (run == 62 || offset == lastPixel) resetRun();
    } else {
      if (run > 0) resetRun();

      if (color == seenPixels[color.hashCode]) {
        bytes[index++] = IDTag.index | color.hashCode;
      } else {
        seenPixels[color.hashCode] = color;

        if (color.alpha == prevColor.alpha) {
          int diffRed = (color.red - prevColor.red) & 255;
          if (diffRed > 127) diffRed -= 256;
          int diffGreen = (color.green - prevColor.green) & 255;
          if (diffGreen > 127) diffGreen -= 256;
          int diffBlue = (color.blue - prevColor.blue) & 255;
          if (diffBlue > 127) diffBlue -= 256;

          int diffRedGreen = diffRed - diffGreen;
          int diffBlueGreen = diffBlue - diffGreen;

          if (diffRed > -3 &&
              diffRed < 2 &&
              diffGreen > -3 &&
              diffGreen < 2 &&
              diffBlue > -3 &&
              diffBlue < 2) {
            bytes[index++] = IDTag.diff |
                (diffRed + 2) << 4 |
                (diffGreen + 2) << 2 |
                (diffBlue + 2);
          } else if (diffRedGreen > -9 &&
              diffRedGreen < 8 &&
              diffGreen > -33 &&
              diffGreen < 32 &&
              diffBlueGreen > -9 &&
              diffBlueGreen < 8) {
            bytes[index++] = IDTag.luma | (diffGreen + 32);
            bytes[index++] = (diffRedGreen + 8) << 4 | (diffBlueGreen + 8);
          } else {
            bytes[index++] = IDTag.rgb;
            bytes[index++] = color.red;
            bytes[index++] = color.green;
            bytes[index++] = color.blue;
          }
        } else {
          bytes[index++] = IDTag.rgba;
          bytes[index++] = color.red;
          bytes[index++] = color.green;
          bytes[index++] = color.blue;
          bytes[index++] = color.alpha;
        }
      }
    }

    prevColor = color;
  }

  for (int byte in Uint8List(8)..[7] = 1) {
    bytes[index++] = byte;
  }

  return Uint8List.fromList(bytes.getRange(0, index).toList());
}

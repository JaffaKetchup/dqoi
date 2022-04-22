import 'dart:typed_data';

import 'shared/color.dart';
import 'shared/consts.dart';

Uint8List encode({
  required Uint8List data,
  required int imageWidth,
  required int imageHeight,
  required int channels,
  required int colorspace,
}) {
  final int lastPixel = data.lengthInBytes - channels;
  final List<Color> seenPixels = List.filled(64, Color.zero);
  final Uint8List bytes =
      Uint8List(imageWidth * imageHeight * (channels + 1) + headerSize + 8);

  Color prevColor = Color(0, 0, 0, 255);
  int run = 0;
  int index = 0;

  void write32(int value) {
    bytes[index++] = (value & 0xff000000) >> 24;
    bytes[index++] = (value & 0x00ff0000) >> 16;
    bytes[index++] = (value & 0x0000ff00) >> 8;
    bytes[index++] = (value & 0x000000ff) >> 0;
  }

  write32(0x716f6966);
  write32(imageWidth);
  write32(imageHeight);
  bytes[index++] = channels;
  bytes[index++] = colorspace;

  for (int offset = 0; offset <= lastPixel; offset += channels) {
    final Color color = Color(
      data[offset + 0],
      data[offset + 1],
      data[offset + 2],
      channels == 4 ? data[offset + 3] : prevColor.alpha,
    );

    if (color == prevColor) {
      run++;
      if (run == 62 || offset == lastPixel) {
        bytes[index++] = opRUN | (run - 1);
        run = 0;
      }
    } else {
      if (run > 0) {
        bytes[index++] = opRUN | (run - 1);
        run = 0;
      }

      if (color == seenPixels[color.hashCode]) {
        bytes[index++] = opINDEX | color.hashCode;
      } else {
        seenPixels[color.hashCode] = color;

        final Color diff = color - prevColor;
        final int diffRedGreen = diff.red - diff.green;
        final int diffBlueGreen = diff.blue - diff.green;

        if (diff.alpha == 0) {
          if ((diff.red >= -2 && diff.red <= 1) &&
              (diff.green >= -2 && diff.green <= 1) &&
              (diff.blue >= -2 && diff.blue <= 1)) {
            bytes[index++] = (opDIFF |
                ((diff.red + 2) << 4) |
                ((diff.green + 2) << 2) |
                ((diff.blue + 2) << 0));
          } else if ((diff.green >= -32 && diff.green <= 31) &&
              (diffRedGreen >= -8 && diffRedGreen <= 7) &&
              (diffBlueGreen >= -8 && diffBlueGreen <= 7)) {
            bytes[index++] = opLUMA | (diff.green + 32);
            bytes[index++] = ((diffRedGreen + 8) << 4) | (diffBlueGreen + 8);
          } else {
            bytes[index++] = opRGB;
            bytes[index++] = color.red;
            bytes[index++] = color.green;
            bytes[index++] = color.blue;
          }
        } else {
          bytes[index++] = opRGBA;
          bytes[index++] = color.red;
          bytes[index++] = color.green;
          bytes[index++] = color.blue;
          bytes[index++] = color.alpha;
        }
      }
    }

    prevColor = color;
  }

  for (int b in endMarker) {
    bytes[index++] = b;
  }

  return Uint8List.fromList(bytes.getRange(0, index).toList());
}

import 'dart:typed_data';

import 'shared.dart';

Uint8List encode({
  required Uint8List data,
  required int width,
  required int height,
  required int channels,
  required int colorspace,
}) {
  final int lastPixel = data.lengthInBytes - channels;
  final seenPixels = List<Color>.filled(64, Color.zero);
  final bytes = Uint8List(width * height * (channels + 1) +
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

  for (int offset = 0; offset <= lastPixel; offset += channels) {
    final Color color = Color(
      data[offset + 0],
      data[offset + 1],
      data[offset + 2],
      channels == 4 ? data[offset + 3] : prevColor.alpha,
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
          int vr = color.red - prevColor.red;
          int vg = color.green - prevColor.green;
          int vb = color.blue - prevColor.blue;

          int vg_r = vr - vg;
          int vg_b = vb - vg;

          if (vr > -3 && vr < 2 && vg > -3 && vg < 2 && vb > -3 && vb < 2) {
            bytes[index++] =
                IDTag.diff | (vr + 2) << 4 | (vg + 2) << 2 | (vb + 2);
          } else if (vg_r > -9 &&
              vg_r < 8 &&
              vg > -33 &&
              vg < 32 &&
              vg_b > -9 &&
              vg_b < 8) {
            bytes[index++] = IDTag.luma | (vg + 32);
            bytes[index++] = (vg_r + 8) << 4 | (vg_b + 8);
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
        /*final Color colorDiff = color - prevColor;
        final int diffRedGreen = colorDiff.red - colorDiff.green;
        final int diffBlueGreen = colorDiff.blue - colorDiff.green;

        if (colorDiff.alpha == 0) {
          if ((colorDiff.red >= -2 && colorDiff.red <= 1) &&
              (colorDiff.green >= -2 && colorDiff.green <= 1) &&
              (colorDiff.blue >= -2 && colorDiff.blue <= 1)) {
            bytes[index++] = (IDTag.diff |
                ((colorDiff.red + 2) << 4) |
                ((colorDiff.green + 2) << 2) |
                ((colorDiff.blue + 2) << 0));
          } else if ((colorDiff.green >= -32 && colorDiff.green <= 31) &&
              (diffRedGreen >= -8 && diffRedGreen <= 7) &&
              (diffBlueGreen >= -8 && diffBlueGreen <= 7)) {
            bytes[index++] = IDTag.luma | (colorDiff.green + 32);
            bytes[index++] = ((diffRedGreen + 8) << 4) | (diffBlueGreen + 8);
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
        }*/
      }
    }

    prevColor = color;
  }

  for (int byte in Uint8List(8)..[7] = 1) {
    bytes[index++] = byte;
  }

  return Uint8List.fromList(bytes.getRange(0, index).toList());
}

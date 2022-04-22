import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:dqoi/qoi.dart';
import 'package:image/image.dart';
import 'package:path/path.dart' as p;

import 'package:dqoi/decode.dart';
import 'package:dqoi/encode.dart';

enum Mode {
  encoding,
  decoding,
}

void main(List<String> inputArgs) async {
  late final ArgResults args;

  try {
    final ArgParser parser = ArgParser();

    parser.addOption(
      'filename',
      abbr: 'f',
      help:
          'Path to file (including extension) to encode/decode\nOutput files are created with the same path within a \'outputs/\' directory',
      allowedHelp: {
        '<filename>.qoi':
            'Decoded to .png (unless otherwise specified with --bin flag)',
        '<filename>.bin': 'Automatically encoded to .qoi',
        '<filename>.png': 'Automatically encoded to .qoi',
        '<filename>.*': 'Other formats are currently unsupported',
      },
      mandatory: true,
    );
    parser.addOption(
      'width',
      abbr: 'w',
      help: 'Image width in pixels\nOnly required when encoding .bin format',
    );
    parser.addOption(
      'height',
      abbr: 'h',
      help: 'Image height in pixels\nOnly required when encoding .bin format',
    );
    parser.addOption(
      'channels',
      help:
          'Number of image channels\nMust be either 3 (RGB) or 4 (RGBA)\nOnly used when encoding .bin format',
      defaultsTo: '4',
    );
    parser.addOption(
      'colorspace',
      help:
          'Number of colorspace\nMust be either 0 (sRGB with linear alpha) or 1 (all channels linear)\nOnly used when encoding',
      defaultsTo: '0',
    );
    parser.addFlag(
      'bin',
      help: 'When decoding, dump to .bin file instead of re-encoding to .png',
      negatable: false,
    );

    if (inputArgs.isEmpty ||
        inputArgs.map((e) => e.toLowerCase()).contains('--help')) {
      print(parser.usage);
      return;
    }

    args = parser.parse(inputArgs);
  } catch (e) {
    if (e is ArgParserException) {
      print(e.message);
    } else {
      print('Unknown Error: ' + e.toString());
    }

    return;
  }

  final String inputExtension = p.extension(args['filename']);
  final Mode mode = inputExtension == '.qoi' ? Mode.decoding : Mode.encoding;

  if (mode == Mode.encoding) {
    if (inputExtension == '.bin' &&
        (args['width'] == null || args['height'] == null)) {
      print(
          'You must input a width and height to encode an image from .bin format\nFor more assistance, run \'dqoi\' with no arguments');
      return;
    }
    if (inputExtension == '.bin' &&
        (args['channels'] != '3' && args['channels'] != '4')) {
      print(
          'You must input a valid channel number (3 or 4) to encode an image from .bin format\nFor more assistance, run \'dqoi\' with no arguments');
      return;
    }
    if (inputExtension == '.bin' &&
        (args['colorspace'] != '0' && args['colorspace'] != '1')) {
      print(
          'You must input a valid colorspace number (0 or 1) to encode an image from .bin format\nFor more assistance, run \'dqoi\' with no arguments');
      return;
    }
  }

  final File outputFile = File('outputs/' +
      p.withoutExtension(args['filename']) +
      (mode == Mode.encoding
          ? '.qoi'
          : args['bin']
              ? '.bin'
              : '.png'));

  await Directory('outputs/' + p.dirname(args['filename']))
      .create(recursive: true);

  final Uint8List file = await File(args['filename']).readAsBytes();

  late final Uint8List data;
  late final int imageWidth;
  late final int imageHeight;
  late final int channels;
  late final int colorspace;

  if (inputExtension == '.bin') {
    data = file;
    imageWidth = int.parse(args['width']);
    imageHeight = int.parse(args['height']);
    channels = int.parse(args['channels']);
    colorspace = int.parse(args['colorspace']);
  } else if (inputExtension == '.png') {
    final Image image = PngDecoder().decodeImage(file)!;
    data = image.getBytes();
    imageWidth = image.width;
    imageHeight = image.height;
    channels = image.numberOfChannels;
    colorspace = int.tryParse(args['colorspace']) ?? 0;
  } else if (inputExtension == '.qoi') {
    data = file;
  }

  late final Uint8List output;

  if (mode == Mode.encoding) {
    output = encode(
      data: data,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      channels: channels,
      colorspace: colorspace,
    );
  } else {
    final QOI decoded = decode(data: data);

    if (args['bin']) {
      output = decoded.bytes;
    } else {
      output = Uint8List.fromList(
        PngEncoder().encodeImage(
          Image.fromBytes(
            decoded.width,
            decoded.height,
            decoded.bytes,
          ),
        ),
      );
    }
  }

  await outputFile.writeAsBytes(output);
}

import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:image/image.dart';
import 'package:path/path.dart' as p;

import 'package:dqoi/dqoi.dart';

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
      aliases: ['input'],
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
      help: 'Image width in pixels\nRequired when encoding .bin format',
    );
    parser.addOption(
      'height',
      abbr: 'h',
      help: 'Image height in pixels\nRequired when encoding .bin format',
    );
    parser.addOption(
      'channels',
      abbr: 'c',
      help:
          'Number of image channels\nMust be either 3 (RGB) or 4 (RGBA)\nRequired when encoding .bin format; Overrides metadata when encoding .png format',
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
  final String outputExtension = mode == Mode.encoding
      ? '.qoi'
      : args['bin']
          ? '.bin'
          : '.png';

  final bool channelsInvalid =
      args['channels'] != '3' && args['channels'] != '4';
  final bool colorspaceInvalid =
      args['colorspace'] != '0' && args['colorspace'] != '1';

  if (mode == Mode.encoding && inputExtension == '.bin') {
    if (args['width'] == null || args['height'] == null) {
      print(
          'You must input a width and height to encode an image from .bin format\nFor more assistance, run \'dqoi\' with no arguments');
      return;
    }
    if (channelsInvalid) {
      print(
          'You must input a valid channel number (3 or 4) to encode an image from .bin format\nFor more assistance, run \'dqoi\' with no arguments');
      return;
    }
    if (colorspaceInvalid) {
      print(
          'You must input a valid colorspace number (0 or 1) to encode an image from .bin format\nFor more assistance, run \'dqoi\' with no arguments');
      return;
    }
  }

  if (channelsInvalid && args['channels'] != null) {
    print(
        'You must input a valid channel number (3 or 4) if you specify it\nFor more assistance, run \'dqoi\' with no arguments');
    return;
  }
  if (colorspaceInvalid) {
    print(
        'You must input a valid colorspace number (0 or 1) if you specify it\nFor more assistance, run \'dqoi\' with no arguments');
    return;
  }

  final Uint8List inputData = await File(args['filename']).readAsBytes();
  final File outputFile = File('outputs/' +
      p.withoutExtension(args['filename']) +
      (mode == Mode.encoding
          ? '.qoi'
          : args['bin']
              ? '.bin'
              : '.png'));

  late final Uint8List output;

  if (mode == Mode.encoding) {
    if (inputExtension == '.png') {
      output = QOI
          .fromPNG(
            inputData,
            overrideChannels: args['channels'] == null
                ? null
                : int.tryParse(args['channels']) == 3
                    ? Channels.rgb
                    : Channels.rgba,
            overrideColorspace: int.tryParse(args['colorspace']),
          )
          .toQOI();
    } else if (inputExtension == '.bin') {
      output = QOI
          .fromRaw(
            bytes: inputData,
            width: int.parse(args['width']),
            height: int.parse(args['height']),
            channels:
                int.parse(args['channels']) == 3 ? Channels.rgb : Channels.rgba,
            colorspace: int.tryParse(args['colorspace'])!,
          )
          .toQOI();
    }
  }

  /*final File outputFile = File('outputs/' +
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
    channels =
        int.tryParse(args['channels'] ?? 'null') ?? image.numberOfChannels;
    colorspace = int.tryParse(args['colorspace']) ?? 0;
  } else if (inputExtension == '.qoi') {
    data = file;
  }

  late final Uint8List output;

  if (mode == Mode.encoding) {
    output = QOI
        .fromRaw(
          bytes: data,
          width: imageWidth,
          height: imageHeight,
          channels: channels == 3 ? Channels.rgb : Channels.rgba,
          colorspace: colorspace,
        )
        .toQOI();
  } else {
    final QOI decoded = QOI.fromRaw(data: data);
    output = args['bin'] ? decoded.toRaw() : decoded.toRaw();
  }*/

  await outputFile.writeAsBytes(output);
}

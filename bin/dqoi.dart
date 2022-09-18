import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

import 'package:dqoi/dqoi_pure.dart';

void main(List<String> inputArgs) async {
  late final ArgResults args;

  try {
    final ArgParser parser = ArgParser();

    parser.addOption(
      'filename',
      abbr: 'f',
      aliases: ['input'],
      help:
          'Path to file (including extension) to encode/decode\nOutput files are created with the same relative path within a \'outputs/\' directory',
      allowedHelp: {
        '<filename>.qoi':
            'Decoded to .png (unless otherwise specified with --bin flag)',
        '<filename>.bin': 'Encoded to .qoi',
        '<filename>.png': 'Encoded to .qoi',
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
          'Number of image channels\nMust be either 3 (RGB) or 4 (RGBA)\nRequired when encoding .bin format\nOverrides metadata when encoding .png format',
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
      print('Unknown Error: $e');
    }

    return;
  }

  final String inputExtension = p.extension(args['filename']);
  final String outputExtension = inputExtension != '.qoi'
      ? '.qoi'
      : args['bin']
          ? '.bin'
          : '.png';

  final bool channelsInvalid =
      args['channels'] != '3' && args['channels'] != '4';
  final bool colorspaceInvalid =
      args['colorspace'] != '0' && args['colorspace'] != '1';

  const String assistanceMessage =
      '\nFor more assistance, run \'dqoi\' with no arguments';

  if (inputExtension != '.qoi' && inputExtension == '.bin') {
    if (args['width'] == null || args['height'] == null) {
      print(
          'You must input a width and height to encode an image from .bin format$assistanceMessage');
      return;
    }
    if (channelsInvalid) {
      print(
          'You must input a valid channel number (3 or 4) to encode an image from .bin format$assistanceMessage');
      return;
    }
    if (colorspaceInvalid) {
      print(
          'You must input a valid colorspace number (0 or 1) to encode an image from .bin format$assistanceMessage');
      return;
    }
  }

  if (channelsInvalid && args['channels'] != null) {
    print(
        'You must input a valid channel number (3 or 4) if you specify it$assistanceMessage');
    return;
  }
  if (colorspaceInvalid) {
    print(
        'You must input a valid colorspace number (0 or 1) if you specify it$assistanceMessage');
    return;
  }

  final Uint8List inputData = await File(args['filename']).readAsBytes();
  final File outputFile = File(
    p.join(
      'outputs/',
      p.withoutExtension(args['filename']) + outputExtension,
    ),
  );

  await Directory('outputs/${p.dirname(args['filename'])}')
      .create(recursive: true);

  late final Uint8List output;

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
  } else if (inputExtension == '.qoi') {
    final QOI qoi = QOI.fromQOI(inputData);
    output = args['bin'] ? qoi.toRaw() : qoi.toPNG();
  }

  await outputFile.writeAsBytes(output);
}

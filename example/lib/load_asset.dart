import 'dart:async' show Future;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

Future<Uint8List> loadAsset(String path) async =>
    (await rootBundle.load(path)).buffer.asUint8List();

import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:dqoi/dqoi.dart';

import 'load_asset.dart';

void main() {
  runApp(const DemoAppContainer());
}

class DemoAppContainer extends StatelessWidget {
  const DemoAppContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dqoi Demo Application',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('dqoi Demo Application'),
      ),
      body: Center(
        child: FutureBuilder<List<Uint8List>>(
          future: Future.wait([
            loadAsset('assets/images/kodim23.qoi'),
            loadAsset('assets/images/dice.qoi'),
            loadAsset('assets/images/testcard_rgba.qoi'),
          ]),
          builder: (context, assets) {
            if (!assets.hasData) {
              return const CircularProgressIndicator();
            }

            return ListView.builder(
              itemBuilder: (context, i) => Container(
                child: QOI.fromQOI(assets.data![i]).toImageWidget(),
                color: Colors.black.withOpacity(0.5),
              ),
              itemCount: assets.data!.length,
            );
          },
        ),
      ),
    );
  }
}

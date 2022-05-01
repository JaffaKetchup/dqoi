# dqoi ('dart_[qoi](https://github.com/phoboslab/qoi)')

[![Pub.dev](https://img.shields.io/pub/v/dqoi.svg?label=Latest+Version)](https://pub.dev/packages/dqoi) [![points](https://badges.bar/dqoi/pub%20points)](https://pub.dev/packages/dqoi/score) [![likes](https://badges.bar/dqoi/likes)](https://pub.dev/packages/dqoi/score)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
[![stars](https://badgen.net/github/stars/JaffaKetchup/dqoi?label=stars&color=green&icon=github)](https://github.com/JaffaKetchup/dqoi/stargazers) [![Open Issues](https://badgen.net/github/open-issues/JaffaKetchup/dqoi?label=Open+Issues&color=green)](https://GitHub.com/JaffaKetchup/dqoi/issues) [![Open PRs](https://badgen.net/github/open-prs/JaffaKetchup/dqoi?label=Open+PRs&color=green)](https://GitHub.com/JaffaKetchup/dqoi/pulls)

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/N4N151INN)

A Dart implementation of the "[Quite OK Image Format](https://qoiformat.org/)", with a command line interface for console use and a library for use in applications.

Based off of [the official C implementation](https://github.com/phoboslab/qoi/blob/master/qoi.h) and other implementations.

## Command Line Interface

An easy to use CLI is provided to get working with QOI!

### Setup/Installation

#### With Dart (recommended)

If you have Dart installed, you can use the CLI on any operating system!  
Just run the command `dart pub global activate dqoi` (with administrator/root privileges), then you can use the command `dqoi` from anywhere on your system!

#### Without Dart

##### Windows

If you don't have Dart installed, you can use the pre-compiled executable for Windows.

You can get the .exe by:

* Cloning this repository with Git, then going to 'bin/dqoi.exe'
* Downloading just the executable from the GitHub repo browser: <https://github.com/JaffaKetchup/dqoi/blob/main/bin/dqoi.exe>.

Note that Windows Defender or your anti-virus may flag the executable malicious or unwanted, as it is not signed. You'll need to make an exception for the program if this happens.

[Add this file to your system path](https://www.computerhope.com/issues/ch000549.htm#windows10), then you can use the command `dqoi` from anywhere on your system!

##### Other Operating Systems

Unfortunately, I cannot provide executables for other operating systems at this time, as I do not have the appropriate devices.

The best way to get the executable for your OS is to install Dart, then follow the instructions above for setup with Dart.

### CLI Usage

You can list the available options by just running `dqoi` with no arguments or with '--help'. The program will return helpful messages in the event of an error, which should be self-explanatory.

On Windows, `dqoi-test.bat` is provided to test the program, comparing the output files with official samples. This is not necessary to run, but may help to verify that the program is working correctly. In the event of a test failure, there will be differences shown in the console.

## Application Library

### Installation

There are two included libraries, each of which are very similar:

* Flutter applications should use the standard `package:dqoi/dqoi.dart` import.
* Non-Flutter programs should use the `package:dqoi/dqoi_pure.dart` import, which excludes some useful Flutter-only methods.

Note that both export the `Channels` enum from the 'image' package, but you can disable this by using `hide Channels` on the end of the import statement.  
Also note that neither uses 'dart:io',  so both are fully compatible with Web applications.

When this documentation refers to the singular "library", it means either library.

### Library Usage

The `QOI` class provides access to conversions between binary, PNG, and QOI formats.

When extended by `FlutterQOIExts`, it also provides an easy way to render/paint a QOI image in a Flutter app efficiently.

You can find the full API documentation at <https://pub.dev/documentation/dqoi/latest/dqoi/dqoi-library.html>.

### Examples

You can build and install the example application, found in the 'example/' directory. However, below are some quick useful snippets to get you started.

* Convert a PNG file to QOI, and then write to another file:

    ``` dart
    await outputFile.writeAsBytes(QOI.fromPNG(await inputFile.readAsBytes()).toQOI());
    ```

* Render/paint a QOI file to a widget:

    ```dart
    return QOI.fromQOI(await inputFile.readAsBytes()).toImageWidget(loadingWidget: loadingWidget);
    ```

* Render/paint a QOI asset (bundled) to a widget:

    ```dart
    Future<Uint8List> loadAsset(String path) async => (await rootBundle.load(path)).buffer.asUint8List();
    return QOI.fromQOI(loadAsset('assetPath.qoi')).toImageWidget(loadingWidget: loadingWidget);
    ```

## FAQ

* How do I pronounce the name of this library?  
  _It's up to you, but I like "decoy" best._
* Is this a good implementation?  
  _The outputted QOI files perfectly match the official C implementation's outputs. The re-encoded PNGs don't always match byte-for-byte, but the pixels are always correct_
* Why wasn't this ported to Dart sooner?  
  _I'm not sure either. You can see all the other available ports on the [official README](https://github.com/phoboslab/qoi#implementations--bindings-of-qoi)._

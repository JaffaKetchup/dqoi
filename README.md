# dqoi ('dart_[qoi](https://github.com/phoboslab/qoi)')

[![Pub.dev](https://img.shields.io/pub/v/dqoi.svg?label=Latest+Version)](https://pub.dev/packages/dqoi) [![points](https://badges.bar/dqoi/pub%20points)](https://pub.dev/packages/dqoi/score) [![likes](https://badges.bar/dqoi/likes)](https://pub.dev/packages/dqoi/score)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
[![stars](https://badgen.net/github/stars/JaffaKetchup/dqoi?label=stars&color=green&icon=github)](https://github.com/JaffaKetchup/dqoi/stargazers) [![Open Issues](https://badgen.net/github/open-issues/JaffaKetchup/dqoi?label=Open+Issues&color=green)](https://GitHub.com/JaffaKetchup/dqoi/issues) [![Open PRs](https://badgen.net/github/open-prs/JaffaKetchup/dqoi?label=Open+PRs&color=green)](https://GitHub.com/JaffaKetchup/dqoi/pulls)

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/N4N151INN)

A Dart implementation of the "[Quite OK Image Format](https://qoiformat.org/)", with a command line interface for console use and a library for use in applications.

Based off of [the official C implementation](https://github.com/phoboslab/qoi/blob/master/qoi.h) and other implementations.

## Command Line Interface

Currently only Windows is supported for the CLI, as I cannot test on other operating systems. When I release the full version, there should be at least a Linux CLI.

### Setup

Very little setup is required. If you want to clone the source from GitHub you can. Then you can build and start using the 'bin/dqoi.exe' executable on Windows.  
Alternatively, you can just install the package as normal, as use `dqoi` from the command line once activated. See the [installation instructions on pub.dev](https://pub.dev/packages/dqoi/install) for more information.

### CLI Usage

You can list the available options by just running the executable with no arguments or with '--help'.  
`dqoi-test.bat` is designed to test the CLI on Windows, by comparing the files with official samples.

## Application Library

### Installation

There are two included libraries, each of which are very similar. Flutter applications should use the standard `package:dqoi/dqoi.dart` import. The other `dqoi_pure.dart` file excludes some useful extensions.  
When this documentation refers to the singular "library", it means either library.

### Library Usage

The `QOI` class provides conversions between binary, PNG, and QOI formats. When extended by `FlutterQOIExts`, it also provides an easy way to render a QOI image in a Flutter app efficiently.  
Note that neither library uses 'dart:io', so both are fully compatible with Web construction.

### Examples

You can build and install the example application, found in the 'example/' directory. However, below are some quick useful snippets to get you started.

Here's a way to convert PNG to QOI:

``` dart
await outputFile.writeAsBytes(QOI.fromPNG(await inputFile.readAsBytes()).toQOI());
```

Here's the way to render a QOI image without converting to any other formats first:

```dart
QOI.fromQOI(await inputFile.readAsBytes()).toImageWidget(loadingWidget: loadingWidget);
```

## FAQ

- How do I pronounce the name of this library?  
  _It's up to you, but I like "decoy" best._
- Is this a good implementation?  
  _The outputted QOI files perfectly match the official C implementation's outputs. The re-encoded PNGs don't always match byte-for-byte, but the pixels are always correct_
- Why wasn't this ported to Dart sooner?  
  _I'm not sure either. You can see all the other available ports on the [official README](https://github.com/phoboslab/qoi#implementations--bindings-of-qoi)._

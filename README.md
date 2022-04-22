# dqoi ('dart_[qoi](https://github.com/phoboslab/qoi)')

[![Pub.dev](https://img.shields.io/pub/v/dqoi.svg?label=Latest+Version)](https://pub.dev/packages/dqoi) [![points](https://badges.bar/dqoi/pub%20points)](https://pub.dev/packages/dqoi/score) [![likes](https://badges.bar/dqoi/likes)](https://pub.dev/packages/dqoi/score)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
[![stars](https://badgen.net/github/stars/JaffaKetchup/dqoi?label=stars&color=green&icon=github)](https://github.com/JaffaKetchup/dqoi/stargazers) [![Open Issues](https://badgen.net/github/open-issues/JaffaKetchup/dqoi?label=Open+Issues&color=green)](https://GitHub.com/JaffaKetchup/dqoi/issues) [![Open PRs](https://badgen.net/github/open-prs/JaffaKetchup/dqoi?label=Open+PRs&color=green)](https://GitHub.com/JaffaKetchup/dqoi/pulls)

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/N4N151INN)

**Currently in pre-release whilst I finalise the API & ensure the encoder/decoder conforms to the standard and is efficient**

A Dart implementation of the "[Quite OK Image Format](https://qoiformat.org/)", with a command line interface for console use and a library for use in applications.

Based off of [the official C implementation](https://github.com/phoboslab/qoi/blob/master/qoi.h) and [LowLevelJavaScript's implementation](https://github.com/LowLevelJavaScript/QOI).

## Command Line Interface

Currently only Windows is supported for the CLI, as I cannot test on other operating systems. When I release the full version, there should be at least a Linux CLI.

### Setup

Very little setup is required. If you want to clone the source from GitHub you can. Then you can build and start using the 'bin/dqoi.exe' executable on Windows.  
Alternatively, you can just install the package as normal, as use `dqoi` from the command line once activated. See the [installation instructions on pub.dev](https://pub.dev/packages/dqoi/install) for more information.

### Usage

You can list the available options by just running the executable with no arguments or with '--help'.  
`dqoi-test.bat` is designed to test the CLI on Windows, by comparing the files with official samples.

## Application Library

**Currently in development, please watch for more developments!**

## FAQ

- How do I pronounce the name of this library?  
  _It's up to you, but I like "decoy" best._
- Why wasn't this ported to Dart sooner?  
  _I'm not sure either. You can see all the other available ports on the [official README](https://github.com/phoboslab/qoi#implementations--bindings-of-qoi)._
- Is this a good implementation?  
  _It's a decent one, and it's currently the only one. I will work on making it perform better, maybe using inspiration for other ports._

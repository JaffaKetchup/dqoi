import 'dart:typed_data';

const int headerSize = 14;
final Uint8List endMarker = Uint8List(8)
  ..[8 - 1] = 1; // [0, 0, 0, 0, 0, 0, 0, 1];

const int opRUN = 0xc0;
const int opINDEX = 0x00;
const int opDIFF = 0x40;
const int opLUMA = 0x80;
const int opRGB = 0xfe;
const int opRGBA = 0xff;

const int runLength = 0x3f;
const int index = 0x3f;
const int chunkMask = 0xc0;

const int diffRed = 0x30;
const int diffGreen = 0x0c;
const int diffBlue = 0x03;

const int lumaGreen = 0x3f;
const int lumaDiffRG = 0xf0;
const int lumaDiffBG = 0x0f;

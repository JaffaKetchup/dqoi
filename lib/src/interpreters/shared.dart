/// Represents a RGBA color pixel
class Color {
  final int red;
  final int green;
  final int blue;
  final int alpha;

  /// Create a RGBA color pixel (custom)
  Color(this.red, this.green, this.blue, this.alpha);

  /// Create a RGBA color pixel (white transparent)
  static Color get zero => Color(0, 0, 0, 0);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Color &&
        other.red == red &&
        other.green == green &&
        other.blue == blue &&
        other.alpha == alpha;
  }

  @override
  int get hashCode => (red * 3 + green * 5 + blue * 7 + alpha * 11) % 64;
}

/// Represents a method identification byte found at the start of each compressed block
class IDTag {
  static const int rgb = 0xfe;
  static const int rgba = 0xff;
  static const int run = 0xc0;
  static const int index = 0x00;
  static const int diff = 0x40;
  static const int luma = 0x80;
}

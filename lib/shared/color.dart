class Color {
  final int red;
  final int green;
  final int blue;
  final int alpha;

  Color(this.red, this.green, this.blue, this.alpha);

  static Color get zero => Color(0, 0, 0, 0);

  Color operator -(Color o) => Color(
        red - o.red,
        green - o.green,
        blue - o.blue,
        alpha - o.alpha,
      );

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

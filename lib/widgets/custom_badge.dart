import 'package:flutter/material.dart';

class CustomBadge extends StatelessWidget {
  final String text;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double fontSize;
  final double? width;
  final double? height;
  final TextAlign textAlign;
  final String? semanticsLabel;

  const CustomBadge({
    super.key,
    required this.text,
    required this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.borderRadius = 8.0,
    this.fontSize = 14.0,
    this.width,
    this.height,
    this.textAlign = TextAlign.center,
    this.semanticsLabel,
  });

  const CustomBadge.small({
    super.key,
    required this.text,
    required this.color,
  })  : padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        borderRadius = 10.0,
        fontSize = 14.0,
        width = null,
        height = 18.0,
        textAlign = TextAlign.center,
        semanticsLabel = null;

  @override
  Widget build(BuildContext context) {
    final textColor = _brighten(color, 0.5);

    Widget child = Container(
      padding: padding,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textAlign: textAlign,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );

    if (semanticsLabel != null) {
      child = Semantics(
        label: semanticsLabel,
        child: child,
      );
    }

    return child;
  }
}

Color _brighten(Color color, [double amount = 0.2]) {
  final hsl = HSLColor.fromColor(color);
  final hslBright = hsl.withLightness(
    (hsl.lightness + amount).clamp(0.0, 1.0),
  );
  return hslBright.toColor();
}

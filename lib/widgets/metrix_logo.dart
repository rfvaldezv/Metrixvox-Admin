import 'package:flutter/material.dart';

/// Logotipo vectorial de MetrixVox.
class MetrixLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? forceColor;
  final Color? textColor;

  const MetrixLogo({
    super.key,
    this.size = 48,
    this.showText = true,
    this.forceColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BarsIcon(size: size, forceColor: forceColor),
        if (showText) ...[
          SizedBox(width: size * 0.25),
          Text(
            'MetrixVox',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: size * 0.55,
              fontWeight: FontWeight.w700,
              color: textColor ?? const Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _BarsIcon extends StatelessWidget {
  final double size;
  final Color? forceColor;

  const _BarsIcon({required this.size, this.forceColor});

  @override
  Widget build(BuildContext context) {
    final colors = forceColor != null
        ? [forceColor!, forceColor!, forceColor!]
        : const [
            Color(0xFF4F46E5),
            Color(0xFF6366F1),
            Color(0xFF7C3AED),
          ];

    final barWidth = size * 0.2;
    final gap = size * 0.1;
    final totalWidth = barWidth * 3 + gap * 2;

    return SizedBox(
      width: totalWidth,
      height: size,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Bar(width: barWidth, heightRatio: 0.5, color: colors[0]),
          SizedBox(width: gap),
          _Bar(width: barWidth, heightRatio: 0.75, color: colors[1]),
          SizedBox(width: gap),
          _Bar(width: barWidth, heightRatio: 1.0, color: colors[2]),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double width;
  final double heightRatio;
  final Color color;

  const _Bar({
    required this.width,
    required this.heightRatio,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: heightRatio,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(width * 0.3),
        ),
      ),
    );
  }
}

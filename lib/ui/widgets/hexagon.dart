import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// A flat-top hexagon shape used throughout the hive UI.
class HexagonBorder extends ShapeBorder {
  final bool pointy;
  const HexagonBorder({this.pointy = false});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  Path _hexPath(Rect rect) {
    final path = Path();
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final w = rect.width / 2;
    final h = rect.height / 2;
    for (var i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i + (pointy ? math.pi / 2 : 0);
      final x = cx + w * math.cos(angle);
      final y = cy + h * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => _hexPath(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => _hexPath(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}

/// A filled hexagon with optional border and centered child.
class HexCell extends StatelessWidget {
  final double size;
  final Color color;
  final Color? borderColor;
  final double borderWidth;
  final Widget? child;
  final bool pointy;

  const HexCell({
    super.key,
    required this.size,
    required this.color,
    this.borderColor,
    this.borderWidth = 2,
    this.child,
    this.pointy = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HexPainter(
        color: color,
        borderColor: borderColor,
        borderWidth: borderWidth,
        pointy: pointy,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(child: child),
      ),
    );
  }
}

class _HexPainter extends CustomPainter {
  final Color color;
  final Color? borderColor;
  final double borderWidth;
  final bool pointy;

  _HexPainter({
    required this.color,
    required this.borderColor,
    required this.borderWidth,
    required this.pointy,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = const HexagonBorder().getOuterPath(rect);
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color, Color.alphaBlend(Colors.black26, color)],
      ).createShader(rect);
    canvas.drawPath(path, fill);
    if (borderColor != null) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..color = borderColor!,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HexPainter old) =>
      old.color != color || old.borderColor != borderColor;
}

/// A hex-styled tappable button.
class HexButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final IconData? icon;

  const HexButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = HiveColors.amber,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: HiveColors.background),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: HiveColors.background,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

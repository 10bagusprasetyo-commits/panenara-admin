// lib/features/admin_web/shared/presentation/widgets/panenara_logo.dart
// SVG logo bulir padi — diekstrak dari HTML desain

import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

class PanenaraLogo extends StatelessWidget {
  const PanenaraLogo({
    super.key,
    this.width = 28,
    this.height = 42,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final grainColor = isDark ? const Color(0xFFe4efe3) : const Color(0xFF2f6b3f);
    const amberColor = Color(0xFFe8a33d);

    return CustomPaint(
      size: Size(width, height),
      painter: _PanenaraLogoPainter(
        grainColor: grainColor,
        amberColor: amberColor,
      ),
    );
  }
}

class _PanenaraLogoPainter extends CustomPainter {
  _PanenaraLogoPainter({
    required this.grainColor,
    required this.amberColor,
  });

  final Color grainColor;
  final Color amberColor;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 48;
    final sy = size.height / 72;

    final grainPaint = Paint()..color = grainColor;
    final amberPaint = Paint()..color = amberColor;

    // Draw ellipses (grain hulls) — 6 pairs
    _drawGrainPair(canvas, 15.5, 25, sx, sy, grainPaint);
    _drawGrainPair(canvas, 15.5, 40, sx, sy, grainPaint);
    _drawGrainPair(canvas, 15.5, 55, sx, sy, grainPaint);

    // Stem
    final stemRect = RRect.fromLTRBR(
      22.5 * sx, 14 * sy, (22.5 + 3) * sx, (14 + 57) * sy,
      const Radius.circular(1.5),
    );
    canvas.drawRRect(stemRect, grainPaint);

    // Top grain (amber)
    final amberOval = Rect.fromCenter(
      center: Offset(24 * sx, 10 * sy),
      width: 10 * sx,
      height: 19 * sy,
    );
    canvas.drawOval(amberOval, amberPaint);
  }

  void _drawGrainPair(
      Canvas canvas, double cx, double cy, double sx, double sy, Paint paint) {
    // Left ellipse (rotated -35 deg)
    _drawRotatedEllipse(canvas, (48 - cx) * sx, cy * sy, 6 * sx, 10 * sy,
        -35 * 3.14159 / 180, paint);
    // Right ellipse (rotated +35 deg)
    _drawRotatedEllipse(canvas, cx * sx, cy * sy, 6 * sx, 10 * sy,
        35 * 3.14159 / 180, paint);
  }

  void _drawRotatedEllipse(Canvas canvas, double cx, double cy, double rx,
      double ry, double angle, Paint paint) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PanenaraLogoPainter old) =>
      old.grainColor != grainColor || old.amberColor != amberColor;
}

/// Brand wordmark: "Pane[nara]" with accent color on "nara"
class PanenBrand extends StatelessWidget {
  const PanenBrand({
    super.key,
    required this.subtitle,
    this.onDark = false,
  });

  final String subtitle;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final baseColor = onDark ? const Color(0xFFe6f0e4) : AdminColors.g9;
    final accentColor = onDark ? const Color(0xFFe4efe3) : const Color(0xFF2f6b3f);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: -0.2,
              color: baseColor,
            ),
            children: [
              const TextSpan(text: 'Pane'),
              TextSpan(
                text: 'nara',
                style: TextStyle(color: accentColor),
              ),
            ],
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: baseColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}


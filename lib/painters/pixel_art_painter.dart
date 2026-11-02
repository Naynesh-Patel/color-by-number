import 'package:flutter/material.dart';
import '../models/artwork.dart';

class PixelArtPainter extends CustomPainter {
  final Artwork artwork;
  final int activeColorId;
  final double cellSize;
  final double highlightPulse; // 0.0 to 1.0 for animation
  final Set<String> hintCells; // Highlighted by hint booster

  PixelArtPainter({
    required this.artwork,
    required this.activeColorId,
    required this.cellSize,
    this.highlightPulse = 0.0,
    this.hintCells = const {},
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = artwork.width;
    final height = artwork.height;

    final Paint borderPaint = Paint()
      ..color = const Color(0xFFD6D6D6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final Paint emptyPaint = Paint()
      ..color = const Color(0xFFF2F2F7)
      ..style = PaintingStyle.fill;

    final Paint highlightFillPaint = Paint()
      ..color = const Color(0xFFFFF176).withValues(alpha: 0.35 + 0.25 * highlightPulse)
      ..style = PaintingStyle.fill;

    final Paint activeBorderPaint = Paint()
      ..color = const Color(0xFFFFB300)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Paint hintGlowPaint = Paint()
      ..color = const Color(0xFFFF1744)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Cache text painters for numbers 1..20
    final Map<int, TextPainter> textPainters = {};
    for (final c in artwork.colors) {
      final textSpan = TextSpan(
        text: '${c.id}',
        style: TextStyle(
          color: const Color(0xFF616161),
          fontSize: cellSize * 0.42,
          fontWeight: FontWeight.w700,
        ),
      );
      final tp = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainters[c.id] = tp;
    }

    final Map<int, Color> colorMap = {
      for (var c in artwork.colors) c.id: c.color,
    };

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final colorId = artwork.grid[y][x];
        if (colorId == 0) continue; // Transparent

        final rect = Rect.fromLTWH(
          x * cellSize,
          y * cellSize,
          cellSize,
          cellSize,
        );

        final isColored = artwork.coloredGrid[y][x];
        final isSelectedColor = (colorId == activeColorId);
        final cellKey = '$x,$y';
        final isHinted = hintCells.contains(cellKey);

        if (isColored) {
          // Fill with true color
          final color = colorMap[colorId] ?? Colors.grey;
          final fillPaint = Paint()..color = color;
          canvas.drawRect(rect, fillPaint);
        } else {
          // Uncolored cell
          if (isSelectedColor) {
            // Highlighted cell for active color!
            canvas.drawRect(rect, emptyPaint);
            canvas.drawRect(rect, highlightFillPaint);
            canvas.drawRect(rect, activeBorderPaint);
          } else {
            canvas.drawRect(rect, emptyPaint);
            canvas.drawRect(rect, borderPaint);
          }

          // Draw number text if cell size is big enough
          if (cellSize >= 10) {
            final tp = textPainters[colorId];
            if (tp != null) {
              final offset = Offset(
                rect.left + (cellSize - tp.width) / 2,
                rect.top + (cellSize - tp.height) / 2,
              );
              tp.paint(canvas, offset);
            }
          }
        }

        // Draw hint glow if active
        if (isHinted && !isColored) {
          canvas.drawRect(rect.inflate(1), hintGlowPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant PixelArtPainter oldDelegate) {
    return true; // Simple & smooth 60fps update
  }
}

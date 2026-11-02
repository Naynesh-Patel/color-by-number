import 'package:flutter/material.dart';
import '../models/artwork.dart';

class ArtworkThumbnailPainter extends CustomPainter {
  final Artwork artwork;
  final bool showFullColor;

  ArtworkThumbnailPainter({
    required this.artwork,
    this.showFullColor = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / artwork.width;
    final cellH = size.height / artwork.height;
    final Map<int, Color> colorMap = {
      for (var c in artwork.colors) c.id: c.color,
    };

    final Paint emptyPaint = Paint()..color = const Color(0xFFEEEEEE);
    final Paint borderPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int y = 0; y < artwork.height; y++) {
      for (int x = 0; x < artwork.width; x++) {
        final colorId = artwork.grid[y][x];
        if (colorId == 0) continue;

        final rect = Rect.fromLTWH(x * cellW, y * cellH, cellW, cellH);
        final isColored = artwork.coloredGrid[y][x] || showFullColor;

        if (isColored) {
          final color = colorMap[colorId] ?? Colors.grey;
          canvas.drawRect(rect, Paint()..color = color);
        } else {
          canvas.drawRect(rect, emptyPaint);
          canvas.drawRect(rect, borderPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant ArtworkThumbnailPainter oldDelegate) {
    return oldDelegate.artwork != artwork ||
        oldDelegate.showFullColor != showFullColor;
  }
}


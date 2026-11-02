import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../models/artwork.dart';

class ImageConverterService {
  /// Converts raw image bytes into a playable Color by Number [Artwork],
  /// strictly preserving the original image's aspect ratio!
  static Future<Artwork> convertImageToArtwork({
    required Uint8List bytes,
    required String title,
    int targetWidth = 48,
    int colorCount = 16,
  }) async {
    // 1. Decode original image
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Failed to decode image');
    }

    // 2. Calculate proportional height to keep true aspect ratio!
    final srcW = decoded.width;
    final srcH = decoded.height;
    final aspectRatio = srcW / srcH;

    final width = targetWidth;
    final height = (targetWidth / aspectRatio).round().clamp(16, 120);

    // 3. High quality resize maintaining proportions
    final resized = img.copyResize(
      decoded,
      width: width,
      height: height,
      interpolation: img.Interpolation.cubic,
    );

    // 4. Collect non-transparent pixels
    final List<List<int>> rgbPixels = [];
    final List<bool> isOpaque = List.filled(width * height, false);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = resized.getPixel(x, y);
        final a = pixel.a.toInt();
        final idx = y * width + x;

        if (a > 30) {
          final r = pixel.r.toInt();
          final g = pixel.g.toInt();
          final b = pixel.b.toInt();

          isOpaque[idx] = true;
          rgbPixels.add([r, g, b]);
        }
      }
    }

    if (rgbPixels.isEmpty) {
      throw Exception('Image appears to be empty or completely transparent');
    }

    // 5. Extract vibrant palette using K-Means Clustering
    final actualK = min(colorCount, rgbPixels.length);
    final palette = _kMeansQuantize(rgbPixels, actualK);

    // Sort palette by luminosity/hue so colors look organized in the bottom bar
    palette.sort((a, b) {
      final lumA = 0.299 * a[0] + 0.587 * a[1] + 0.114 * a[2];
      final lumB = 0.299 * b[0] + 0.587 * b[1] + 0.114 * b[2];
      return lumA.compareTo(lumB);
    });

    final List<PixelColor> pixelColors = [];
    for (int i = 0; i < palette.length; i++) {
      final rgb = palette[i];
      pixelColors.add(
        PixelColor(
          id: i + 1,
          color: Color.fromARGB(255, rgb[0], rgb[1], rgb[2]),
          name: 'Color ${i + 1}',
        ),
      );
    }

    // 6. Map each pixel to closest palette color
    final List<List<int>> grid = List.generate(
      height,
      (_) => List.generate(width, (_) => 0),
    );

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final idx = y * width + x;
        if (!isOpaque[idx]) {
          grid[y][x] = 0; // Transparent background
          continue;
        }

        final pixel = resized.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        final bestColorId = _findClosestPaletteIndex(r, g, b, palette) + 1;
        grid[y][x] = bestColorId;
      }
    }

    // Initial coloredGrid: only transparent (0) cells are marked true, everything else false!
    final coloredGrid = List.generate(
      height,
      (y) => List.generate(width, (x) => grid[y][x] == 0),
    );

    return Artwork(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title.isEmpty ? 'My Photo Art' : title,
      category: 'Custom',
      width: width,
      height: height,
      colors: pixelColors,
      grid: grid,
      coloredGrid: coloredGrid,
      isCustom: true,
    );
  }

  /// K-Means color quantization algorithm
  static List<List<int>> _kMeansQuantize(List<List<int>> pixels, int k) {
    if (pixels.length <= k) {
      return pixels;
    }

    final random = Random(42);
    final List<List<int>> centroids = [];
    final Set<int> chosenIndices = {};

    while (centroids.length < k && chosenIndices.length < pixels.length) {
      final index = random.nextInt(pixels.length);
      if (!chosenIndices.contains(index)) {
        chosenIndices.add(index);
        centroids.add(List<int>.from(pixels[index]));
      }
    }

    const maxIterations = 10;
    for (int iter = 0; iter < maxIterations; iter++) {
      final List<List<List<int>>> clusters = List.generate(k, (_) => []);

      for (final p in pixels) {
        final cIndex = _findClosestPaletteIndex(p[0], p[1], p[2], centroids);
        clusters[cIndex].add(p);
      }

      bool changed = false;
      for (int i = 0; i < k; i++) {
        if (clusters[i].isEmpty) continue;

        int sumR = 0, sumG = 0, sumB = 0;
        for (final p in clusters[i]) {
          sumR += p[0];
          sumG += p[1];
          sumB += p[2];
        }

        final newR = (sumR / clusters[i].length).round();
        final newG = (sumG / clusters[i].length).round();
        final newB = (sumB / clusters[i].length).round();

        if (newR != centroids[i][0] ||
            newG != centroids[i][1] ||
            newB != centroids[i][2]) {
          changed = true;
          centroids[i] = [newR, newG, newB];
        }
      }

      if (!changed) break;
    }

    return centroids;
  }

  static int _findClosestPaletteIndex(
    int r,
    int g,
    int b,
    List<List<int>> palette,
  ) {
    int bestIdx = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < palette.length; i++) {
      final pr = palette[i][0];
      final pg = palette[i][1];
      final pb = palette[i][2];

      final dr = r - pr;
      final dg = g - pg;
      final db = b - pb;
      // Perceptually weighted color distance (human eye is most sensitive to green)
      final dist = (dr * dr * 0.299 + dg * dg * 0.587 + db * db * 0.114);

      if (dist < minDistance) {
        minDistance = dist;
        bestIdx = i;
      }
    }

    return bestIdx;
  }
}

import 'package:flutter/material.dart';

class PixelColor {
  final int id; // 1-based index (1, 2, 3...)
  final Color color;
  final String name;

  const PixelColor({
    required this.id,
    required this.color,
    this.name = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'color': color.toARGB32(),
    'name': name,
  };

  factory PixelColor.fromJson(Map<String, dynamic> json) {
    return PixelColor(
      id: json['id'] as int,
      color: Color(json['color'] as int),
      name: json['name'] as String? ?? '',
    );
  }
}

class Artwork {
  final String id;
  final String title;
  final String category;
  final int width;
  final int height;
  final List<PixelColor> colors;
  final List<List<int>> grid; // 0 = empty/transparent, 1..N = color id
  final List<List<bool>> coloredGrid;
  final bool isCustom;

  Artwork({
    required this.id,
    required this.title,
    required this.category,
    required this.width,
    required this.height,
    required this.colors,
    required this.grid,
    List<List<bool>>? coloredGrid,
    this.isCustom = false,
  }) : coloredGrid = coloredGrid ??
            List.generate(
              height,
              (y) => List.generate(
                width,
                (x) => grid[y][x] == 0, // Auto-mark transparent as done
              ),
            );

  int get totalPaintablePixels {
    int count = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (grid[y][x] > 0) {
          count++;
        }
      }
    }
    return count;
  }

  int get coloredPixelsCount {
    int count = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (grid[y][x] > 0 && coloredGrid[y][x]) {
          count++;
        }
      }
    }
    return count;
  }

  double get progress {
    final total = totalPaintablePixels;
    if (total == 0) return 1.0;
    return coloredPixelsCount / total;
  }

  bool get isCompleted => coloredPixelsCount >= totalPaintablePixels;

  int getRemainingCountForColor(int colorId) {
    int remaining = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (grid[y][x] == colorId && !coloredGrid[y][x]) {
          remaining++;
        }
      }
    }
    return remaining;
  }

  int getTotalCountForColor(int colorId) {
    int count = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (grid[y][x] == colorId) {
          count++;
        }
      }
    }
    return count;
  }

  bool isColorCompleted(int colorId) {
    return getRemainingCountForColor(colorId) == 0;
  }

  void resetProgress() {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        coloredGrid[y][x] = grid[y][x] == 0;
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'width': width,
      'height': height,
      'colors': colors.map((c) => c.toJson()).toList(),
      'grid': grid,
      'coloredGrid': coloredGrid,
      'isCustom': isCustom,
    };
  }

  factory Artwork.fromJson(Map<String, dynamic> json) {
    final width = json['width'] as int;
    final height = json['height'] as int;
    final gridRaw = (json['grid'] as List)
        .map((row) => (row as List).map((c) => c as int).toList())
        .toList();
    final coloredRaw = (json['coloredGrid'] as List)
        .map((row) => (row as List).map((c) => c as bool).toList())
        .toList();
    final colorsRaw = (json['colors'] as List)
        .map((c) => PixelColor.fromJson(c as Map<String, dynamic>))
        .toList();

    return Artwork(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      width: width,
      height: height,
      colors: colorsRaw,
      grid: gridRaw,
      coloredGrid: coloredRaw,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }
}

import 'package:flutter/material.dart';
import '../models/artwork.dart';

class DefaultArtworks {
  static List<Artwork> getArtworks() {
    return [
      _createStrawberry(),
      _createPixelSword(),
      _createRainbowHeart(),
      _createCuteKitty(),
      _createUnicorn(),
      _createCupcake(),
      _createGameController(),
    ];
  }

  // 1. STRAWBERRY (from screenshots)
  static Artwork _createStrawberry() {
    const w = 20;
    const h = 20;
    // Colors:
    // 1: Leaf Green (#388E3C)
    // 2: Light Green (#81C784)
    // 3: Bright Red (#E53935)
    // 4: Deep Red (#B71C1C)
    // 5: Seed Yellow (#FFF176)
    // 6: Black Outline/Face (#212121)
    // 7: White Sparkle (#FFFFFF)
    final colors = [
      const PixelColor(id: 1, color: Color(0xFF388E3C), name: 'Leaf Green'),
      const PixelColor(id: 2, color: Color(0xFF81C784), name: 'Light Green'),
      const PixelColor(id: 3, color: Color(0xFFE53935), name: 'Strawberry Red'),
      const PixelColor(id: 4, color: Color(0xFFB71C1C), name: 'Dark Red'),
      const PixelColor(id: 5, color: Color(0xFFFFF176), name: 'Seed Yellow'),
      const PixelColor(id: 6, color: Color(0xFF212121), name: 'Black Detail'),
      const PixelColor(id: 7, color: Color(0xFFFFFFFF), name: 'White Glow'),
    ];

    final grid = [
      [0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,1,2,1,1,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,1,1,0,0,1,1,0,0,1,1,0,0,0,0,0,0],
      [0,0,0,1,2,2,1,1,1,1,1,1,2,2,1,0,0,0,0,0],
      [0,0,1,2,2,1,1,2,2,2,1,1,1,2,2,1,0,0,0,0],
      [0,0,0,1,1,6,6,6,6,6,6,6,6,1,1,0,0,0,0,0],
      [0,0,6,6,3,3,3,3,3,3,3,3,3,3,6,6,0,0,0,0],
      [0,6,3,7,3,3,5,3,3,3,5,3,3,3,3,3,6,0,0,0],
      [0,6,3,7,7,3,3,3,3,3,3,3,5,3,3,4,6,0,0,0],
      [6,3,3,3,3,3,6,6,3,3,6,6,3,3,3,4,4,6,0,0],
      [6,3,5,3,3,3,6,6,3,3,6,6,3,5,3,4,4,6,0,0],
      [6,3,3,3,3,3,3,3,6,6,3,3,3,3,3,4,4,6,0,0],
      [6,3,3,5,3,3,3,3,3,3,3,3,3,3,4,4,4,6,0,0],
      [0,6,3,3,3,3,5,3,3,3,5,3,3,4,4,4,6,0,0,0],
      [0,6,3,3,5,3,3,3,3,3,3,3,4,4,4,4,6,0,0,0],
      [0,0,6,3,3,3,3,5,3,3,4,4,4,4,4,6,0,0,0,0],
      [0,0,6,3,3,3,3,3,3,4,4,4,4,4,4,6,0,0,0,0],
      [0,0,0,6,6,3,3,3,4,4,4,4,4,6,6,0,0,0,0,0],
      [0,0,0,0,0,6,6,4,4,4,4,6,6,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,6,6,6,6,0,0,0,0,0,0,0,0,0],
    ];

    return Artwork(
      id: 'strawberry',
      title: 'Sweet Strawberry',
      category: 'Food',
      width: w,
      height: h,
      colors: colors,
      grid: grid,
    );
  }

  // 2. PIXEL SWORD (from screenshots)
  static Artwork _createPixelSword() {
    const w = 20;
    const h = 20;
    // 1: Steel Cyan (#80D8FF)
    // 2: Blade Blue (#00B0FF)
    // 3: Deep Blade Blue (#0091EA)
    // 4: Golden Hilt (#FFD54F)
    // 5: Dark Gold (#FF8F00)
    // 6: Wood Grip (#8D6E63)
    // 7: Dark Handle (#4E342E)
    // 8: Black Outline (#212121)
    final colors = [
      const PixelColor(id: 1, color: Color(0xFFE0F7FA), name: 'Glint White'),
      const PixelColor(id: 2, color: Color(0xFF80D8FF), name: 'Cyan Glow'),
      const PixelColor(id: 3, color: Color(0xFF0091EA), name: 'Steel Blue'),
      const PixelColor(id: 4, color: Color(0xFF01579B), name: 'Deep Blue'),
      const PixelColor(id: 5, color: Color(0xFFFFD54F), name: 'Gold Hilt'),
      const PixelColor(id: 6, color: Color(0xFFFF8F00), name: 'Dark Gold'),
      const PixelColor(id: 7, color: Color(0xFF8D6E63), name: 'Wood Grip'),
      const PixelColor(id: 8, color: Color(0xFF212121), name: 'Iron Black'),
    ];

    final grid = [
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,1,8,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,1,2,8,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,8,1,2,3,8,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,8,1,2,3,4,8,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,8,1,2,3,4,8,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,8,1,2,3,4,8,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,8,1,2,3,4,8,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,8,1,2,3,4,8,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,8,1,2,3,4,8,0,0,0,0,0,0,0],
      [0,0,0,0,0,8,8,5,2,3,4,8,8,0,0,0,0,0,0,0],
      [0,0,0,0,8,5,5,5,4,8,8,5,5,8,0,0,0,0,0,0],
      [0,0,0,8,5,6,6,8,8,7,8,6,5,8,0,0,0,0,0,0],
      [0,0,0,8,6,8,8,7,7,8,8,8,8,0,0,0,0,0,0,0],
      [0,0,8,8,8,0,8,7,7,8,0,0,0,0,0,0,0,0,0,0],
      [0,8,5,8,0,0,0,8,7,7,8,0,0,0,0,0,0,0,0,0],
      [0,8,5,5,8,0,0,0,8,7,7,8,0,0,0,0,0,0,0,0],
      [0,0,8,6,5,8,0,0,0,8,8,5,8,0,0,0,0,0,0,0],
      [0,0,0,8,8,0,0,0,0,0,8,5,5,8,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,8,8,0,0,0,0,0,0,0],
    ];

    return Artwork(
      id: 'sword',
      title: 'Pixel Diamond Sword',
      category: 'Games',
      width: w,
      height: h,
      colors: colors,
      grid: grid,
    );
  }

  // 3. RAINBOW HEART (from screenshots)
  static Artwork _createRainbowHeart() {
    const w = 20;
    const h = 20;
    // 1: Red (#FF1744)
    // 2: Orange (#FF9100)
    // 3: Yellow (#FFEA00)
    // 4: Green (#00E676)
    // 5: Cyan/Blue (#00E5FF)
    // 6: Purple/Violet (#D500F9)
    // 7: Black Outline (#212121)
    final colors = [
      const PixelColor(id: 1, color: Color(0xFFFF1744), name: 'Rainbow Red'),
      const PixelColor(id: 2, color: Color(0xFFFF9100), name: 'Rainbow Orange'),
      const PixelColor(id: 3, color: Color(0xFFFFEA00), name: 'Rainbow Yellow'),
      const PixelColor(id: 4, color: Color(0xFF00E676), name: 'Rainbow Green'),
      const PixelColor(id: 5, color: Color(0xFF00E5FF), name: 'Rainbow Cyan'),
      const PixelColor(id: 6, color: Color(0xFFD500F9), name: 'Rainbow Violet'),
      const PixelColor(id: 7, color: Color(0xFF212121), name: 'Border Black'),
    ];

    final grid = [
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,7,7,7,7,0,0,0,0,7,7,7,7,0,0,0,0,0],
      [0,0,7,1,1,1,1,7,0,0,7,1,1,1,1,7,0,0,0,0],
      [0,7,1,1,2,2,1,1,7,7,1,1,2,2,1,1,7,0,0,0],
      [7,1,1,2,2,3,3,2,1,1,2,2,3,3,2,1,1,7,0,0],
      [7,1,2,2,3,3,4,4,3,2,2,3,3,4,4,2,1,7,0,0],
      [7,1,2,3,3,4,4,5,5,4,3,3,4,4,5,3,1,7,0,0],
      [7,1,2,3,4,4,5,5,6,6,5,4,4,5,5,3,1,7,0,0],
      [7,1,2,3,4,5,5,6,6,6,6,5,5,6,5,3,1,7,0,0],
      [0,7,1,2,3,4,5,5,6,6,5,5,6,6,4,2,7,0,0,0],
      [0,7,1,2,3,4,4,5,5,6,5,5,5,4,3,2,7,0,0,0],
      [0,0,7,1,2,3,3,4,4,5,4,4,4,3,2,7,0,0,0,0],
      [0,0,7,1,2,2,3,3,4,4,4,3,3,2,1,7,0,0,0,0],
      [0,0,0,7,1,1,2,2,3,3,3,2,2,1,7,0,0,0,0,0],
      [0,0,0,0,7,1,1,2,2,2,2,1,1,7,0,0,0,0,0,0],
      [0,0,0,0,0,7,1,1,1,1,1,1,7,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,7,1,1,1,1,7,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,7,1,1,7,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,7,7,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    ];

    return Artwork(
      id: 'rainbow_heart',
      title: 'Rainbow Heart',
      category: 'Love & Cute',
      width: w,
      height: h,
      colors: colors,
      grid: grid,
    );
  }

  // 4. CUTE KITTY (from screenshots)
  static Artwork _createCuteKitty() {
    const w = 20;
    const h = 20;
    // 1: Rainbow Red (#FF5252)
    // 2: Rainbow Yellow (#FFD740)
    // 3: Rainbow Cyan (#40C4FF)
    // 4: Ginger Orange (#FF9800)
    // 5: Dark Orange (#E65100)
    // 6: White Fur (#FFFFFF)
    // 7: Pink Blush (#FF80AB)
    // 8: Black Features (#212121)
    final colors = [
      const PixelColor(id: 1, color: Color(0xFFFF5252), name: 'Sky Pink'),
      const PixelColor(id: 2, color: Color(0xFFFFD740), name: 'Sky Yellow'),
      const PixelColor(id: 3, color: Color(0xFF40C4FF), name: 'Sky Blue'),
      const PixelColor(id: 4, color: Color(0xFFFF9800), name: 'Cat Orange'),
      const PixelColor(id: 5, color: Color(0xFFE65100), name: 'Stripe Amber'),
      const PixelColor(id: 6, color: Color(0xFFFFFFFF), name: 'White Fur'),
      const PixelColor(id: 7, color: Color(0xFFFF80AB), name: 'Blush Pink'),
      const PixelColor(id: 8, color: Color(0xFF212121), name: 'Black Outline'),
    ];

    final grid = [
      [0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0],
      [0,0,1,1,2,2,2,2,2,2,2,2,2,2,1,1,0,0,0,0],
      [0,1,2,3,3,3,3,3,3,3,3,3,3,3,3,2,1,0,0,0],
      [1,2,3,0,0,0,0,0,0,0,0,0,0,0,0,3,2,1,0,0],
      [2,3,0,8,8,0,0,0,0,0,0,0,0,8,8,0,3,2,0,0],
      [3,0,8,4,4,8,0,0,0,0,0,0,8,4,4,8,0,3,0,0],
      [0,0,8,4,7,4,8,8,8,8,8,8,8,4,7,4,8,0,0,0],
      [0,8,4,4,4,4,4,5,5,4,4,4,4,4,4,4,4,8,0,0],
      [0,8,4,4,4,4,4,4,5,4,4,4,4,4,4,4,4,8,0,0],
      [0,8,4,8,8,4,4,4,4,4,4,4,4,8,8,4,4,8,0,0],
      [0,8,4,8,8,4,4,4,8,8,4,4,4,8,8,4,4,8,0,0],
      [0,8,7,7,4,4,4,8,7,7,8,4,4,4,7,7,4,8,0,0],
      [0,8,4,4,4,4,6,6,6,6,6,6,4,4,4,4,4,8,0,0],
      [0,0,8,4,4,6,6,6,6,6,6,6,6,4,4,4,8,0,0,0],
      [0,0,8,4,4,6,6,6,6,6,6,6,6,4,4,4,8,0,0,0],
      [0,0,8,4,6,6,8,8,6,6,8,8,6,6,4,4,8,0,0,0],
      [0,0,8,4,6,6,8,8,6,6,8,8,6,6,4,4,8,0,0,0],
      [0,0,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    ];

    return Artwork(
      id: 'kitty',
      title: 'Rainbow Cat',
      category: 'Animals',
      width: w,
      height: h,
      colors: colors,
      grid: grid,
    );
  }

  // 5. UNICORN (from screenshots)
  static Artwork _createUnicorn() {
    const w = 20;
    const h = 20;
    // 1: Magic Gold Horn (#FFD700)
    // 2: Magic Purple (#AB47BC)
    // 3: Magic Cyan (#26C6DA)
    // 4: Magic Pink (#EC407A)
    // 5: Body White (#FFFFFF)
    // 6: Shadow Grey (#ECEFF1)
    // 7: Dark Outline (#263238)
    final colors = [
      const PixelColor(id: 1, color: Color(0xFFFFD700), name: 'Horn Gold'),
      const PixelColor(id: 2, color: Color(0xFFAB47BC), name: 'Mane Violet'),
      const PixelColor(id: 3, color: Color(0xFF26C6DA), name: 'Mane Turquoise'),
      const PixelColor(id: 4, color: Color(0xFFEC407A), name: 'Mane Pink'),
      const PixelColor(id: 5, color: Color(0xFFFFFFFF), name: 'Unicorn White'),
      const PixelColor(id: 6, color: Color(0xFFCFD8DC), name: 'Soft Shadow'),
      const PixelColor(id: 7, color: Color(0xFF263238), name: 'Charcoal Line'),
    ];

    final grid = [
      [0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,7,7,1,1,7,7,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,7,5,5,7,7,5,5,7,0,0,0,0,0,0],
      [0,0,0,0,0,7,5,5,5,5,5,5,5,5,7,2,2,0,0,0],
      [0,0,0,0,7,5,5,5,5,5,5,5,5,5,5,7,2,2,0,0],
      [0,0,0,7,5,5,7,7,5,5,5,5,5,5,5,5,7,3,0,0],
      [0,0,7,5,5,5,7,7,5,5,5,5,5,5,5,5,7,3,3,0],
      [0,7,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,7,4,0],
      [7,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,7,4,0],
      [7,4,4,7,7,7,7,5,5,5,5,5,5,6,6,5,5,7,0,0],
      [0,7,7,0,0,0,7,5,5,5,5,6,6,6,6,5,7,0,0,0],
      [0,0,0,0,0,0,7,5,5,5,6,6,6,6,6,5,7,0,0,0],
      [0,0,0,0,0,7,5,5,6,6,6,6,6,6,6,5,7,0,0,0],
      [0,0,0,0,7,5,5,6,6,6,7,7,7,6,6,5,7,0,0,0],
      [0,0,0,7,5,5,6,6,6,7,0,0,0,7,6,5,7,0,0,0],
      [0,0,7,5,5,6,6,6,7,0,0,0,0,0,7,7,0,0,0,0],
      [0,0,7,7,7,7,7,7,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    ];

    return Artwork(
      id: 'unicorn',
      title: 'Magical Unicorn',
      category: 'Love & Cute',
      width: w,
      height: h,
      colors: colors,
      grid: grid,
    );
  }

  // 6. CUPCAKE
  static Artwork _createCupcake() {
    const w = 20;
    const h = 20;
    final colors = [
      const PixelColor(id: 1, color: Color(0xFFD50000), name: 'Cherry Red'),
      const PixelColor(id: 2, color: Color(0xFFF48FB1), name: 'Frosting Pink'),
      const PixelColor(id: 3, color: Color(0xFFFCE4EC), name: 'Frosting White'),
      const PixelColor(id: 4, color: Color(0xFFFFD54F), name: 'Sprinkle Gold'),
      const PixelColor(id: 5, color: Color(0xFF80D8FF), name: 'Cup Cyan'),
      const PixelColor(id: 6, color: Color(0xFF0091EA), name: 'Cup Dark Blue'),
      const PixelColor(id: 7, color: Color(0xFF212121), name: 'Line Dark'),
    ];

    final grid = [
      [0,0,0,0,0,0,0,0,7,7,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,7,1,1,7,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,7,1,1,1,1,7,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,7,1,1,7,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,7,7,7,7,7,7,7,7,0,0,0,0,0,0,0],
      [0,0,0,0,7,3,3,3,3,3,3,3,3,7,0,0,0,0,0,0],
      [0,0,0,7,3,4,3,2,2,3,4,3,3,3,7,0,0,0,0,0],
      [0,0,7,2,3,3,2,2,2,2,3,3,4,2,2,7,0,0,0,0],
      [0,7,2,2,2,2,2,4,2,2,2,2,2,2,2,2,7,0,0,0],
      [7,2,2,4,2,2,2,2,2,2,2,4,2,2,4,2,2,7,0,0],
      [7,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,7,0,0],
      [0,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,0,0,0],
      [0,0,7,5,5,6,5,5,6,5,5,6,5,5,6,7,0,0,0,0],
      [0,0,7,5,5,6,5,5,6,5,5,6,5,5,6,7,0,0,0,0],
      [0,0,0,7,5,6,5,5,6,5,5,6,5,5,7,0,0,0,0,0],
      [0,0,0,7,5,6,5,5,6,5,5,6,5,5,7,0,0,0,0,0],
      [0,0,0,0,7,6,5,5,6,5,5,6,5,7,0,0,0,0,0,0],
      [0,0,0,0,7,6,5,5,6,5,5,6,5,7,0,0,0,0,0,0],
      [0,0,0,0,0,7,7,7,7,7,7,7,7,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    ];

    return Artwork(
      id: 'cupcake',
      title: 'Sweet Cupcake',
      category: 'Food',
      width: w,
      height: h,
      colors: colors,
      grid: grid,
    );
  }

  // 7. GAME CONTROLLER
  static Artwork _createGameController() {
    const w = 20;
    const h = 20;
    final colors = [
      const PixelColor(id: 1, color: Color(0xFF78909C), name: 'Console Grey'),
      const PixelColor(id: 2, color: Color(0xFF37474F), name: 'Dark Grey'),
      const PixelColor(id: 3, color: Color(0xFFFF5252), name: 'Button Red'),
      const PixelColor(id: 4, color: Color(0xFF448AFF), name: 'Button Blue'),
      const PixelColor(id: 5, color: Color(0xFFFFD740), name: 'Button Yellow'),
      const PixelColor(id: 6, color: Color(0xFF69F0AE), name: 'Button Green'),
      const PixelColor(id: 7, color: Color(0xFF212121), name: 'Black Outline'),
    ];

    final grid = [
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,7,7,7,0,0,0,0,0,0,0,7,7,7,0,0,0,0],
      [0,0,7,2,2,2,7,7,7,7,7,7,7,2,2,2,7,0,0,0],
      [0,7,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,7,0,0],
      [7,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,7,0],
      [7,1,1,7,1,1,1,1,1,1,1,1,1,5,1,1,1,1,7,0],
      [7,1,7,7,7,1,1,2,2,1,2,2,1,3,1,4,1,1,7,0],
      [7,1,1,7,1,1,1,2,2,1,2,2,1,1,6,1,1,1,7,0],
      [7,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,7,0],
      [7,1,1,1,1,1,1,7,7,7,7,1,1,1,1,1,1,1,7,0],
      [0,7,1,1,1,1,7,0,0,0,0,7,1,1,1,1,1,7,0,0],
      [0,7,1,1,1,7,0,0,0,0,0,0,7,1,1,1,1,7,0,0],
      [0,0,7,1,1,7,0,0,0,0,0,0,7,1,1,1,7,0,0,0],
      [0,0,7,1,1,7,0,0,0,0,0,0,7,1,1,1,7,0,0,0],
      [0,0,0,7,7,0,0,0,0,0,0,0,0,7,7,7,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    ];

    return Artwork(
      id: 'gamepad',
      title: 'Retro Gamepad',
      category: 'Games',
      width: w,
      height: h,
      colors: colors,
      grid: grid,
    );
  }
}


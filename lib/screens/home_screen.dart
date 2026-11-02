import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/default_artworks.dart';
import '../models/artwork.dart';
import '../painters/artwork_thumbnail_painter.dart';
import '../services/game_storage_service.dart';
import '../services/image_converter_service.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Artwork> _artworks = [];
  String _selectedCategory = 'All';
  int _coins = 150;
  bool _isLoading = true;

  final List<String> _categories = [
    'All',
    'Food',
    'Games',
    'Animals',
    'Love & Cute',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    _loadAllArtworks();
  }

  Future<void> _loadAllArtworks() async {
    setState(() => _isLoading = true);

    final defaults = DefaultArtworks.getArtworks();
    for (final art in defaults) {
      await GameStorageService.loadArtworkProgress(art);
    }

    final customs = await GameStorageService.loadCustomArtworks();
    for (final art in customs) {
      await GameStorageService.loadArtworkProgress(art);
    }

    final coins = await GameStorageService.getCoins();

    setState(() {
      _artworks = [...defaults, ...customs];
      _coins = coins;
      _isLoading = false;
    });
  }

  Future<void> _pickAndCreateArtwork() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF6C5CE7)),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF00B894)),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await picker.pickImage(source: source);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    _showCustomizationDialog(bytes);
  }

  void _showCustomizationDialog(Uint8List bytes) {
    int resolution = 48;
    int colors = 16;
    final titleController = TextEditingController(text: 'My Photo Art');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.tune, color: Color(0xFF6C5CE7)),
              SizedBox(width: 8),
              Text(
                'Convert to Color by Number',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Artwork Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Detail Resolution:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      resolution >= 60
                          ? '$resolution (High Detail)'
                          : resolution >= 40
                              ? '$resolution (Medium)'
                              : '$resolution (Retro Pixel)',
                      style: const TextStyle(color: Color(0xFF6C5CE7), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  min: 24,
                  max: 72,
                  divisions: 6,
                  value: resolution.toDouble(),
                  onChanged: (v) => setDlgState(() => resolution = v.toInt()),
                ),
                const Text(
                  '💡 Real photos of people look best at 48 to 72 resolution.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Color Palette Count:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '$colors Colors',
                      style: const TextStyle(color: Color(0xFF6C5CE7), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  min: 6,
                  max: 24,
                  divisions: 9,
                  value: colors.toDouble(),
                  onChanged: (v) => setDlgState(() => colors = v.toInt()),
                ),
                const Text(
                  '💡 More colors capture skin tones, clothing, and natural lighting.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                _processCustomImage(
                  bytes: bytes,
                  title: titleController.text,
                  size: resolution,
                  colorCount: colors,
                );
              },
              child: const Text('Convert & Play'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processCustomImage({
    required Uint8List bytes,
    required String title,
    required int size,
    required int colorCount,
  }) async {
    try {
      final customArt = await ImageConverterService.convertImageToArtwork(
        bytes: bytes,
        title: title,
        targetWidth: size,
        colorCount: colorCount,
      );

      await GameStorageService.saveCustomArtwork(customArt);
      await _loadAllArtworks();

      if (!mounted) return;
      _openGame(customArt);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating artwork: $e')),
      );
    }
  }

  void _openGame(Artwork artwork) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(artwork: artwork),
      ),
    );

    if (result == true) {
      _loadAllArtworks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _artworks.where((a) {
      if (_selectedCategory == 'All') return true;
      if (_selectedCategory == 'Custom') return a.isCustom;
      return a.category == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.palette_rounded, color: Color(0xFF6C5CE7), size: 28),
            SizedBox(width: 8),
            Text(
              'Color by Number',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF2D3436),
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          // Coins chip
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$_coins',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
          ),

          // Custom Create button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Create from Photo',
              icon: const Icon(Icons.add_photo_alternate, color: Color(0xFF6C5CE7)),
              onPressed: _pickAndCreateArtwork,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAllArtworks,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. SHOWCASE BEFORE & AFTER BANNER (from screenshots)
                    _buildShowcaseBanner(),

                    const SizedBox(height: 16),

                    // 2. CATEGORIES FILTER CHIPS
                    _buildCategoriesBar(),

                    const SizedBox(height: 16),

                    // 3. ARTWORKS GRID
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '$_selectedCategory Artworks (${filtered.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemBuilder: (context, index) {
                          final art = filtered[index];
                          return _buildArtworkCard(art);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Wildlife Studios Showcase Card (Screenshot 2: Before & After Strawberry)
  Widget _buildShowcaseBanner() {
    final strawberry = _artworks.firstWhere(
      (a) => a.id == 'strawberry',
      orElse: () => _artworks.first,
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
              SizedBox(width: 6),
              Text(
                'COLOR & RELAX',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Paint by Numbers Easily',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),

          // Before & After container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Before (Grey Outline)
                Column(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CustomPaint(
                        painter: ArtworkThumbnailPainter(
                          artwork: strawberry,
                          showFullColor: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Numbered',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                // Arrow
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF6C5CE7),
                  size: 28,
                ),

                // After (Full Color)
                Column(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CustomPaint(
                        painter: ArtworkThumbnailPainter(
                          artwork: strawberry,
                          showFullColor: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Colored!',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00B894),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesBar() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              selectedColor: const Color(0xFF6C5CE7),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF2D3436),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                ),
              ),
              onSelected: (val) {
                if (val) {
                  setState(() => _selectedCategory = cat);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildArtworkCard(Artwork artwork) {
    final progress = artwork.progress;
    final percentage = (progress * 100).toInt();
    final isDone = artwork.isCompleted;

    return GestureDetector(
      onTap: () => _openGame(artwork),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Image
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CustomPaint(
                      painter: ArtworkThumbnailPainter(
                        artwork: artwork,
                        showFullColor: isDone,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Card details
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artwork.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDone ? const Color(0xFF00B894) : const Color(0xFF6C5CE7),
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isDone ? '✓' : '$percentage%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDone ? const Color(0xFF00B894) : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

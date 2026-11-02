import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../models/artwork.dart';
import '../painters/pixel_art_painter.dart';
import '../services/game_storage_service.dart';

enum GameToolMode { paint, pan }

class GameScreen extends StatefulWidget {
  final Artwork artwork;

  const GameScreen({
    super.key,
    required this.artwork,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _pulseController;
  late ConfettiController _confettiController;

  int _selectedColorId = 1;
  int _coins = 150;
  final Set<String> _hintCells = {};
  bool _isFinished = false;
  GameToolMode _currentMode = GameToolMode.paint;

  // Adaptive cell size based on grid dimensions
  late double _baseCellSize;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    // Calculate nice base cell size
    final maxDim = max(widget.artwork.width, widget.artwork.height);
    if (maxDim <= 24) {
      _baseCellSize = 26.0;
    } else if (maxDim <= 48) {
      _baseCellSize = 18.0;
    } else {
      _baseCellSize = 12.0;
    }

    _loadState();
    _selectFirstIncompleteColor();
  }

  Future<void> _loadState() async {
    final coins = await GameStorageService.getCoins();
    setState(() {
      _coins = coins;
    });
  }

  void _selectFirstIncompleteColor() {
    for (final c in widget.artwork.colors) {
      if (!widget.artwork.isColorCompleted(c.id)) {
        setState(() {
          _selectedColorId = c.id;
        });
        return;
      }
    }
    if (widget.artwork.colors.isNotEmpty) {
      _selectedColorId = widget.artwork.colors.first.id;
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _paintAt(Offset localOffset) {
    if (_isFinished || _currentMode != GameToolMode.paint) return;

    final x = (localOffset.dx / _baseCellSize).floor();
    final y = (localOffset.dy / _baseCellSize).floor();

    if (x < 0 ||
        x >= widget.artwork.width ||
        y < 0 ||
        y >= widget.artwork.height) {
      return;
    }

    final cellColorId = widget.artwork.grid[y][x];
    if (cellColorId == 0) return;

    if (cellColorId == _selectedColorId && !widget.artwork.coloredGrid[y][x]) {
      setState(() {
        widget.artwork.coloredGrid[y][x] = true;
        _hintCells.remove('$x,$y');
      });

      HapticFeedback.lightImpact();
      GameStorageService.saveArtworkProgress(widget.artwork);

      if (widget.artwork.isColorCompleted(_selectedColorId)) {
        _onColorCompleted();
      }

      if (widget.artwork.isCompleted && !_isFinished) {
        _onArtworkCompleted();
      }
    }
  }

  void _onColorCompleted() {
    for (final c in widget.artwork.colors) {
      if (!widget.artwork.isColorCompleted(c.id)) {
        setState(() {
          _selectedColorId = c.id;
        });
        break;
      }
    }
  }

  Future<void> _onArtworkCompleted() async {
    setState(() {
      _isFinished = true;
    });
    _confettiController.play();
    await GameStorageService.addCoins(50);
    final updatedCoins = await GameStorageService.getCoins();
    setState(() {
      _coins = updatedCoins;
    });

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Center(
          child: Text(
            '🎉 Fantastic! 🎉',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You completed this masterpiece!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.monetization_on, color: Colors.amber, size: 24),
                  SizedBox(width: 8),
                  Text(
                    '+50 Coins Earned!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.brown,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: const Text('Back to Gallery', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _resetProgress() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Restart Artwork?'),
        content: const Text('Do you want to reset all colors and paint again from start?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                widget.artwork.resetProgress();
                _isFinished = false;
                _hintCells.clear();
              });
              _selectFirstIncompleteColor();
              GameStorageService.saveArtworkProgress(widget.artwork);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _useHint() {
    final List<Point<int>> remaining = [];
    for (int y = 0; y < widget.artwork.height; y++) {
      for (int x = 0; x < widget.artwork.width; x++) {
        if (widget.artwork.grid[y][x] == _selectedColorId &&
            !widget.artwork.coloredGrid[y][x]) {
          remaining.add(Point(x, y));
        }
      }
    }

    if (remaining.isEmpty) return;

    final target = remaining[Random().nextInt(remaining.length)];
    setState(() {
      _hintCells.add('${target.x},${target.y}');
    });

    HapticFeedback.mediumImpact();

    final targetX = target.x * _baseCellSize + _baseCellSize / 2;
    final targetY = target.y * _baseCellSize + _baseCellSize / 2;
    final matrix = Matrix4.diagonal3Values(1.8, 1.8, 1.0)
      ..setTranslationRaw(-targetX * 1.8 + 200, -targetY * 1.8 + 250, 0.0);
    _transformationController.value = matrix;
  }

  void _useMagicWand() {
    int filled = 0;
    setState(() {
      for (int y = 0; y < widget.artwork.height; y++) {
        for (int x = 0; x < widget.artwork.width; x++) {
          if (widget.artwork.grid[y][x] == _selectedColorId &&
              !widget.artwork.coloredGrid[y][x]) {
            widget.artwork.coloredGrid[y][x] = true;
            _hintCells.remove('$x,$y');
            filled++;
            if (filled >= 6) break;
          }
        }
        if (filled >= 6) break;
      }
    });

    if (filled > 0) {
      HapticFeedback.heavyImpact();
      GameStorageService.saveArtworkProgress(widget.artwork);

      if (widget.artwork.isColorCompleted(_selectedColorId)) {
        _onColorCompleted();
      }
      if (widget.artwork.isCompleted && !_isFinished) {
        _onArtworkCompleted();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canvasWidth = widget.artwork.width * _baseCellSize;
    final canvasHeight = widget.artwork.height * _baseCellSize;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),

                // Canvas Area
                Expanded(
                  child: Center(
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 0.5,
                      maxScale: 6.0,
                      panEnabled: _currentMode == GameToolMode.pan,
                      boundaryMargin: const EdgeInsets.all(160),
                      child: GestureDetector(
                        onPanDown: (details) => _paintAt(details.localPosition),
                        onPanUpdate: (details) => _paintAt(details.localPosition),
                        onTapUp: (details) => _paintAt(details.localPosition),
                        child: Container(
                          width: canvasWidth,
                          height: canvasHeight,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, _) {
                                return CustomPaint(
                                  size: Size(canvasWidth, canvasHeight),
                                  painter: PixelArtPainter(
                                    artwork: widget.artwork,
                                    activeColorId: _selectedColorId,
                                    cellSize: _baseCellSize,
                                    highlightPulse: _pulseController.value,
                                    hintCells: _hintCells,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                _buildColorPaletteBar(),
              ],
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.amber,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final progress = widget.artwork.progress;
    final percentage = (progress * 100).toInt();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                onPressed: () => Navigator.pop(context, true),
              ),
              Expanded(
                child: Text(
                  widget.artwork.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2D3436),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Restart / Reset
              IconButton(
                tooltip: 'Reset Colors',
                icon: const Icon(Icons.refresh, color: Colors.grey),
                onPressed: _resetProgress,
              ),
              // Magic Wand
              IconButton(
                tooltip: 'Magic Wand (+6 pixels)',
                icon: const Icon(Icons.auto_fix_high, color: Color(0xFF00B894)),
                onPressed: _useMagicWand,
              ),
              // Hint
              IconButton(
                tooltip: 'Find Missing Pixel',
                icon: const Icon(Icons.search, color: Color(0xFF0984E3)),
                onPressed: _useHint,
              ),
              // Coins
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$_coins',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.brown,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress bar + Mode switch row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Painting Progress',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          '$percentage%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color(0xFF6C5CE7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF6C5CE7),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Mode Segmented Button
              SegmentedButton<GameToolMode>(
                segments: const [
                  ButtonSegment(
                    value: GameToolMode.paint,
                    icon: Icon(Icons.edit, size: 16),
                    label: Text('Paint', style: TextStyle(fontSize: 12)),
                  ),
                  ButtonSegment(
                    value: GameToolMode.pan,
                    icon: Icon(Icons.pan_tool, size: 16),
                    label: Text('Move', style: TextStyle(fontSize: 12)),
                  ),
                ],
                selected: {_currentMode},
                onSelectionChanged: (set) {
                  setState(() => _currentMode = set.first);
                },
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorPaletteBar() {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.artwork.colors.length,
        itemBuilder: (context, index) {
          final pixelColor = widget.artwork.colors[index];
          final isSelected = pixelColor.id == _selectedColorId;
          final remaining = widget.artwork.getRemainingCountForColor(pixelColor.id);
          final isDone = remaining == 0;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedColorId = pixelColor.id;
              });
              HapticFeedback.selectionClick();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 52 : 44,
                    height: isSelected ? 52 : 44,
                    decoration: BoxDecoration(
                      color: pixelColor.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF2D3436) : Colors.black12,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: pixelColor.color.withValues(alpha: 0.4),
                          blurRadius: isSelected ? 8 : 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 22,
                            )
                          : Text(
                              '${pixelColor.id}',
                              style: TextStyle(
                                color: ThemeData.estimateBrightnessForColor(
                                          pixelColor.color,
                                        ) ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: isSelected ? 18 : 14,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isDone ? 'Done' : '$remaining',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isDone ? Colors.green : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

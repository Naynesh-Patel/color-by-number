import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/artwork.dart';

class GameStorageService {
  static const String _keyCustomArtworks = 'cbn_custom_artworks';
  static const String _keyCoins = 'cbn_player_coins';
  static const String _keyProgressPrefix = 'cbn_progress_';

  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCoins) ?? 150; // Starter coins
  }

  static Future<void> addCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getCoins();
    await prefs.setInt(_keyCoins, current + amount);
  }

  static Future<bool> spendCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getCoins();
    if (current >= amount) {
      await prefs.setInt(_keyCoins, current - amount);
      return true;
    }
    return false;
  }

  static Future<void> saveArtworkProgress(Artwork artwork) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyProgressPrefix${artwork.id}';
    final jsonStr = jsonEncode(artwork.coloredGrid);
    await prefs.setString(key, jsonStr);
  }

  static Future<void> loadArtworkProgress(Artwork artwork) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyProgressPrefix${artwork.id}';
    final jsonStr = prefs.getString(key);
    if (jsonStr != null) {
      try {
        final List<dynamic> raw = jsonDecode(jsonStr);
        for (int y = 0; y < artwork.height && y < raw.length; y++) {
          final row = raw[y] as List;
          for (int x = 0; x < artwork.width && x < row.length; x++) {
            artwork.coloredGrid[y][x] = row[x] as bool;
          }
        }
      } catch (e) {
        debugPrint('Error loading progress: $e');
      }
    }
  }

  static Future<void> saveCustomArtwork(Artwork artwork) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(_keyCustomArtworks) ?? [];
    list.add(jsonEncode(artwork.toJson()));
    await prefs.setStringList(_keyCustomArtworks, list);
  }

  static Future<List<Artwork>> loadCustomArtworks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? list = prefs.getStringList(_keyCustomArtworks);
    if (list == null) return [];

    final List<Artwork> result = [];
    for (final item in list) {
      try {
        final Map<String, dynamic> map = jsonDecode(item);
        result.add(Artwork.fromJson(map));
      } catch (e) {
        debugPrint('Error decoding custom artwork: $e');
      }
    }
    return result;
  }
}

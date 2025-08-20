import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents a cosmetic item (theme, icon, trail, etc.)
class CosmeticItem {
  final String id;
  final String name;
  final String type; // e.g., 'theme', 'icon', 'trail'

  const CosmeticItem({
    required this.id,
    required this.name,
    required this.type,
  });
}

class CosmeticProvider with ChangeNotifier {
  static const _prefsKeyUnlocked = 'cosmetics_unlocked';
  static const _prefsKeyEquipped = 'cosmetics_equipped';

  /// All available cosmetics in the app
  final List<CosmeticItem> allItems = const [
    CosmeticItem(id: 'theme_neon', name: 'Neon Theme', type: 'theme'),
    CosmeticItem(id: 'theme_cyan', name: 'Cyan Aurora', type: 'theme'),
    CosmeticItem(id: 'trail_spark', name: 'Spark Trail', type: 'trail'),
    CosmeticItem(id: 'icon_crystal', name: 'Crystal Icons', type: 'icon'),
  ];

  /// Unlocked item IDs
  Set<String> _unlocked = {};
  /// Current equipped items by type
  Map<String, String> _equippedByType = {};

  Set<String> get unlocked => _unlocked;
  Map<String, String> get equippedByType => _equippedByType;

  /// Load cosmetics state from SharedPreferences
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // Load unlocked
    final unlockedList = prefs.getStringList(_prefsKeyUnlocked);
    _unlocked = (unlockedList ?? []).toSet();

    // Load equipped
    final raw = prefs.getString(_prefsKeyEquipped);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _equippedByType = decoded.map(
            (key, value) => MapEntry(key, value.toString()),
          );
        }
      } catch (e) {
        debugPrint('Failed to decode equipped cosmetics: $e');
        _equippedByType = {};
      }
    }

    notifyListeners();
  }

  /// Unlock a cosmetic by ID
  Future<void> unlock(String id) async {
    _unlocked.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKeyUnlocked, _unlocked.toList());
    notifyListeners();
  }

  /// Equip a cosmetic by ID (replaces any of that type)
  Future<void> equip(String id) async {
    final item = allItems.firstWhere(
      (e) => e.id == id,
      orElse: () => throw Exception('Equip failed: Item $id not found'),
    );

    _equippedByType[item.type] = item.id;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyEquipped, jsonEncode(_equippedByType));

    notifyListeners();
  }

  /// Get currently equipped item for a given type
  CosmeticItem? getEquipped(String type) {
    final id = _equippedByType[type];
    if (id == null) return null;

    try {
      return allItems.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Return a random locked (unowned) cosmetic, or null if all unlocked
  CosmeticItem? randomLocked() {
    final remaining = allItems.where((e) => !_unlocked.contains(e.id)).toList();
    if (remaining.isEmpty) return null;
    remaining.shuffle();
    return remaining.first;
  }

  /// Reset all cosmetics (useful for debug/testing or account reset)
  Future<void> reset() async {
    _unlocked.clear();
    _equippedByType.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKeyUnlocked);
    await prefs.remove(_prefsKeyEquipped);
    notifyListeners();
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CosmeticItem {
  final String id;
  final String name;
  final String type; // e.g., theme, icon, trail

  const CosmeticItem({required this.id, required this.name, required this.type});
}

class CosmeticProvider with ChangeNotifier {
  static const _prefsKeyUnlocked = 'cosmetics_unlocked';
  static const _prefsKeyEquipped = 'cosmetics_equipped';

  final List<CosmeticItem> allItems = const [
    CosmeticItem(id: 'theme_neon', name: 'Neon Theme', type: 'theme'),
    CosmeticItem(id: 'theme_cyan', name: 'Cyan Aurora', type: 'theme'),
    CosmeticItem(id: 'trail_spark', name: 'Spark Trail', type: 'trail'),
    CosmeticItem(id: 'icon_crystal', name: 'Crystal Icons', type: 'icon'),
  ];

  Set<String> _unlocked = {};
  Map<String, String> _equippedByType = {};

  Set<String> get unlocked => _unlocked;
  Map<String, String> get equippedByType => _equippedByType;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _unlocked = (prefs.getStringList(_prefsKeyUnlocked) ?? []).toSet();
    final raw = prefs.getString(_prefsKeyEquipped);
    if (raw != null) {
      _equippedByType = Map<String, String>.from(jsonDecode(raw) as Map);
    }
    notifyListeners();
  }

  Future<void> unlock(String id) async {
    _unlocked.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKeyUnlocked, _unlocked.toList());
    notifyListeners();
  }

  Future<void> equip(String id) async {
    final item = allItems.firstWhere((e) => e.id == id);
    _equippedByType[item.type] = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyEquipped, jsonEncode(_equippedByType));
    notifyListeners();
  }

  CosmeticItem? getEquipped(String type) {
    final id = _equippedByType[type];
    if (id == null) return null;
    return allItems.firstWhere((e) => e.id == id, orElse: () => allItems.first);
  }

  CosmeticItem? randomLocked() {
    final remaining = allItems.where((e) => !_unlocked.contains(e.id)).toList();
    if (remaining.isEmpty) return null;
    remaining.shuffle();
    return remaining.first;
  }
}



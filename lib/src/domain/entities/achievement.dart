import 'package:flutter/material.dart';

enum AchievementType {
  streak,
  completion,
  level,
  category,
  perfection,
  consistency,
  firstHabit,
  perfectDays,
  streakFreeze,
}

enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

@immutable
class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final AchievementRarity rarity;
  final int xpReward;
  final String iconData; // Using string for icon data since no assets
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int target;
  final DateTime createdAt;
  final int streakFreezeReward;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.rarity,
    required this.xpReward,
    required this.iconData,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
    required this.target,
    required this.createdAt,
    this.streakFreezeReward = 0,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    AchievementType? type,
    AchievementRarity? rarity,
    int? xpReward,
    String? iconData,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? progress,
    int? target,
    DateTime? createdAt,
    int? streakFreezeReward,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      xpReward: xpReward ?? this.xpReward,
      iconData: iconData ?? this.iconData,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      createdAt: createdAt ?? this.createdAt,
      streakFreezeReward: streakFreezeReward ?? this.streakFreezeReward,
    );
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: AchievementType.values[json['type'] as int],
      rarity: AchievementRarity.values[json['rarity'] as int],
      xpReward: json['xpReward'] as int,
      iconData: json['iconData'] as String,
      isUnlocked: json['isUnlocked'] as bool,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      progress: json['progress'] as int,
      target: json['target'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      streakFreezeReward: json['streakFreezeReward'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.index,
        'rarity': rarity.index,
        'xpReward': xpReward,
        'iconData': iconData,
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
        'progress': progress,
        'target': target,
        'createdAt': createdAt.toIso8601String(),
        'streakFreezeReward': streakFreezeReward,
      };

  double get progressPercentage {
    if (target == 0) return 0.0;
    return (progress / target).clamp(0.0, 1.0);
  }

  bool get isCompleted => progress >= target;

  Color get rarityColor {
    switch (rarity) {
      case AchievementRarity.common:
        return const Color(0xFF9E9E9E); // Grey
      case AchievementRarity.rare:
        return const Color(0xFF2196F3); // Blue
      case AchievementRarity.epic:
        return const Color(0xFF9C27B0); // Purple
      case AchievementRarity.legendary:
        return const Color(0xFFFFC107); // Amber
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.type == type &&
        other.rarity == rarity &&
        other.xpReward == xpReward &&
        other.iconData == iconData &&
        other.isUnlocked == isUnlocked &&
        other.unlockedAt == unlockedAt &&
        other.progress == progress &&
        other.target == target &&
        other.createdAt == createdAt &&
        other.streakFreezeReward == streakFreezeReward;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        type.hashCode ^
        rarity.hashCode ^
        xpReward.hashCode ^
        iconData.hashCode ^
        isUnlocked.hashCode ^
        unlockedAt.hashCode ^
        progress.hashCode ^
        target.hashCode ^
        createdAt.hashCode ^
        streakFreezeReward.hashCode;
  }
}
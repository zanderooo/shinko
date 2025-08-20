import 'package:flutter/foundation.dart';

enum HabitType {
  daily,
  weekly,
  monthly,
  custom,
}

enum HabitCategory {
  health,
  productivity,
  learning,
  fitness,
  mindfulness,
  social,
  finance,
  creativity,
  other,
}

enum HabitDifficulty {
  easy,
  medium,
  hard,
  expert,
}

@immutable
class Habit {
  final String id;
  final String title;
  final String? description;
  final HabitType type;
  final HabitCategory category;
  final HabitDifficulty difficulty;
  final int targetCount;
  final int currentStreak;
  final int bestStreak;
  final int totalCompletions;
  final DateTime createdAt;
  final DateTime? lastCompletedAt;
  final List<int> completionHistory; // List of days since epoch
  final bool isActive;
  final String? reminderTime;
  final int xpValue;
  final int streakFreezes;
  final DateTime? lastStreakFreezeUsed;

  const Habit({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.category,
    required this.difficulty,
    this.targetCount = 1,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalCompletions = 0,
    required this.createdAt,
    this.lastCompletedAt,
    this.completionHistory = const [],
    this.isActive = true,
    this.reminderTime,
    required this.xpValue,
    this.streakFreezes = 0,
    this.lastStreakFreezeUsed,
  });

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    HabitType? type,
    HabitCategory? category,
    HabitDifficulty? difficulty,
    int? targetCount,
    int? currentStreak,
    int? bestStreak,
    int? totalCompletions,
    DateTime? createdAt,
    DateTime? lastCompletedAt,
    List<int>? completionHistory,
    bool? isActive,
    String? reminderTime,
    int? xpValue,
    int? streakFreezes,
    DateTime? lastStreakFreezeUsed,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      targetCount: targetCount ?? this.targetCount,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      createdAt: createdAt ?? this.createdAt,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      completionHistory: completionHistory ?? this.completionHistory,
      isActive: isActive ?? this.isActive,
      reminderTime: reminderTime ?? this.reminderTime,
      xpValue: xpValue ?? this.xpValue,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      lastStreakFreezeUsed: lastStreakFreezeUsed ?? this.lastStreakFreezeUsed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habit &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.type == type &&
        other.category == category &&
        other.difficulty == difficulty &&
        other.targetCount == targetCount &&
        other.currentStreak == currentStreak &&
        other.bestStreak == bestStreak &&
        other.totalCompletions == totalCompletions &&
        other.createdAt == createdAt &&
        other.lastCompletedAt == lastCompletedAt &&
        listEquals(other.completionHistory, completionHistory) &&
        other.isActive == isActive &&
        other.reminderTime == reminderTime &&
        other.xpValue == xpValue;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        type.hashCode ^
        category.hashCode ^
        difficulty.hashCode ^
        targetCount.hashCode ^
        currentStreak.hashCode ^
        bestStreak.hashCode ^
        totalCompletions.hashCode ^
        createdAt.hashCode ^
        lastCompletedAt.hashCode ^
        completionHistory.hashCode ^
        isActive.hashCode ^
        reminderTime.hashCode ^
        xpValue.hashCode ^
        streakFreezes.hashCode ^
        lastStreakFreezeUsed.hashCode;
  }
}
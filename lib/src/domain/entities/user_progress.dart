import 'package:flutter/foundation.dart';

@immutable
class UserProgress {
  final int totalXP;
  final int currentLevel;
  final int xpToNextLevel;
  final int dailyStreak;
  final int bestDailyStreak;
  final int weeklyStreak;
  final int bestWeeklyStreak;
  final int totalHabitsCompleted;
  final int totalPerfectDays;
  final DateTime? lastActiveDate;
  final DateTime createdAt;

  const UserProgress({
    this.totalXP = 0,
    this.currentLevel = 1,
    this.xpToNextLevel = 100,
    this.dailyStreak = 0,
    this.bestDailyStreak = 0,
    this.weeklyStreak = 0,
    this.bestWeeklyStreak = 0,
    this.totalHabitsCompleted = 0,
    this.totalPerfectDays = 0,
    this.lastActiveDate,
    required this.createdAt,
  });

  UserProgress copyWith({
    int? totalXP,
    int? currentLevel,
    int? xpToNextLevel,
    int? dailyStreak,
    int? bestDailyStreak,
    int? weeklyStreak,
    int? bestWeeklyStreak,
    int? totalHabitsCompleted,
    int? totalPerfectDays,
    DateTime? lastActiveDate,
    DateTime? createdAt,
  }) {
    return UserProgress(
      totalXP: totalXP ?? this.totalXP,
      currentLevel: currentLevel ?? this.currentLevel,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      bestDailyStreak: bestDailyStreak ?? this.bestDailyStreak,
      weeklyStreak: weeklyStreak ?? this.weeklyStreak,
      bestWeeklyStreak: bestWeeklyStreak ?? this.bestWeeklyStreak,
      totalHabitsCompleted: totalHabitsCompleted ?? this.totalHabitsCompleted,
      totalPerfectDays: totalPerfectDays ?? this.totalPerfectDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  int get xpForCurrentLevel {
    int xpNeeded = 0;
    for (int level = 1; level < currentLevel; level++) {
      xpNeeded += _calculateXPForLevel(level);
    }
    return xpNeeded;
  }

  static int calculateXPForNextLevel(int level) {
    return 100 + (level * 25);
  }

  int _calculateXPForLevel(int level) {
    return 100 + (level * 25);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProgress &&
        other.totalXP == totalXP &&
        other.currentLevel == currentLevel &&
        other.xpToNextLevel == xpToNextLevel &&
        other.dailyStreak == dailyStreak &&
        other.bestDailyStreak == bestDailyStreak &&
        other.weeklyStreak == weeklyStreak &&
        other.bestWeeklyStreak == bestWeeklyStreak &&
        other.totalHabitsCompleted == totalHabitsCompleted &&
        other.totalPerfectDays == totalPerfectDays &&
        other.lastActiveDate == lastActiveDate &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return totalXP.hashCode ^
        currentLevel.hashCode ^
        xpToNextLevel.hashCode ^
        dailyStreak.hashCode ^
        bestDailyStreak.hashCode ^
        weeklyStreak.hashCode ^
        bestWeeklyStreak.hashCode ^
        totalHabitsCompleted.hashCode ^
        totalPerfectDays.hashCode ^
        lastActiveDate.hashCode ^
        createdAt.hashCode;
  }
}
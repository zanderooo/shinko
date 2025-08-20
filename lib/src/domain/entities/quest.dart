import 'package:flutter/foundation.dart';

enum QuestType {
  completeHabitsTotal,
  completeHabitsBeforeNoon,
  perfectDay,
  streakSave,
}

@immutable
class Quest {
  final String id;
  final DateTime date; // quest day (yyyy-mm-dd)
  final QuestType type;
  final String title;
  final String description;
  final int target;
  final int progress;
  final int rewardXp;
  final bool isCompleted;
  final bool isClaimed;

  const Quest({
    required this.id,
    required this.date,
    required this.type,
    required this.title,
    required this.description,
    required this.target,
    required this.progress,
    required this.rewardXp,
    this.isCompleted = false,
    this.isClaimed = false,
  });

  Quest copyWith({
    String? id,
    DateTime? date,
    QuestType? type,
    String? title,
    String? description,
    int? target,
    int? progress,
    int? rewardXp,
    bool? isCompleted,
    bool? isClaimed,
  }) {
    return Quest(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      rewardXp: rewardXp ?? this.rewardXp,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}



import 'package:flutter/material.dart';
import 'package:shinko/src/domain/entities/quest.dart';
import 'package:shinko/src/presentation/theme/app_theme.dart';

class QuestCard extends StatelessWidget {
  final Quest quest;
  const QuestCard({super.key, required this.quest});

  @override
  Widget build(BuildContext context) {
    final progress = (quest.progress / quest.target).clamp(0.0, 1.0);
    return Container(
      decoration: AppTheme.glassCardDecoration,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: quest.isCompleted ? Colors.green.withValues(alpha: 0.2) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            child: Icon(quest.isCompleted ? Icons.check : Icons.flag, size: 18, color: quest.isCompleted ? Colors.green : Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(quest.title, style: AppTheme.bodyLarge),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(quest.isCompleted ? Colors.green : Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('+${quest.rewardXp} XP', style: AppTheme.caption.copyWith(color: quest.isCompleted ? Colors.green : Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}



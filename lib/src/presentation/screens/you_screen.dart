import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shinko/src/presentation/providers/user_progress_provider.dart';
import 'package:shinko/src/presentation/theme/app_theme.dart';

class YouScreen extends StatelessWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProgressProvider = context.watch<UserProgressProvider>();
    final userProgress = userProgressProvider.userProgress;

    // Collect stats in a data-driven way
    final stats = [
      ('Strength', userProgress.stats.strength, Icons.fitness_center, Colors.red),
      ('Intelligence', userProgress.stats.intelligence, Icons.lightbulb, Colors.blue),
      ('Wisdom', userProgress.stats.wisdom, Icons.book, Colors.purple),
      ('Charisma', userProgress.stats.charisma, Icons.people, Colors.pink),
      ('Dexterity', userProgress.stats.dexterity, Icons.run_circle, Colors.orange),
      ('Luck', userProgress.stats.luck, Icons.casino, Colors.green),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('You'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCharacterHeader(context, userProgressProvider),
            const SizedBox(height: 24),
            Text('Character Stats', style: AppTheme.titleLarge),
            const SizedBox(height: 16),
            // Generate cards from data
            for (final stat in stats)
              _StatCard(
                title: stat.$1,
                value: stat.$2,
                icon: stat.$3,
                color: stat.$4,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterHeader(BuildContext context, UserProgressProvider provider) {
    final userProgress = provider.userProgress;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCardDecoration.copyWith(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withAlpha(102),
            Theme.of(context).colorScheme.primary.withAlpha(51),
            Colors.purple.withAlpha(26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${userProgress.currentLevel}',
                      style: AppTheme.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${userProgress.totalXP} XP',
                      style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            key: ValueKey(provider.levelProgress), // avoid re-animating unnecessarily
            tween: Tween(begin: 0.0, end: provider.levelProgress),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 12,
                      backgroundColor: Colors.white.withAlpha(26),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                      semanticsLabel: 'Level progress bar',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress to Level ${userProgress.currentLevel + 1}',
                        style: AppTheme.caption.copyWith(color: Colors.white70),
                      ),
                      Text(
                        '${(value * 100).toStringAsFixed(0)}%',
                        style: AppTheme.caption.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Extracted Stat Card Widget for clarity
class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final level = value ~/ 100;
    final progress = (value % 100) / 100.0;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.transparent,
      child: Container(
        decoration: AppTheme.glassCardDecoration,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Level $level', style: AppTheme.bodyMedium),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    key: ValueKey(progress), // avoids glitchy re-animation
                    tween: Tween(begin: 0.0, end: progress),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, val, child) {
                      return LinearProgressIndicator(
                        value: val,
                        backgroundColor: color.withAlpha(51),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        semanticsLabel: '$title progress bar',
                      );
                    },
                  ),
                ],
              ),
            ),
            TweenAnimationBuilder<int>(
              key: ValueKey(value), // also avoids weird re-build loop
              tween: IntTween(begin: 0, end: value),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, val, child) {
                return Text(
                  val.toString(),
                  style: AppTheme.titleLarge.copyWith(color: color),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
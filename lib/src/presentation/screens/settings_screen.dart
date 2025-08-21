import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shinko/src/core/services/backup_service.dart';
import 'package:shinko/src/data/datasources/database_helper.dart';
import 'package:shinko/src/presentation/providers/cosmetic_provider.dart';
import 'package:shinko/src/presentation/providers/habit_provider.dart';
import 'package:shinko/src/presentation/providers/motivation_provider.dart';
import 'package:shinko/src/presentation/providers/quest_provider.dart';
import 'package:shinko/src/presentation/providers/tomorrow_message_provider.dart';
import 'package:shinko/src/presentation/providers/user_progress_provider.dart';
import 'package:shinko/src/presentation/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _busy = false;
  String? _lastExportPath;

  Future<void> _exportData() async {
    setState(() => _busy = true);
    try {
      final backup = BackupService(DatabaseHelper.instance);
      final jsonString = await backup.exportToJsonString();

      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${dir.path}/shinko-backup-$timestamp.json');
      await file.writeAsString(jsonString);

      _lastExportPath = file.path;

      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '🌸 Shinkō backup • Keep this file safe!',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Backup exported successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Export failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importData() async {
    final confirmed = await _showConfirmDialog(
      'Import Data',
      'This will replace your current data with a backup.\n\nProceed?',
    );
    if (!confirmed) return;

    setState(() => _busy = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.isEmpty) {
        if (mounted) setState(() => _busy = false);
        return; // cancelled
      }

      final path = result.files.single.path;
      if (path == null) throw 'Invalid file path';

      final jsonString = await File(path).readAsString();
      final backup = BackupService(DatabaseHelper.instance);
      await backup.importFromJsonString(jsonString);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Import complete. Please restart the app.'),
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Import failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetData() async {
    final confirmed = await _showConfirmDialog(
      'Factory Reset',
      'This will delete ALL habits, progress, achievements, quests, cosmetics, and settings.\n\nAre you sure?',
    );
    if (!confirmed) return;

    setState(() => _busy = true);
    try {
      // Clear database tables
      final db = await DatabaseHelper.instance.database;
      await db.delete('habits');
      await db.delete('user_progress');
      await db.delete('achievements');
      
      // Clear ALL SharedPreferences data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // This clears all SharedPreferences data
      
      // Specifically ensure these keys are cleared
      // Cosmetics
      await prefs.remove('cosmetics_unlocked');
      await prefs.remove('cosmetics_equipped');
      
      // Quests
      final questKeys = prefs.getKeys()
          .where((key) => key.startsWith('claimed_chest_'))
          .toList();
      for (final key in questKeys) {
        await prefs.remove(key);
      }
      
      // Motivational quotes
      await prefs.remove('last_quote_date');
      await prefs.remove('last_quote');
      
      // Tomorrow messages
      await prefs.remove('tomorrow_message');
      await prefs.remove('last_message_date');
      
      // Onboarding
      await prefs.remove('onboarding_completed');
      
      // Reset providers
      if (mounted) {
        // Reset all providers
        Provider.of<CosmeticProvider>(context, listen: false).load();
        Provider.of<QuestProvider>(context, listen: false).onHabitsChanged();
        Provider.of<MotivationProvider>(context, listen: false).loadDailyQuote();
        Provider.of<TomorrowMessageProvider>(context, listen: false).loadMessage();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑 App reset complete. Restart the app.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Reset failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton(
                child: const Text('Confirm'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Store Section
              Text(
                'Store',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildStoreSection(),
              const SizedBox(height: 24),
              
              // Backup & Restore Section
              Text(
                'Backup & Restore',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(Icons.upload_file, color: Colors.amber),
                title: const Text('Export to JSON'),
                subtitle: _lastExportPath != null
                    ? Text('Last export: $_lastExportPath',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70))
                    : null,
                onTap: _busy ? null : _exportData,
              ),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.download, color: Colors.lightBlue),
                title: const Text('Import from JSON'),
                onTap: _busy ? null : _importData,
              ),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Factory Reset'),
                onTap: _busy ? null : _resetData,
              ),
            ],
          ),
        ),

        if (_busy)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
  
  Widget _buildStoreSection() {
    final userProgressProvider = Provider.of<UserProgressProvider>(context);
    final coins = userProgressProvider.userProgress.coins;
    
    return Container(
      decoration: AppTheme.glassCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Your Coins: $coins',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Spend your coins on useful items:',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          _buildStoreItem(
            'Streak Freeze',
            'Protects your streak for one day if you miss completing a habit',
            '❄️',
            50,
            () => _purchaseStreakFreeze(1),
            userProgressProvider.canUseCoins(50),
          ),
          const SizedBox(height: 12),
          _buildStoreItem(
            'Streak Freeze Pack',
            'Get 3 streak freezes at a discounted price',
            '❄️❄️❄️',
            120,
            () => _purchaseStreakFreeze(3),
            userProgressProvider.canUseCoins(120),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStoreItem(String title, String description, String icon, 
      int price, VoidCallback onPurchase, bool canAfford) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black26,
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
          Column(
            children: [
              Text('$price 🪙', style: TextStyle(color: canAfford ? Colors.amber : Colors.red)),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: canAfford ? onPurchase : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade700,
                ),
                child: const Text('Buy'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Future<void> _purchaseStreakFreeze(int count) async {
    final userProgressProvider = Provider.of<UserProgressProvider>(context, listen: false);
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    
    final price = count == 1 ? 50 : 120;
    
    if (!userProgressProvider.canUseCoins(price)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough coins!')),
      );
      return;
    }
    
    // Show dialog to select which habit to apply the streak freeze to
    final activeHabits = habitProvider.activeHabits;
    if (activeHabits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You don\'t have any active habits!')),
      );
      return;
    }
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Purchase $count Streak ${count == 1 ? 'Freeze' : 'Freezes'}'),
        content: Text('This will cost $price coins. Do you want to proceed?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text('Confirm'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    ) ?? false;
    
    if (!confirmed) return;
    
    // Deduct coins
    await userProgressProvider.useCoins(price);
    
    // Award streak freezes to all habits
    await userProgressProvider.awardStreakFreezes(count);
    
    setState(() {}); // Refresh UI
  }
}
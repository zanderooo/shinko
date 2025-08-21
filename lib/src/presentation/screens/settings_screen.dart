import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shinko/src/core/services/backup_service.dart';
import 'package:shinko/src/data/datasources/database_helper.dart';

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
      'This will delete ALL habits, progress, and settings.\n\nAre you sure?',
    );
    if (!confirmed) return;

    setState(() => _busy = true);
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('habits');
      await db.delete('user_progress');
      // TODO: Clear any other relevant tables you have

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
}
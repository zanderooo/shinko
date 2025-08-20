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
      final file = File('${dir.path}/shinko-backup-${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);
      _lastExportPath = file.path;

      if (!mounted) return;
      await Share.shareXFiles([XFile(file.path)], text: 'Shinkō backup');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importData() async {
    setState(() => _busy = true);
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      if (result == null || result.files.isEmpty) {
        setState(() => _busy = false);
        return;
      }
      final path = result.files.single.path;
      if (path == null) throw 'No file selected';

      final jsonString = await File(path).readAsString();
      final backup = BackupService(DatabaseHelper.instance);
      await backup.importFromJsonString(jsonString);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import complete. Restart app to ensure consistency.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Backup & Restore', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _busy ? null : _exportData,
              icon: const Icon(Icons.upload_file),
              label: const Text('Export Data (JSON)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _busy ? null : _importData,
              icon: const Icon(Icons.download),
              label: const Text('Import Data (JSON)'),
            ),
            const SizedBox(height: 8),
            if (_lastExportPath != null)
              Text('Last export: $_lastExportPath', style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}



import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:convert';

import '../core/models.dart';
import '../services/parser.dart';
import '../services/analytics.dart';

/// Provider for the currently loaded chat data
final chatDataProvider = StateProvider<ChatData?>((ref) => null);

/// Provider for computed analytics (derived from chat data)
final analyticsProvider = Provider<ChatAnalytics?>((ref) {
  final chatData = ref.watch(chatDataProvider);
  if (chatData == null) return null;
  return ChatAnalytics(chatData);
});

/// Import state for tracking file import progress
enum ImportState { idle, picking, parsing, success, error }

final importStateProvider = StateProvider<ImportState>((ref) => ImportState.idle);
final importErrorProvider = StateProvider<String?>((ref) => null);

/// Request storage permissions (Android only)
Future<bool> _requestPermissions() async {
  if (kIsWeb) return true;
  
  if (Platform.isAndroid) {
    // Check Android version and request appropriate permissions
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }
    
    // Try storage permission first
    var status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    }
    
    // For Android 13+, try media permissions
    final photos = await Permission.photos.request();
    if (photos.isGranted) {
      return true;
    }
    
    // For accessing all files (Downloads folder, etc.)
    final manageStorage = await Permission.manageExternalStorage.request();
    if (manageStorage.isGranted) {
      return true;
    }
    
    return false;
  }
  
  return true;
}

/// Import a chat file
Future<void> importChatFile(WidgetRef ref) async {
  ref.read(importStateProvider.notifier).state = ImportState.picking;
  ref.read(importErrorProvider.notifier).state = null;

  try {
    // ✅ Request permissions first
    if (!kIsWeb) {
      final hasPermission = await _requestPermissions();
      if (!hasPermission) {
        throw Exception(
          'Storage permission required. Please grant permission in Settings.'
        );
      }
    }

    // ✅ Use FileType.any to avoid MIME type filtering issues
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      ref.read(importStateProvider.notifier).state = ImportState.idle;
      return;
    }

    final file = result.files.first;
    final fileName = file.name.toLowerCase();

    // ✅ Manual validation
    if (!fileName.endsWith('.txt') && !fileName.endsWith('.zip')) {
      throw Exception('Please select a .txt or .zip file (WhatsApp export)');
    }

    ref.read(importStateProvider.notifier).state = ImportState.parsing;

    String content;

    if (kIsWeb) {
      if (file.bytes == null) {
        throw Exception('Could not read file');
      }
      content = utf8.decode(file.bytes!);
    } else {
      if (file.path == null) {
        throw Exception('Could not read file');
      }
      content = await File(file.path!).readAsString();
    }

    final chatData = WhatsAppParser.parse(content, file.name);

    if (chatData.messages.isEmpty) {
      throw Exception('No messages found in the file. Please check the file format.');
    }

    ref.read(chatDataProvider.notifier).state = chatData;
    ref.read(importStateProvider.notifier).state = ImportState.success;

  } catch (e) {
    ref.read(importErrorProvider.notifier).state = e.toString();
    ref.read(importStateProvider.notifier).state = ImportState.error;
  }
}

/// Reset the import state and clear data
void resetImport(WidgetRef ref) {
  ref.read(chatDataProvider.notifier).state = null;
  ref.read(importStateProvider.notifier).state = ImportState.idle;
  ref.read(importErrorProvider.notifier).state = null;
}

/// Dashboard tab selection
enum DashboardTab { overview, timeline, emoji, words }

final dashboardTabProvider = StateProvider<DashboardTab>((ref) => DashboardTab.overview);

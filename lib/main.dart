import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme.dart';
import 'pages/import_page.dart';
import 'pages/dashboard_page.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  runApp(
    const ProviderScope(
      child: WhatStatApp(),
    ),
  );
}

class WhatStatApp extends ConsumerWidget {
  const WhatStatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importState = ref.watch(importStateProvider);
    final chatData = ref.watch(chatDataProvider);
    
    return MaterialApp(
      title: 'WhatStat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _getHomePage(importState, chatData != null),
    );
  }
  
  Widget _getHomePage(ImportState state, bool hasData) {
    // Show dashboard if we have data
    if (hasData && state == ImportState.success) {
      return const DashboardPage();
    }
    
    // Otherwise show import page
    return const ImportPage();
  }
}

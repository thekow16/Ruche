import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/providers.dart';
import 'ui/screens/main_menu_screen.dart';
import 'ui/theme.dart';

class HiveApp extends ConsumerStatefulWidget {
  const HiveApp({super.key});

  @override
  ConsumerState<HiveApp> createState() => _HiveAppState();
}

class _HiveAppState extends ConsumerState<HiveApp> {
  @override
  void initState() {
    super.initState();
    // Load persisted meta-progression once at startup.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(metaProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HIVE',
      debugShowCheckedModeBanner: false,
      theme: HiveTheme.build(),
      home: const MainMenuScreen(),
    );
  }
}

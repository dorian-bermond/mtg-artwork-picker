import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/providers.dart';

class App extends ConsumerWidget {
  final GoRouter router;
  const App({super.key, required this.router});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMode = ref.watch(themeModeProvider);
    final themeMode = switch (asyncMode) {
      AsyncData(:final value) => value,
      _ => ThemeMode.system,
    };
    return MaterialApp.router(
      title: 'MTG Artwork Picker',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

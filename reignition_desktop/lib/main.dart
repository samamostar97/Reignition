import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constants/app_theme.dart';
import 'screens/login_screen.dart';
import 'widgets/layout/app_scaffold.dart';

void main() {
  runApp(const ProviderScope(child: ReignitionApp()));
}

class ReignitionApp extends StatelessWidget {
  const ReignitionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reignition Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/dashboard': (_) => const AppScaffold(),
      },
    );
  }
}

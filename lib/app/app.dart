import 'package:flutter/material.dart';
import 'package:hustlehub/app/router/app_router.dart';
import 'package:hustlehub/app/theme/app_theme.dart';

class HustleHubApp extends StatelessWidget {
  const HustleHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HustleHub',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: AppRouter.router,
    );
  }
}

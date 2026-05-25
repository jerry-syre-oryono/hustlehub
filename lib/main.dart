// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hustlehub/app/app.dart';
import 'package:hustlehub/bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Register adapters
  await bootstrap();
  
  runApp(
    const ProviderScope(
      child: HustleHubApp(),
    ),
  );
}

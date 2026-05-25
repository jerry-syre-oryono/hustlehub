// lib/bootstrap.dart
import 'package:hive/hive.dart';
import 'package:hustlehub/core/services/appwrite_service.dart';
import 'package:hustlehub/core/services/notification_service.dart';
import 'package:hustlehub/core/services/storage_service.dart';
import 'package:hustlehub/shared/models/user_model.dart';

Future<void> bootstrap() async {
  // Register Hive adapters
  Hive.registerAdapter(UserModelAdapter());
  
  // Open Hive boxes
  await Hive.openBox('user_cache');
  await Hive.openBox('jobs_cache');
  await Hive.openBox('gigs_cache');
  await Hive.openBox('drafts');
  await Hive.openBox('settings');
  
  // Initialize services
  await AppwriteService.init();
  await NotificationService.init();
  await StorageService.init();
}

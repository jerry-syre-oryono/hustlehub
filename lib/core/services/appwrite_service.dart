// lib/core/services/appwrite_service.dart
import 'package:appwrite/appwrite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppwriteService {
  static late Client client;
  static late Account account;
  static late Databases databases;
  static late Storage storage;
  static late Realtime realtime;
  
  // Only these two constants needed - NO API KEYS
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = 'hustlehub-prod'; // Replace with your project ID
  static const String databaseId = 'hustlehub-db';
  
  static Future<void> init() async {
    client = Client()
        .setEndpoint(endpoint)
        .setProject(projectId);
    
    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
    realtime = Realtime(client);
    
    // Restore session if exists
    const secureStorage = FlutterSecureStorage();
    final session = await secureStorage.read(key: 'session');
    if (session != null && session.isNotEmpty) {
      try {
        client.setSession(session);
      } catch (e) {
        // Invalid session, ignore
      }
    }
  }
  
  static Future<void> setSession(String session) async {
    client.setSession(session);
    const secureStorage = FlutterSecureStorage();
    await secureStorage.write(key: 'session', value: session);
  }
  
  static Future<void> clearSession() async {
    client.setSession('');
    const secureStorage = FlutterSecureStorage();
    await secureStorage.delete(key: 'session');
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';
import 'core/services/supabase_service.dart';
import 'core/services/device_service.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Services
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SupabaseService.instance.initialize();
  await DeviceService.instance.initialize();
  await NotificationService.instance.initialize();
  
  runApp(
    const ProviderScope(
      child: VeltrikApp(),
    ),
  );
}

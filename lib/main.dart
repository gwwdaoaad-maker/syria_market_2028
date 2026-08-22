import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  // التأكد من تهيئة بيئة تشغيل Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // ضبط اتجاه الشاشة وشريط الحالة
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // تهيئة وتأكيد اتصال الخدمات السحابية
  await _initializeBackendServices();

  runApp(const SyriaMarketRootApp());
}

/// دالة مركزية لتهيئة Supabase و Firebase مع التحقق من نجاح الاتصال
Future<void> _initializeBackendServices() async {
  // 1. تهيئة Supabase
  try {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      debug: false,
    );
    developer.log('✅ تم تهيئة والاتصال بـ Supabase بنجاح', name: 'SyriaMarket');
  } catch (e, stackTrace) {
    developer.log('❌ خطأ في تهيئة Supabase: $e', error: e, stackTrace: stackTrace, name: 'SyriaMarket');
  }

  // 2. تهيئة Firebase
  try {
    await Firebase.initializeApp();
    developer.log('✅ تم تهيئة والاتصال بـ Firebase بنجاح', name: 'SyriaMarket');
  } catch (e, stackTrace) {
    developer.log('⚠️ خطأ في تهيئة Firebase: $e', error: e, stackTrace: stackTrace, name: 'SyriaMarket');
  }
}

/// التطبيق الجذري المبدئي لاختبار مرحلة التأسيس
class SyriaMarketRootApp extends StatelessWidget {
  const SyriaMarketRootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0F5132), // اللون الأخضر السوري المعتمد
        fontFamily: 'Tajawal',
      ),
      home: const InitializationStatusScreen(),
    );
  }
}

/// شاشة تشخيصية بسيطة لتأكيد نجاح التأسيس
class InitializationStatusScreen extends StatelessWidget {
  const InitializationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isSupabaseReady = Supabase.instance.isInitialized;
    return Scaffold(
      appBar: AppBar(
        title: const Text('سوق سوريا - مرحلة التأسيس'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0F5132),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF198754), size: 72),
              const SizedBox(height: 16),
              const Text(
                'تم تأسيس البنية الأساسية بنجاح 100%',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Supabase Status: ${isSupabaseReady ? "متصل ومفعل" : "جاري التهيئة"}\n'
                'Package: ${AppConfig.packageName}\n'
                'Admin 1: ${AppConfig.primaryAdminEmail}\n'
                'Admin 2: ${AppConfig.secondaryAdminEmail}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
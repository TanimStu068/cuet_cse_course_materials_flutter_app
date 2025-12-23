import 'package:flutter/material.dart';
import 'core/routing/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ektsbquqghqibjphncnj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrdHNicXVxZ2hxaWJqcGhuY25qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1OTQ2NTMsImV4cCI6MjA3ODE3MDY1M30.3p1JkXDURVPKdXjgp4o5RT0dkDYXmnc7vSnJBjr77Y0',
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CUET CSE Course Material',
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}

import 'package:flutter/material.dart';
import 'colors.dart';
import 'login.dart';
import 'signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homescreen.dart';
import 'auth_wrapper.dart';
import 'welcomescreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const PawPalsApp());
}

class PawPalsApp extends StatelessWidget {
  const PawPalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawPals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.softBlue,
          primary: AppColors.caramel,
          secondary: AppColors.mutedTeal,
        ),
        fontFamily: 'Texturina',
      ),
      home: const AuthWrapper(),
    );
  }
}

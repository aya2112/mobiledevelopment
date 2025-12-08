import 'package:flutter/material.dart';
import 'colors.dart';
import 'login.dart';
import 'signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homescreen.dart';

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
      home: const WelcomeScreen(),
    );
  }
}

// --------WELCOME SCREEN--------
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/pawpals_bg.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
            colorFilter: ColorFilter.mode(
              Color(0x10B67845),
              BlendMode.multiply,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // --- Logo & text ---
              Column(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Image.asset(
                      'assets/images/pawpals_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome to PawPals',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 10, 51, 92),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Find trusted walkers and keep your pup happy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 10, 51, 92),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),

              // --- Buttons ---
              Column(
                children: [
                  SizedBox(
                    width: 230,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 10, 51, 92),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding:
                            const EdgeInsets.symmetric(vertical: 7.0),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const HomeShell(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign Up Now! ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const HomeShell(),
                        ),
                      );
                    },
                    child: const Text(
                      'I already have an account!',
                      style: TextStyle(
                        color: Color.fromARGB(255, 10, 51, 92),
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'colors.dart';
import 'homescreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_wrapper.dart';
import 'welcomescreen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  bool _obscure = false;
  bool _submitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

Future<void> login() async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailCtrl.text.trim(),
      password: _pwdCtrl.text.trim(),
    );
  } catch (e) {
    // Firebase error handling later if needed
  }
}


Future<void> resetPassword() async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: _emailCtrl.text.trim(),
    );
  } catch (e) {
    // (file just has empty catch)
  }
}

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
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Logo ---
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: Image.asset(
                          'assets/images/pawpals_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // --- Email ---
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(
                          fontSize: 16, 
                          color: Color(0xFF333333),
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: AppColors.charcoal),
                          prefixIcon: Icon(Icons.email_outlined, color: AppColors.charcoal),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.charcoal),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please enter your email';
                          }

                          final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                          if (!emailRegex.hasMatch(v)) {
                            return 'Enter a valid email address';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // --- Password ---
                      TextFormField(
                        controller: _pwdCtrl,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(
                            fontSize: 16, color: Color(0xFF333333)),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: AppColors.charcoal),
                          prefixIcon: const Icon(Icons.lock_clock_outlined, color: AppColors.charcoal),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.charcoal),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility : Icons.visibility_off,
                              color: AppColors.charcoal,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // --- Forgot Password ---
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: resetPassword,
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: AppColors.charcoal,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // --- Submit button ---
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 10, 51, 92),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _canSubmit ? _submit : null,
                        child: _submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Log in',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // --- BACK BUTTON (FIXED) ---
            Positioned(
              top: 40,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 28),
                color: AppColors.charcoal,
                onPressed: () {
                  // Check if there's a screen to pop back to
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    // If no screen behind, go to Welcome screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canSubmit =>
      _formKey.currentState?.validate() == true && !_submitting;

  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() => _submitting = true);

    await login();

    if (!mounted) return;

    setState(() => _submitting = false);

    

    Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const AuthWrapper()),
  (route) => false,
);

  }
}
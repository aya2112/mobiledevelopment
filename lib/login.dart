import 'package:flutter/material.dart';
import 'colors.dart';
import 'homescreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  bool _obscure = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
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
            //opacity: 50,
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
                            fontSize: 16, color: Color(0xFF333333)),
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(color: AppColors.charcoal),
                          prefixIcon: Icon(Icons.attach_email_outlined, color: AppColors.charcoal),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.charcoal),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty){
                                  return 'Please enter your username';
                                }
                                if(v.trim().length <7){
                                  return 'UserName is not valid';
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
                          onPressed: () {
                            //  Add forgot password logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Forgot Password pressed')),
                            );
                          },
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
                          backgroundColor: AppColors.charcoal,
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
            
            // --- BACK BUTTON ---
            Positioned(
         top: 40, // Adjusted for status bar
     left: 8,
                            child: IconButton(
           icon: const Icon(Icons.arrow_back, size: 28),
     color: AppColors.charcoal, // Use the primary color
                   onPressed: () {
    Navigator.of(context).pop();
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
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 2)); // simulate API call
    if (!mounted) return;

    if (_submitting) {
      setState(() => _submitting = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in successfully! 🎉')),
      );

      // Navigate to Home Screen after login
      // For now, just pop back to Welcome
      Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const HomeShell()),
);
    }
  }
}

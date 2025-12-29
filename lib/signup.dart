import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'auth_wrapper.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

// Defining the primary color
const Color _kPrimaryColor = Color.fromARGB(255, 10, 51, 92);

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscure = true;
  bool _agreed = false;
  bool _submitting = false;

  // ✅ NEW: role selection
  String _selectedRole = 'user'; // default = dog owner

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // Helper function to create consistent input decoration
  InputDecoration _getInputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      labelStyle: TextStyle(
        color: Colors.grey.shade600,
        fontWeight: FontWeight.bold,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _kPrimaryColor, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      floatingLabelStyle:
          const TextStyle(color: _kPrimaryColor, fontWeight: FontWeight.bold),
      prefixIconColor: _kPrimaryColor,
    );
  }

  Future<void> signUp() async {
    try {
      // 1️⃣ Create the user account
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _pwdCtrl.text.trim(),
      );

      // 2️⃣ Get the newly created user
      User? user = userCredential.user;

      if (user != null) {
        // 3️⃣ Update display name
        await user.updateDisplayName(_nameCtrl.text.trim());
        await user.reload();

        // 4️⃣ ✅ SAVE USER DATA + ROLE IN FIRESTORE
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'role': _selectedRole, // ✅ user OR walker
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 5️⃣ Refresh current user
        await FirebaseAuth.instance.currentUser?.reload();
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle inputTextStyle = TextStyle(
      fontSize: 16,
      color: Color(0xFF333333),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/pawpals_bg.png'),
            fit: BoxFit.cover,
            opacity: 50,
            alignment: Alignment.center,
            colorFilter: ColorFilter.mode(
              Color(0x10B67845),
              BlendMode.multiply,
            ),
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Image.asset(
                          'assets/images/pawpals_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),

                      Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Username
                            TextFormField(
                              controller: _nameCtrl,
                              textInputAction: TextInputAction.next,
                              style: inputTextStyle,
                              decoration:
                                  _getInputDecoration('UserName', Icons.person_outline),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Please enter your username';
                                }
                                if (v.trim().length < 7) {
                                  return 'UserName is too short';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Email
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              style: inputTextStyle,
                              decoration:
                                  _getInputDecoration('Email', Icons.attach_email_outlined),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Enter a valid email';
                                }
                                final re =
                                    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                                if (!re.hasMatch(v)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // ✅ NEW: Role dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              decoration: _getInputDecoration(
                                'Account type',
                                Icons.badge_outlined,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'user',
                                  child: Text('Dog Owner'),
                                ),
                                DropdownMenuItem(
                                  value: 'walker',
                                  child: Text('Walker'),
                                ),
                              ],
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() => _selectedRole = v);
                              },
                            ),
                            const SizedBox(height: 12),

                            // Password
                            TextFormField(
                              controller: _pwdCtrl,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.next,
                              style: inputTextStyle,
                              decoration: _getInputDecoration(
                                'Password',
                                Icons.lock_outline,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: _kPrimaryColor,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                                helperText: 'Min 8 chars, 1 uppercase, 1number',
                                helperStyle:
                                    const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              validator: (v) {
                                if (v == null || v.length < 8) {
                                  return 'Min 8 characters';
                                }
                                if (!RegExp(r'[A-Z]').hasMatch(v)) {
                                  return 'Add an uppercase letter';
                                }
                                if (!RegExp(r'[0-9]').hasMatch(v)) {
                                  return 'Add a number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Confirm password
                            TextFormField(
                              controller: _confirmCtrl,
                              obscureText: _obscure,
                              style: inputTextStyle,
                              decoration: _getInputDecoration(
                                  'Confirm password', Icons.lock_outline),
                              validator: (v) =>
                                  v != _pwdCtrl.text ? 'Passwords dont match' : null,
                            ),
                            const SizedBox(height: 8),

                            // Terms checkbox
                            Row(
                              children: [
                                Checkbox(
                                  value: _agreed,
                                  onChanged: (v) =>
                                      setState(() => _agreed = v ?? false),
                                  activeColor: _kPrimaryColor,
                                ),
                                const Expanded(
                                  child: Text(
                                    'I agree to the Terms & Privacy Policy',
                                    style: TextStyle(
                                      color: _kPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Submit button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kPrimaryColor,
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
                                      'Create account',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Back button
            Positioned(
              top: 8,
              left: 8,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 28),
                  color: _kPrimaryColor,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canSubmit =>
      _formKey.currentState?.validate() == true && _agreed && !_submitting;

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true || !_agreed) return;

    setState(() => _submitting = true);

    try {
      await signUp();
      if (!mounted) return;

      // ✅ for now we still go to HomeShell (next we will route by role)
      Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const AuthWrapper()),
  (route) => false,
);

    } catch (e) {
      // you can show a SnackBar later if you want
    } finally {
      if (!mounted) return;
      setState(() => _submitting = false);
    }
  }
}

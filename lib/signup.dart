import 'package:flutter/material.dart';
import 'homescreen.dart';




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
      prefixIcon: Icon(icon, color: Colors.grey.shade600), // Default icon color
      // New: Set the color of the label text when not focused
      labelStyle: TextStyle(
        color: Colors.grey.shade600, 
        fontWeight: FontWeight.bold // Set bold for all labels
      ), 
      // New: Style the focused border and focused label/icon color
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _kPrimaryColor, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      // New: Set the focused color for the label and icon
      floatingLabelStyle: const TextStyle(color: _kPrimaryColor, fontWeight: FontWeight.bold),
      prefixIconColor: _kPrimaryColor, // Set focused prefix icon color
    );
  }

  @override
  Widget build(BuildContext context) {
    // Defines the style for the text *inside* the form fields
    const TextStyle inputTextStyle = TextStyle(
      fontSize: 16, // Increased font size here
      color: Color(0xFF333333), // Charcoal color for the entered text
    );

    return Scaffold(
      body: Container(
        // background decoration as WelcomeScreen
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
        // Use Stack to layer the back button over the content
        child: Stack(
          children: [
            // --- MAIN CONTENT ---
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- Logo centered at the top ---
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Image.asset(
                          'assets/images/pawpals_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- Form starts here ---
                      Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Full Name
                            TextFormField(
                              controller: _nameCtrl,
                              textInputAction: TextInputAction.next,
                              style: inputTextStyle, // Applied new style
                              decoration: _getInputDecoration('UserName', Icons.person_outline),
                              validator: (v){
                                if (v == null || v.trim().isEmpty){
                                  return 'Please enter your username';
                                }
                                if(v.trim().length < 7){
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
                            style: inputTextStyle, // Applied new style
                            decoration: _getInputDecoration('Email', Icons.attach_email_outlined),
                            validator: (v){
                              if (v == null || v.isEmpty){
                          return 'Enter a valid email';
                              }

                              final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                              if (!re.hasMatch(v)){
                              return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          // Password
                          TextFormField(
                            controller: _pwdCtrl,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.next,
                            style: inputTextStyle, // Applied new style
                            decoration: _getInputDecoration('Password', Icons.lock_outline).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure ? Icons.visibility : Icons.visibility_off,
                                  color: _kPrimaryColor, // Set visibility icon color
                                ),
                                onPressed: () => 
                                setState(() => _obscure = !_obscure),
                              ),
                              helperText: 'Min 8 chars, 1 uppercase, 1number',
                              helperStyle: const TextStyle(fontWeight: FontWeight.bold) // Bold helper text
                            ),
                            validator: (v) {
                              if (v == null || v.length <8){
                                return 'Min 8 characters';
                              }
                              if (!RegExp(r'[A-Z]').hasMatch(v)){
                                return 'Add an uppercase letter';

                              }
                              if (!RegExp(r'[0-9]').hasMatch(v)){
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
                            style: inputTextStyle, // Applied new style
                            decoration: _getInputDecoration('Confirm password', Icons.lock_outline),
                            validator: (v) =>
                                v != _pwdCtrl.text ? 'Passwords dont match' : null,
                          ),
                          const SizedBox(height: 8),

                          // Terms checkbox
                          Row(
                            children: [
                              Checkbox(
                                value: _agreed,
                                onChanged: (v) => setState(() => _agreed = v ?? false),
                                activeColor: _kPrimaryColor, // Set the primary color
                              ),
                              const Expanded(
                                child: Text(
                                  'I agree to the Terms & Privacy Policy',
                                  style: TextStyle(
                                    color: _kPrimaryColor, // Set the primary color
                                    fontWeight: FontWeight.bold, // Set the text to bold
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Submit button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kPrimaryColor, // Set the primary color
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
            // --- BACK BUTTON (Positioned on top of the content) ---
            Positioned(
              top: 8,
              left: 8,
              // Use an IconButton for a standard, touch-friendly back button
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 28),
                  color: _kPrimaryColor, // Use the primary color
                  onPressed: () {
                    // This pops the current route (RegistrationScreen) off the stack, 
                    // revealing the previous screen (WelcomeScreen).
                    Navigator.of(context).pop();
                  },
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
    if (_formKey.currentState?.validate() != true) return; 
    
    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 2)); // simulate API call
    if (!mounted) return;
    
    if (_submitting) {
      setState(() => _submitting = false);
      
      
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const HomeShell()),
);
    }
  }
}

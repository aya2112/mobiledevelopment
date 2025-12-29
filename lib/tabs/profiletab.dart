import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawpals/auth_wrapper.dart'; // Ensure this import path is correct for your project

// ==========================================
// 1. PROFILE TAB (Main Screen)
// ==========================================

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  static const _ink = Color.fromARGB(255, 10, 51, 92);

  User? get user => FirebaseAuth.instance.currentUser;

  String _getUserName() {
    if (user != null && user!.displayName != null && user!.displayName!.isNotEmpty) {
      return user!.displayName!;
    }
    return 'Guest User';
  }

  String _getUserEmail() {
    return user?.email ?? 'guest@example.com';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5E6D3), Color(0xFFEAD5BE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Container(
          color: const Color(0x20B67845),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // --- HEADER ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            shape: BoxShape.circle,
                            border: Border.all(color: _ink.withOpacity(0.08), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _getUserName().isNotEmpty ? _getUserName()[0].toUpperCase() : 'G',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: _ink,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getUserName(),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _ink),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _getUserEmail(),
                          style: TextStyle(fontSize: 14, color: _ink.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // --- DOGS SECTION (Connected to Firestore) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text(
                              'Your dogs',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _ink),
                            ),
                            SizedBox(width: 6),
                            Text('🐕', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // STREAM BUILDER FOR DOGS
                        if (user != null)
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(user!.uid)
                                .collection('dogs')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) return const Text("Error loading dogs");
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              final docs = snapshot.data?.docs ?? [];

                              if (docs.isEmpty) {
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text("No dogs added yet.", style: TextStyle(color: _ink)),
                                );
                              }

                              return SizedBox(
                                height: 160, 
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: docs.length,
                                  itemBuilder: (context, index) {
                                    final data = docs[index].data() as Map<String, dynamic>;
                                    final docId = docs[index].id;
                                    
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: SizedBox(
                                        width: 140, // Fixed width for cards in horizontal list
                                        child: _buildDogCard(
                                          context,
                                          docId,
                                          data['name'] ?? 'Dog',
                                          data['breed'] ?? 'Unknown',
                                          data['age'] ?? '',
                                          Color(data['color'] ?? 0xFFFFE5CC),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 12),
                        
                        // ADD DOG BUTTON
                        InkWell(
                          onTap: () {
                             Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => const AddEditDogScreen())
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _ink.withOpacity(0.2),
                                style: BorderStyle.solid,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add_circle_outline, color: _ink, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Add another dog',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // --- ACCOUNT MENU ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _ink.withOpacity(0.08)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            Icons.edit_outlined,
                            'Edit profile',
                            'Name, photo, contact info',
                            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            Icons.pets_outlined,
                            'Dog profiles',
                            'Manage your dogs',
                            // Reuses the Add/Edit logic but maybe purely for list view
                            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditDogScreen())), 
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            Icons.notifications_outlined,
                            'Notifications',
                            'Push, email & SMS alerts',
                            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            Icons.credit_card_outlined,
                            'Payment methods',
                            'Cards & receipts',
                            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsScreen())),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            Icons.history_outlined,
                            'Booking history',
                            'View past walks',
                            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BookingHistoryScreen())),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // --- LOGOUT ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          foregroundColor: Colors.red[700],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: const Text('Log out', style: TextStyle(fontWeight: FontWeight.w900)),
                              content: const Text('Are you sure you want to log out?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('Log out'),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirm == true) {
                            await FirebaseAuth.instance.signOut();
                            if (!context.mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const AuthWrapper()),
                              (route) => false,
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.logout, size: 20),
                            SizedBox(width: 8),
                            Text('Log out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Updated Dog Card to handle Taps for Editing
  Widget _buildDogCard(BuildContext context, String docId, String name, String breed, String age, Color bgColor) {
    return GestureDetector(
      onTap: () {
        // Navigate to edit screen with existing data
        Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditDogScreen(
          docId: docId,
          initialName: name,
          initialBreed: breed,
          initialAge: age,
          initialColor: bgColor,
        )));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _ink.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(child: Text('🐕', style: TextStyle(fontSize: 28))),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _ink),
            ),
            const SizedBox(height: 4),
            Text(
              breed,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: _ink.withOpacity(0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              age,
              style: TextStyle(fontSize: 11, color: _ink.withOpacity(0.5), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _ink.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _ink, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _ink)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: _ink.withOpacity(0.5))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: _ink.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 70),
      child: Divider(height: 1, color: _ink.withOpacity(0.08)),
    );
  }
}

// ==========================================
// 2. ADD / EDIT DOG SCREEN (New Implementation)
// ==========================================

class AddEditDogScreen extends StatefulWidget {
  final String? docId;
  final String? initialName;
  final String? initialBreed;
  final String? initialAge;
  final Color? initialColor;

  const AddEditDogScreen({
    super.key, 
    this.docId,
    this.initialName,
    this.initialBreed,
    this.initialAge,
    this.initialColor
  });

  @override
  State<AddEditDogScreen> createState() => _AddEditDogScreenState();
}

class _AddEditDogScreenState extends State<AddEditDogScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;
  late Color _selectedColor;

  bool _isLoading = false;

  final List<Color> _colorOptions = [
    const Color(0xFFFFE5CC),
    const Color(0xFFCCE5FF),
    const Color(0xFFFFCCE5),
    const Color(0xFFE5FFCC),
    const Color(0xFFE0E0E0),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _breedController = TextEditingController(text: widget.initialBreed ?? '');
    _ageController = TextEditingController(text: widget.initialAge ?? '');
    _selectedColor = widget.initialColor ?? _colorOptions[0];
  }

  Future<void> _saveDog() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final dogData = {
      'name': _nameController.text.trim(),
      'breed': _breedController.text.trim(),
      'age': _ageController.text.trim(),
      'color': _selectedColor.value, // Save integer value of color
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.docId == null) {
        // Add new
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('dogs')
            .add(dogData);
      } else {
        // Update existing
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('dogs')
            .doc(widget.docId)
            .update(dogData);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteDog() async {
    if (widget.docId == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Dog'),
        content: const Text('Are you sure? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete')
          ),
        ],
      ),
    );

    if (confirm == true) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
         await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('dogs')
            .doc(widget.docId)
            .delete();
         if(mounted) Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 10, 51, 92)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.docId == null ? 'Add New Dog' : 'Edit Dog',
          style: const TextStyle(color: Color.fromARGB(255, 10, 51, 92), fontWeight: FontWeight.bold),
        ),
        actions: [
          if (widget.docId != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteDog,
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Name', _nameController),
              const SizedBox(height: 16),
              _buildTextField('Breed', _breedController),
              const SizedBox(height: 16),
              _buildTextField('Age', _ageController),
              const SizedBox(height: 24),
              const Text('Card Color', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 10, 51, 92))),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _colorOptions.map((c) => GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: _selectedColor == c ? Border.all(color: Colors.black, width: 2) : null,
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 10, 51, 92),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _saveDog,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Dog', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      validator: (v) => v!.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color.fromARGB(255, 10, 51, 92)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}

// ==========================================
// 3. EDIT PROFILE SCREEN (Placeholder)
// ==========================================

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = FirebaseAuth.instance.currentUser?.displayName ?? '';
  }

  Future<void> _updateProfile() async {
    try {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(_nameController.text);
      if(mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!')));
      }
    } catch(e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 10, 51, 92)),
        title: const Text('Edit Profile', style: TextStyle(color: Color.fromARGB(255, 10, 51, 92))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
             TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Display Name',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
             ),
             const SizedBox(height: 20),
             ElevatedButton(
               onPressed: _updateProfile,
               style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 10, 51, 92)),
               child: const Text('Update', style: TextStyle(color: Colors.white)),
             )
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. PAYMENT METHODS SCREEN (Placeholder)
// ==========================================

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 10, 51, 92)),
        title: const Text('Payment Methods', style: TextStyle(color: Color.fromARGB(255, 10, 51, 92))),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.credit_card_off, size: 60, color: Colors.grey),
            SizedBox(height: 10),
            Text('No cards added yet'),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. BOOKING HISTORY SCREEN (Original + Connected)
// ==========================================

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  static const _ink = Color.fromARGB(255, 10, 51, 92);

  @override
  Widget build(BuildContext context) {
    // NOTE: Ideally, fetch this from Firestore too. Kept static for now as requested.
    final bookings = [
      {
        'walker': 'Sarah M.',
        'date': 'Dec 18, 2024',
        'time': '4:00 PM',
        'duration': '30 min',
        'dog': 'Luna',
        'price': 10,
        'status': 'Completed',
        'color': const Color(0xFFFFE5CC),
      },
      // ... (Rest of your dummy data)
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5E6D3), Color(0xFFEAD5BE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Container(
          color: const Color(0x20B67845),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _ink.withOpacity(0.08)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: _ink,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Booking History',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: _ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildBookingCard(context, booking),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, Map<String, dynamic> booking) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('View details for ${booking['walker']}')),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _ink.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: booking['color'],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('🐕', style: TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['walker'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _ink),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${booking['date']} • ${booking['time']}',
                        style: TextStyle(fontSize: 13, color: _ink.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${booking['price']}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _ink),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        booking['status'],
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.green[700]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 6. NOTIFICATIONS SCREEN (Original + Connected)
// ==========================================

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _ink = Color.fromARGB(255, 10, 51, 92);

  final List<Map<String, dynamic>> notifications = [
    {
      'type': 'walk',
      'title': 'Walk completed! 🎉',
      'message': 'Sarah M. completed a 30-min walk with Luna',
      'time': '10 min ago',
      'icon': Icons.check_circle,
      'color': Colors.green,
      'unread': true,
    },
    // ... (Your existing notification data)
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => n['unread'] == true).length;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5E6D3), Color(0xFFEAD5BE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Container(
          color: const Color(0x20B67845),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _ink.withOpacity(0.08)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: _ink,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Notifications',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _ink),
                            ),
                            if (unreadCount > 0)
                              Text(
                                '$unreadCount unread',
                                style: TextStyle(fontSize: 13, color: _ink.withOpacity(0.6)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: notifications.isEmpty
                      ? const Center(child: Text('No notifications'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildNotificationCard(notification),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final bool isUnread = notification['unread'] ?? false;
    // ... (Your card implementation)
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? Colors.white : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(notification['icon'], color: notification['color']),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification['title'], style: const TextStyle(fontWeight: FontWeight.bold, color: _ink)),
                  Text(notification['message'], style: TextStyle(color: _ink.withOpacity(0.7))),
                ],
              ),
            )
          ],
        )
    );
  }
}
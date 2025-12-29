import 'dart:async'; // Required for StreamSubscription
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawpals/booking_confirmation_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookTab extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const BookTab({super.key, this.onNavigateToTab});

  @override
  State<BookTab> createState() => _BookTabState();
}

class _BookTabState extends State<BookTab> {
  static const _ink = Color.fromARGB(255, 10, 51, 92);
  
  String selectedDate = 'Today';
  String selectedDuration = '30 min';
  String selectedTime = '4:00 PM';
  
  List<Map<String, dynamic>> selectedDogs = [];
  List<Map<String, dynamic>> allUserDogs = [];
  bool isLoadingDogs = true;
  StreamSubscription? _dogSubscription; // ✅ Live connection to database

  Map<String, dynamic>? selectedWalker;

  final dates = ['Today', 'Tue 26', 'Wed 27', 'Thu 28'];
  final durations = ['30 min', '45 min', '60 min'];
  final times = ['3:00 PM', '3:30 PM', '4:00 PM', '4:30 PM', '5:00 PM', '5:30 PM'];

  final List<Map<String, dynamic>> availableWalkers = [
    {
      'id': 'hS3nhkZoq2M4whude4Zmzxu7WTH3',
      'name': 'Sarah M.',
      'rating': 4.5,
      'distance': 0.9,
      'price': 20,
      'verified': true,
      'color': Color(0xFFFFE5CC),
    },
    {
      'id': 'walker2_uid',
      'name': 'Michael L.',
      'rating': 4.7,
      'distance': 3.2,
      'price': 21,
      'verified': true,
      'color': Color(0xFFCCE5FF),
    },
    {
      'id': 'walker3_uid',
      'name': 'Emily R.',
      'rating': 4.9,
      'distance': 1.5,
      'price': 25,
      'verified': false,
      'color': Color(0xFFFFCCE5),
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedWalker = availableWalkers.first;
    _setupDogListener(); // ✅ Start listening to changes immediately
  }

  @override
  void dispose() {
    _dogSubscription?.cancel(); // ✅ Clean up listener to prevent memory leaks
    super.dispose();
  }

  // ✅ NEW: Robust Live Listener
  void _setupDogListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("❌ NO USER LOGGED IN");
      setState(() => isLoadingDogs = false);
      return;
    }

    print("✅ LISTENING FOR DOGS FOR USER: ${user.uid}");

    _dogSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('dogs')
        .snapshots()
        .listen((snapshot) {
      
      print("📦 RECEIVED ${snapshot.docs.length} DOGS FROM DB");
      
      final List<Map<String, dynamic>> loadedDogs = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown Dog',
          'breed': data['breed'] ?? '',
          // Handle color safety
          'color': data['color'] is int 
              ? Color(data['color']) 
              : const Color(0xFFFFE5CC),
        };
      }).toList();

      if (mounted) {
        setState(() {
          allUserDogs = loadedDogs;
          isLoadingDogs = false;
          
          // Auto-select first dog if nothing is selected yet
          if (selectedDogs.isEmpty && allUserDogs.isNotEmpty) {
            selectedDogs = [allUserDogs.first];
            print("👉 AUTO-SELECTED: ${allUserDogs.first['name']}");
          }
        });
      }
    }, onError: (error) {
      print("❌ ERROR LOADING DOGS: $error");
      if (mounted) {
        setState(() => isLoadingDogs = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading dogs: $error")),
        );
      }
    });
  }

  String _getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!.split(' ')[0];
    }
    return 'Guest';
  }

  double _calculatePrice() {
    final basePrice = selectedWalker?['price']?.toDouble() ?? 20.0;
    final hours = selectedDuration == '30 min' ? 0.5 : 
                  selectedDuration == '45 min' ? 0.75 : 1.0;
    double total = basePrice * hours;
    if (selectedDogs.length > 1) {
      total += (selectedDogs.length - 1) * 10.0 * hours;
    }
    return total;
  }

  void _showWalkerSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Choose a Walker', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _ink)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: availableWalkers.length,
                itemBuilder: (context, index) {
                  final walker = availableWalkers[index];
                  final isSelected = selectedWalker?['id'] == walker['id'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        setState(() { selectedWalker = walker; });
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: isSelected ? _ink : _ink.withOpacity(0.08), width: isSelected ? 2 : 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(color: walker['color'], borderRadius: BorderRadius.circular(16)),
                              child: const Center(child: Text('🐕', style: TextStyle(fontSize: 28))),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(walker['name'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: _ink)),
                                Text("⭐ ${walker['rating']} • ${walker['distance']} mi away", style: TextStyle(fontSize: 13, color: _ink.withOpacity(0.7))),
                              ]),
                            ),
                            Text("\$${walker['price']}/hr", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _ink)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
                          onPressed: () {
                            if (widget.onNavigateToTab != null) widget.onNavigateToTab!(0);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Book a Walk', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _ink)),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Walker Selection
                        InkWell(
                          onTap: _showWalkerSelection,
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: _ink.withOpacity(0.08)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(
                                    color: selectedWalker?['color'] ?? const Color(0xFFFFE5CC),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(child: Text('🐕', style: TextStyle(fontSize: 28))),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(selectedWalker?['name'] ?? 'Select walker', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _ink)),
                                    if (selectedWalker != null)
                                      Text("⭐ ${selectedWalker!['rating']} • ${selectedWalker!['distance']} mi away", style: TextStyle(fontSize: 13, color: _ink.withOpacity(0.7))),
                                  ]),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 16, color: _ink),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Dogs Section
                        Row(children: const [
                          Text('Your dogs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _ink)),
                          SizedBox(width: 6),
                          Text('🐕', style: TextStyle(fontSize: 16)),
                        ]),
                        const SizedBox(height: 12),
                        
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: _ink.withOpacity(0.08)),
                          ),
                          child: isLoadingDogs 
                          ? const Center(child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator()))
                          : Column(
                            children: [
                              if (allUserDogs.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("No dogs found. Go to Profile to add one!", style: TextStyle(color: _ink)),
                                  ),
                                ),

                              if (selectedDogs.isEmpty && allUserDogs.isNotEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: Text("No dogs selected", style: TextStyle(color: _ink)),
                                ),

                              ...selectedDogs.asMap().entries.map((entry) {
                                int idx = entry.key;
                                Map<String, dynamic> dog = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50, height: 50,
                                        decoration: BoxDecoration(color: dog['color'], borderRadius: BorderRadius.circular(12)),
                                        child: const Center(child: Text('🐕', style: TextStyle(fontSize: 28))),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(dog['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _ink)),
                                      ),
                                      if (selectedDogs.length > 1)
                                        IconButton(
                                          icon: const Icon(Icons.close, size: 20),
                                          color: _ink.withOpacity(0.5),
                                          onPressed: () => setState(() => selectedDogs.removeAt(idx)),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),

                              if (selectedDogs.length < allUserDogs.length)
                                InkWell(
                                  onTap: () => _showAddDogDialog(),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: _ink.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: _ink.withOpacity(0.2), width: 2),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.add_circle_outline, color: _ink, size: 20),
                                        SizedBox(width: 8),
                                        Text('Add another dog', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _ink)),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Date & Time
                        const Text('Choose date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _ink)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: dates.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: _buildChip(dates[index], dates[index] == selectedDate, () => setState(() => selectedDate = dates[index])),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Duration
                        const Text('Duration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _ink)),
                        const SizedBox(height: 12),
                        Row(children: durations.map((d) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _buildChip(d, d == selectedDuration, () => setState(() => selectedDuration = d)),
                        )).toList()),
                        const SizedBox(height: 20),

                        // Price
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5EB).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFFFE5CC), width: 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Estimated total', style: TextStyle(fontSize: 14, color: _ink, fontWeight: FontWeight.w600)),
                              Text('\$${_calculatePrice().toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _ink)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Confirm Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: _ink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            onPressed: () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null && selectedWalker != null && selectedDogs.isNotEmpty) {
                                try {
                                  final dogNames = selectedDogs.map((d) => d['name']).join(', ');
                                  await FirebaseFirestore.instance.collection('walks').add({
                                    'ownerId': user.uid,
                                    'ownerName': _getUserName(),
                                    'walkerId': selectedWalker!['id'],
                                    'walkerName': selectedWalker!['name'],
                                    'dogName': dogNames,
                                    'status': 'scheduled',
                                    'scheduledTime': selectedTime,
                                    'date': selectedDate,
                                    'duration': selectedDuration == '30 min' ? 30 : 60,
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });

                                  if (!mounted) return;
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => BookingConfirmationScreen(
                                      walkerName: selectedWalker!['name'],
                                      date: selectedDate,
                                      time: selectedTime,
                                      duration: selectedDuration,
                                      dogs: selectedDogs.map((d) => d['name'] as String).toList(),
                                      price: _calculatePrice(),
                                      onNavigateToTab: widget.onNavigateToTab,
                                    ),
                                  ));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a dog')));
                              }
                            },
                            child: const Text('Confirm Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddDogDialog() {
    final availableToAdd = allUserDogs.where((dog) {
      return !selectedDogs.any((selected) => selected['id'] == dog['id']);
    }).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add another dog', style: TextStyle(fontWeight: FontWeight.w900, color: _ink)),
        content: availableToAdd.isEmpty 
        ? const Padding(padding: EdgeInsets.all(8.0), child: Text("No other dogs found.", textAlign: TextAlign.center))
        : Column(
          mainAxisSize: MainAxisSize.min,
          children: availableToAdd.map((dog) {
            return ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: dog['color'], borderRadius: BorderRadius.circular(8)),
                child: const Center(child: Text('🐕', style: TextStyle(fontSize: 20))),
              ),
              title: Text(dog['name'], style: const TextStyle(fontWeight: FontWeight.w700, color: _ink)),
              onTap: () {
                setState(() => selectedDogs.add(dog));
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? _ink : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? _ink : _ink.withOpacity(0.15), width: isSelected ? 2 : 1),
        ),
        child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : _ink)),
      ),
    );
  }
}
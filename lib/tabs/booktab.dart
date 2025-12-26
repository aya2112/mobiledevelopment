import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawpals/booking_confirmation_screen.dart';

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
  List<String> selectedDogs = ['Luna'];

  final dates = ['Today', 'Tue 26', 'Wed 27', 'Thu 28'];
  final durations = ['30 min', '45 min', '60 min'];
  final times = ['3:00 PM', '3:30 PM', '4:00 PM', '4:30 PM', '5:00 PM', '5:30 PM'];
  final availableDogs = ['Luna', 'Max', 'Bella', 'Charlie'];

  String _getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!.split(' ')[0];
    }
    return 'Guest';
  }

  double _calculatePrice() {
    final basePrice = 20.0;
    final hours = selectedDuration == '30 min' ? 0.5 : 
                  selectedDuration == '45 min' ? 0.75 : 1.0;
    double total = basePrice * hours;
    if (selectedDogs.length > 1) {
      total += (selectedDogs.length - 1) * 10.0 * hours;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF5E6D3),
              Color(0xFFEAD5BE),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Container(
          color: const Color(0x20B67845),
          child: SafeArea(
            child: Column(
              children: [
                // Custom Header with Back Button
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
                            if (widget.onNavigateToTab != null) {
                              widget.onNavigateToTab!(0); // Navigate to Home tab
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Book a Walk',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: _ink,
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Walk Details Card
                        Container(
                          padding: const EdgeInsets.all(18),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Selected Dogs List
                              ...selectedDogs.asMap().entries.map((entry) {
                                int idx = entry.key;
                                String dog = entry.value;
                                final colors = [
                                  Color(0xFFFFE5CC),
                                  Color(0xFFCCE5FF),
                                  Color(0xFFFFCCE5),
                                  Color(0xFFE5FFCC),
                                ];
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: colors[idx % colors.length],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Center(
                                          child: Text('🐕', style: TextStyle(fontSize: 28)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              dog,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: _ink,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (selectedDogs.length > 1)
                                        IconButton(
                                          icon: const Icon(Icons.close, size: 20),
                                          color: _ink.withOpacity(0.5),
                                          onPressed: () {
                                            setState(() {
                                              selectedDogs.removeAt(idx);
                                            });
                                          },
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),

                              // Add Another Dog Button
                              if (selectedDogs.length < availableDogs.length)
                                InkWell(
                                  onTap: () => _showAddDogDialog(),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: _ink.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
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
                        const SizedBox(height: 20),

                        // Choose Date Section
                        Row(
                          children: const [
                            Text(
                              'Choose date',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: _ink,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text('📅', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: dates.length,
                            itemBuilder: (context, index) {
                              final isSelected = dates[index] == selectedDate;
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: _buildChip(
                                  dates[index],
                                  isSelected,
                                  () => setState(() => selectedDate = dates[index]),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Duration Section
                        Row(
                          children: const [
                            Text(
                              'Duration',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: _ink,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text('⏱️', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        Row(
                          children: durations.map((duration) {
                            final isSelected = duration == selectedDuration;
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: _buildChip(
                                duration,
                                isSelected,
                                () => setState(() => selectedDuration = duration),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Choose Time Section
                        Row(
                          children: const [
                            Text(
                              'Choose time',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: _ink,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text('🕐', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: times.map((time) {
                            final isSelected = time == selectedTime;
                            return _buildChip(
                              time,
                              isSelected,
                              () => setState(() => selectedTime = time),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 30),

                        // Price Summary Card
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5EB).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFFFE5CC), width: 2),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Estimated total',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _ink,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '\$${_calculatePrice().toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: _ink,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$selectedDate • $selectedTime',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _ink.withOpacity(0.7),
                                    ),
                                  ),
                                  Text(
                                    '${selectedDogs.length} dog${selectedDogs.length > 1 ? 's' : ''} • $selectedDuration',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _ink.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Confirm Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _ink,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BookingConfirmationScreen(
        date: selectedDate,
        time: selectedTime,
        duration: selectedDuration,
        dogs: List<String>.from(selectedDogs),
        price: _calculatePrice(),
        onNavigateToTab: widget.onNavigateToTab,
        // walkerName: 'Sarah M.', // optional (it has default)
      ),
    ),
  );
},



                            child: const Text(
                              'Confirm Booking',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
    final availableToAdd = availableDogs.where((dog) => !selectedDogs.contains(dog)).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Add another dog',
          style: TextStyle(fontWeight: FontWeight.w900, color: _ink),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: availableToAdd.map((dog) {
            return ListTile(
              leading: const Text('🐕', style: TextStyle(fontSize: 28)),
              title: Text(
                dog,
                style: const TextStyle(fontWeight: FontWeight.w700, color: _ink),
              ),
              onTap: () {
                setState(() {
                  selectedDogs.add(dog);
                });
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
          color: isSelected 
              ? _ink 
              : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? _ink 
                : _ink.withOpacity(0.15),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: _ink.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : _ink,
          ),
        ),
      ),
    );
  }
}
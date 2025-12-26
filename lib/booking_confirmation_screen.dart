import 'package:flutter/material.dart';


class BookingConfirmationScreen extends StatelessWidget {
  final String date;
  final String time;
  final String duration;
  final List<String> dogs;
  final double price;
  final String walkerName;
  final Function(int)? onNavigateToTab;


  const BookingConfirmationScreen({
    super.key,
    required this.date,
    required this.time,
    required this.duration,
    required this.dogs,
    required this.price,
    this.walkerName = 'Sarah M.',
    this.onNavigateToTab,
  });

  static const _ink = Color.fromARGB(255, 10, 51, 92);

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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Success Animation
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 70,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Success Message
                        const Text(
                          'Walk Booked! 🎉',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: _ink,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Your walk has been confirmed with $walkerName',
                          style: TextStyle(
                            fontSize: 16,
                            color: _ink.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Booking Details Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _ink.withOpacity(0.08)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Text(
                                    'Booking Details',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: _ink,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('📋', style: TextStyle(fontSize: 18)),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Walker Info
                              _buildDetailRow(
                                Icons.person_outline,
                                'Walker',
                                walkerName,
                              ),
                              const Divider(height: 24),

                              // Date & Time
                              _buildDetailRow(
                                Icons.calendar_today_outlined,
                                'Date & Time',
                                '$date at $time',
                              ),
                              const Divider(height: 24),

                              // Duration
                              _buildDetailRow(
                                Icons.access_time_outlined,
                                'Duration',
                                duration,
                              ),
                              const Divider(height: 24),

                              // Dogs
                              _buildDetailRow(
                                Icons.pets_outlined,
                                dogs.length > 1 ? 'Dogs' : 'Dog',
                                dogs.join(', '),
                              ),
                              const Divider(height: 24),

                              // Price
                              _buildDetailRow(
                                Icons.payment_outlined,
                                'Total Price',
                                '\$${price.toStringAsFixed(0)}',
                                isPrice: true,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // What's Next Card
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.blue.shade200, width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.info_outline, color: _ink, size: 22),
                                  SizedBox(width: 8),
                                  Text(
                                    "What's next?",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: _ink,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildNextStepItem(
                                '📧',
                                'You\'ll receive a confirmation email',
                              ),
                              const SizedBox(height: 12),
                              _buildNextStepItem(
                                '⏰',
                                '$walkerName will arrive 5 minutes before $time',
                              ),
                              const SizedBox(height: 12),
                              _buildNextStepItem(
                                '💬',
                                'You can message your walker anytime',
                              ),
                              const SizedBox(height: 12),
                              _buildNextStepItem(
                                '📍',
                                'Track your dog\'s walk in real-time',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Quick Actions
                        Row(
                          children: [
                            Expanded(
                                  child: _buildActionButton(
                              context,
                           '💬 Message Walker',
                            Colors.white,
                            _ink,
                            () {
                                // Close confirmation screen
                              Navigator.of(context).pop();

                             // Switch to Messages tab (index 2)
                             onNavigateToTab?.call(2);
                            },
                         ),
                        ),

                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                context,
                                '📅 Add to Calendar',
                                Colors.white,
                                _ink,
                                () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Added to calendar! 📅')),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
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
                        // Go back to home
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isPrice = false,
  }) {
    return Row(
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
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: _ink.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isPrice ? 20 : 15,
                  fontWeight: isPrice ? FontWeight.w900 : FontWeight.w700,
                  color: _ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextStepItem(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: _ink.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    Color bgColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: _ink.withOpacity(0.2)),
        ),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
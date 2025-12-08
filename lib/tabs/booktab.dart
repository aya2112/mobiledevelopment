import 'package:flutter/material.dart';

class BookTab extends StatefulWidget {
  const BookTab({super.key});

  @override
  State<BookTab> createState() => _BookTabState();
}

class _BookTabState extends State<BookTab> {
  final List<String> _dates = ['Today', 'Tue 26', 'Wed 27', 'Thu 28'];
  final List<int> _durations = [30, 45, 60];
  final List<String> _times = [
    '3:00 PM',
    '3:30 PM',
    '4:00 PM',
    '4:30 PM',
    '5:00 PM',
    '5:30 PM',
  ];

  int _selectedDateIndex = 0;
  int _selectedDuration = 30;
  String _selectedTime = '4:30 PM';

  static const _ink = Color.fromARGB(255, 10, 51, 92);
  static const _brown = Color(0xFF6B3E22);
  static const _teal = Color(0xFF6FB3A9);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        const Text(
          'Book a walk for your pup',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        const SizedBox(height: 16),

        // Date picker
        const _SectionTitle(title: 'Choose date'),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _dates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final selected = index == _selectedDateIndex;
              return _SelectableChip(
                label: _dates[index],
                selected: selected,
                onTap: () {
                  setState(() => _selectedDateIndex = index);
                },
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // Walk details
        const _SectionTitle(title: 'Walk details'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFE9DED0),
                    child: Icon(Icons.pets, color: _ink),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dog', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const Text(
                        'Luna',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _ink,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Change',
                      style: TextStyle(
                        color: _teal,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              const Text(
                'Duration',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: _durations.map((d) {
                  final selected = d == _selectedDuration;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _SelectableChip(
                      label: '$d min',
                      selected: selected,
                      compact: true,
                      onTap: () => setState(() => _selectedDuration = d),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Choose time
        const _SectionTitle(title: 'Choose time'),
        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _times.map((t) {
            final selected = t == _selectedTime;
            return _TimeSlotButton(
              label: t,
              selected: selected,
              onTap: () => setState(() => _selectedTime = t),
            );
          }).toList(),
        ),

        const SizedBox(height: 28),

        // Summary + CTA
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Estimated total', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(
                    '${(_selectedDuration / 10).round() * 2} JOD',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _brown,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_dates[_selectedDateIndex]} · $_selectedTime',
                    style: TextStyle(fontSize: 12, color: _ink.withOpacity(0.7)),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Walk booked (demo) 🐾')),
                  );
                },
                child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  static const _ink = Color.fromARGB(255, 10, 51, 92);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: _ink,
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  static const _ink = Color.fromARGB(255, 10, 51, 92);
  static const _teal = Color(0xFF6FB3A9);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _teal.withOpacity(0.15) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 16,
            vertical: compact ? 8 : 10,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected ? _teal : _ink.withOpacity(0.85),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeSlotButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TimeSlotButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const _ink = Color.fromARGB(255, 10, 51, 92);
  static const _teal = Color(0xFF6FB3A9);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: selected ? _teal : _ink.withOpacity(0.25),
          width: 1.2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: selected ? _teal.withOpacity(0.08) : Colors.white,
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: selected ? _teal : _ink,
        ),
      ),
    );
  }
}

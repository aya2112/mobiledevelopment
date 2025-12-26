import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pawpals/live_tracking_screen.dart';


class MessagesTab extends StatefulWidget {
  const MessagesTab({super.key});

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  static const _ink = Color.fromARGB(255, 10, 51, 92);

  // Demo data (later replace with real booking/walker data)
  bool walkActive = true;
  int walkDuration = 15; // minutes
  String walkerName = "Sarah M.";
  String dogName = "Luna";

  // Chat state
  final TextEditingController _msgCtrl = TextEditingController();
  final List<_ChatItem> _chat = [];

  @override
  void initState() {
    super.initState();

    // Seed demo chat
    _chat.addAll([
      _ChatItem.text("Walk started! Luna is so excited! 🐕", isMe: false, time: "10:00 AM"),
      _ChatItem.photo(isMe: false, time: "10:05 AM"),
      _ChatItem.text("Great! Keep me updated!", isMe: true, time: "10:06 AM"),
      _ChatItem.status("💧 Bathroom break", time: "10:15 AM"),
      _ChatItem.photo(isMe: false, time: "10:20 AM"),
      _ChatItem.text("We're at the park now! Luna made a new friend 🎾", isMe: false, time: "10:21 AM"),
    ]);
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  String _nowLabel() {
    final t = TimeOfDay.now();
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final ap = t.period == DayPeriod.am ? "AM" : "PM";
    return "$h:$m $ap";
  }

  void _sendMessage() {
    final txt = _msgCtrl.text.trim();
    if (txt.isEmpty) return;

    setState(() {
      _chat.add(_ChatItem.text(txt, isMe: true, time: _nowLabel()));
      _msgCtrl.clear();
    });
  }

  void _openLiveTracking() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveTrackingMapScreen(
          walkId: 'demoWalk1',
          walkerName: walkerName,
          dogName: dogName,
        ),
      ),
    );
  }

  void _callWalker() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Call walker"),
        content: Text("Calling $walkerName... (demo)"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _requestPhoto() {
    setState(() {
      _chat.add(_ChatItem.text("Can you send a photo of $dogName? 📸", isMe: true, time: _nowLabel()));
    });
  }

  void _emergency() {
    setState(() {
      _chat.add(_ChatItem.text("Emergency: Please call me ASAP. 🚨", isMe: true, time: _nowLabel()));
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Emergency"),
        content: const Text("We alerted the walker in chat. (demo)"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
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
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text(
                            'Messages',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: _ink,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('💬', style: TextStyle(fontSize: 24)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        walkActive ? 'Walk in progress with $walkerName' : 'Stay connected with your walker',
                        style: TextStyle(
                          fontSize: 14,
                          color: _ink.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Live Walk Status Card
                if (walkActive)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade300,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.directions_walk,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Walk in Progress',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$walkDuration minutes elapsed',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.pets,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                      '📍 Live Location',
                                    Colors.white,
                                   Colors.green[700]!,
                                    () {
                                       Navigator.of(context).push(
                                          MaterialPageRoute(
                                           builder: (_) => LiveTrackingMapScreen(
                                            walkId: "demoWalk1", // demo Firestore doc
                                            walkerName: walkerName,
                                             dogName: dogName,
                                              ),
                                            ),
                                          );
                                         },
                                        ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildActionButton(
                                  '📞 Call',
                                  Colors.white,
                                  Colors.green.shade700,
                                  _callWalker,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Messages + input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Chat header
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFFFFE5CC),
                                child: const Text('🐕', style: TextStyle(fontSize: 24)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      walkerName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: _ink,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          walkActive ? 'On walk' : 'Available',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: _ink.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.videocam_outlined),
                                color: _ink,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      title: const Text("Video call"),
                                      content: Text("Starting video call with $walkerName... (demo)"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        // Messages list
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _chat.length,
                            itemBuilder: (context, i) {
                              final item = _chat[i];
                              if (item.type == "photo") {
                                return _buildPhotoMessage("", item.isMe, item.time);
                              } else if (item.type == "status") {
                                return _buildStatusUpdate(item.text, item.time);
                              } else {
                                return _buildMessage(item.text, item.isMe, item.time);
                              }
                            },
                          ),
                        ),

                        // Quick Actions Bar
                        if (walkActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: _ink.withOpacity(0.05),
                              border: Border(top: BorderSide(color: _ink.withOpacity(0.1))),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildQuickAction('📸', 'Request Photo', _requestPhoto),
                                _buildQuickAction('📍', 'Location', _openLiveTracking),
                                _buildQuickAction('🚨', 'Emergency', _emergency),
                              ],
                            ),
                          ),

                        // Message Input
                        Container(
                          padding: const EdgeInsets.all(16),
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
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: _ink.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: TextField(
                                    controller: _msgCtrl,
                                    onSubmitted: (_) => _sendMessage(),
                                    decoration: InputDecoration(
                                      hintText: 'Type a message...',
                                      hintStyle: TextStyle(
                                        color: _ink.withOpacity(0.5),
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: _ink,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                                  onPressed: _sendMessage,
                                ),
                              ),
                            ],
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

  Widget _buildActionButton(String label, Color bgColor, Color textColor, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildMessage(String text, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? _ink : _ink.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isMe ? Colors.white : _ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: isMe ? Colors.white70 : _ink.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoMessage(String _ignored, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5CC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  '📷\n\nPhoto of Luna',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: _ink),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 11,
                  color: _ink.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusUpdate(String status, String time) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _ink.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              status,
              style: TextStyle(
                fontSize: 13,
                color: _ink.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: _ink.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String emoji, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: _ink.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------- Live Tracking Screen (demo) -----------------
class LiveTrackingScreen extends StatefulWidget {
  final String walkerName;
  final String dogName;

  const LiveTrackingScreen({
    super.key,
    required this.walkerName,
    required this.dogName,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  static const _ink = Color.fromARGB(255, 10, 51, 92);

  // Demo path (moving dot)
  final List<Offset> _path = const [
    Offset(40, 140),
    Offset(80, 120),
    Offset(120, 160),
    Offset(170, 140),
    Offset(220, 170),
    Offset(270, 140),
    Offset(310, 190),
  ];

  int _idx = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _idx = (_idx + 1) % _path.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6D3),
        elevation: 0,
        title: const Text(
          "Live Tracking",
          style: TextStyle(color: _ink, fontWeight: FontWeight.w900),
        ),
        iconTheme: const IconThemeData(color: _ink),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _ink.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_walk, color: _ink),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "${widget.walkerName} is walking ${widget.dogName}",
                      style: const TextStyle(color: _ink, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _ink.withOpacity(0.08)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CustomPaint(
                    painter: _DemoMapPainter(
                      path: _path,
                      position: _path[_idx],
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoMapPainter extends CustomPainter {
  final List<Offset> path;
  final Offset position;

  _DemoMapPainter({required this.path, required this.position});

  @override
  void paint(Canvas canvas, Size size) {
    // Simple “map” background
    final bg = Paint()..color = const Color(0xFFE3F2FD);
    canvas.drawRect(Offset.zero & size, bg);

    // Path line
    final line = Paint()
      ..color = const Color.fromARGB(255, 10, 51, 92).withOpacity(0.25)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final p = Path();
    if (path.isNotEmpty) {
      p.moveTo(path.first.dx, path.first.dy);
      for (final pt in path.skip(1)) {
        p.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(p, line);
    }

    // Moving marker
    final marker = Paint()..color = const Color(0xFF2E7D32);
    canvas.drawCircle(position, 10, marker);

    final ring = Paint()..color = const Color(0xFF2E7D32).withOpacity(0.25);
    canvas.drawCircle(position, 22, ring);
  }

  @override
  bool shouldRepaint(covariant _DemoMapPainter oldDelegate) =>
      oldDelegate.position != position;
}

// ----------------- Chat Model -----------------
class _ChatItem {
  final String type; // "text" | "photo" | "status"
  final String text;
  final bool isMe;
  final String time;

  const _ChatItem._(this.type, this.text, this.isMe, this.time);

  factory _ChatItem.text(String text, {required bool isMe, required String time}) =>
      _ChatItem._("text", text, isMe, time);

  factory _ChatItem.photo({required bool isMe, required String time}) =>
      _ChatItem._("photo", "", isMe, time);

  factory _ChatItem.status(String text, {required String time}) =>
      _ChatItem._("status", text, false, time);
}

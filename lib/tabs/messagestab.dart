import 'package:flutter/material.dart';
import 'package:pawpals/live_tracking_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ==========================================
// 1. MESSAGES TAB 
// ==========================================

class MessagesTab extends StatefulWidget {
  const MessagesTab({super.key});

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  static const _ink = Color.fromARGB(255, 10, 51, 92);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header ---
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: const [
                      Text(
                        '',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w900, color: _ink),
                      ),
                      SizedBox(width: 8),
                      Text('', style: TextStyle(fontSize: 24)),
                    ],
                  ),
                ),

                // --- Active Walk / Chat List ---
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('walks')
                          .where('ownerId', isEqualTo: user.uid)
                          .where('status', isEqualTo: 'active')
                          .limit(1)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        // Check if there is an active walk
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return _buildEmptyState();
                        }

                        // Get Data
                        final walkDoc = snapshot.data!.docs.first;
                        final walk = walkDoc.data() as Map<String, dynamic>;
                        final walkerName = walk['walkerName'] ?? 'Walker';
                        final dogName = walk['dogName'] ?? 'Dog';
                        final walkId = walkDoc.id;

                        return ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 10, left: 4),
                              child: Text(
                                "Active Now",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _ink,
                                    fontSize: 14),
                              ),
                            ),
                            // The Chat Item
                            _buildChatListItem(
                              context: context,
                              name: walkerName,
                              message: "Walk in progress with $dogName...",
                              time: "Now",
                              isOnline: true,
                              onTap: () {
                                // Navigate to Full Screen Chat
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      walkerName: walkerName,
                                      dogName: dogName,
                                      walkId: walkId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
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

  Widget _buildChatListItem({
    required BuildContext context,
    required String name,
    required String message,
    required String time,
    required bool isOnline,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFFFE5CC),
              child: const Text('🐕', style: TextStyle(fontSize: 28)),
            ),
            if (isOnline)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    border: Border.all(color: Colors.white, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: _ink,
          ),
        ),
        subtitle: Text(
          message,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _ink.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: _ink.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mark_chat_read_outlined, size: 60, color: _ink.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            "No active messages",
            style: TextStyle(color: _ink.withOpacity(0.5), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            "Book a walk to start chatting!",
            style: TextStyle(color: _ink.withOpacity(0.4), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. CHAT SCREEN 
// ==========================================

class ChatScreen extends StatefulWidget {
  final String walkerName;
  final String dogName;
  final String walkId;

  const ChatScreen({
    super.key,
    required this.walkerName,
    required this.dogName,
    required this.walkId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _ink = Color.fromARGB(255, 10, 51, 92);
  final TextEditingController _msgCtrl = TextEditingController();
  final List<_ChatItem> _chat = [];

  @override
  void initState() {
    super.initState();
    _loadFakeChatHistory();
  }

  void _loadFakeChatHistory() {
    setState(() {
      _chat.addAll([
        _ChatItem.text("Walk started! ${widget.dogName} is so excited! ", isMe: false, time: "10:00 AM"),
        _ChatItem.photo(isMe: false, time: "10:05 AM"),
        _ChatItem.text("Great! Keep me updated!", isMe: true, time: "10:06 AM"),
        _ChatItem.status("💧 Bathroom break", time: "10:15 AM"),
        _ChatItem.text("We're at the park now! 🎾", isMe: false, time: "10:21 AM"),
      ]);
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final txt = _msgCtrl.text.trim();
    if (txt.isEmpty) return;
    setState(() {
      _chat.add(_ChatItem.text(txt, isMe: true, time: _nowLabel()));
      _msgCtrl.clear();
    });
  }

  String _nowLabel() {
    final t = TimeOfDay.now();
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final ap = t.period == DayPeriod.am ? "AM" : "PM";
    return "$h:$m $ap";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFFFE5CC),
              child: const Text('🐕', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.walkerName,
                  style: const TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Active now',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: _ink),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: _ink),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // QUICK ACTIONS
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction('📸', 'Request Photo', () {
                  setState(() {
                     _chat.add(_ChatItem.text("Can you send a photo? 📸", isMe: true, time: _nowLabel()));
                  });
                }),
                _buildQuickAction('📍', 'Live Location', () {
                   Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LiveTrackingMapScreen(
                        walkId: widget.walkId,
                        walkerName: widget.walkerName,
                        dogName: widget.dogName,
                      ),
                    ),
                  );
                }),
                _buildQuickAction('🚨', 'Emergency', () {
                   setState(() {
                     _chat.add(_ChatItem.text("Emergency! Call me ASAP 🚨", isMe: true, time: _nowLabel()));
                  });
                }),
              ],
            ),
          ),
          
          // MESSAGES
          Expanded(
            child: Container(
              color: const Color(0xFFF5E6D3).withOpacity(0.5),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _chat.length,
                itemBuilder: (context, i) {
                  final item = _chat[i];
                  if (item.type == "photo") return _buildPhotoMessage(item.isMe, item.time);
                  if (item.type == "status") return _buildStatusUpdate(item.text, item.time);
                  return _buildMessage(item.text, item.isMe, item.time);
                },
              ),
            ),
          ),

          // INPUT
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 30), // Extra padding for safe area
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
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
                        hintStyle: TextStyle(color: _ink.withOpacity(0.5)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: _ink,
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
    );
  }

  Widget _buildQuickAction(String emoji, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _ink)),
        ],
      ),
    );
  }

  Widget _buildMessage(String text, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? _ink : Colors.white,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: TextStyle(fontSize: 15, color: isMe ? Colors.white : _ink)),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(fontSize: 11, color: isMe ? Colors.white70 : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoMessage(bool isMe, String time) {
    const String sampleDogPhoto = "https://images.squarespace-cdn.com/content/v1/540f7799e4b0bc67f00d7080/1494510247315-3E99XE9Q1VBZ6BFXK41J/IMG_2318.JPG";

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2)
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 200,
              height: 200, 
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF0F0F0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  sampleDogPhoto,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter, 
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            // 3. Time Label
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 4, top: 4),
              child: Text(
                time,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
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
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text("$status • $time", style: TextStyle(fontSize: 12, color: _ink.withOpacity(0.6))),
      ),
    );
  }
}

// ==========================================
// 3. CHAT MODEL 
// ==========================================

class _ChatItem {
  final String type;
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
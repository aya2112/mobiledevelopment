import 'package:flutter/material.dart';

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
    {
      'type': 'booking',
      'title': 'Booking confirmed',
      'message': 'Your walk is scheduled for today at 4:00 PM',
      'time': '2 hours ago',
      'icon': Icons.calendar_today,
      'color': Colors.blue,
      'unread': true,
    },
    {
      'type': 'message',
      'title': 'New message from Sarah M.',
      'message': 'Luna had a great time at the park! 🐕',
      'time': '3 hours ago',
      'icon': Icons.chat_bubble,
      'color': Colors.purple,
      'unread': false,
    },
    {
      'type': 'payment',
      'title': 'Payment processed',
      'message': 'Your payment of \$20 was successful',
      'time': '1 day ago',
      'icon': Icons.credit_card,
      'color': Colors.orange,
      'unread': false,
    },
    {
      'type': 'reminder',
      'title': 'Upcoming walk reminder',
      'message': 'You have a walk scheduled in 1 hour',
      'time': '1 day ago',
      'icon': Icons.notifications,
      'color': _ink,
      'unread': false,
    },
    {
      'type': 'walker',
      'title': 'Sarah M. is nearby',
      'message': 'Your walker is 5 minutes away',
      'time': '2 days ago',
      'icon': Icons.location_on,
      'color': Colors.red,
      'unread': false,
    },
    {
      'type': 'review',
      'title': 'Leave a review',
      'message': 'How was your walk with Sarah M.?',
      'time': '2 days ago',
      'icon': Icons.star,
      'color': Colors.amber,
      'unread': false,
    },
    {
      'type': 'promo',
      'title': 'Special offer! 🎁',
      'message': 'Get 20% off your next walk',
      'time': '3 days ago',
      'icon': Icons.local_offer,
      'color': Colors.pink,
      'unread': false,
    },
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
                // Custom AppBar
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
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: _ink,
                              ),
                            ),
                            if (unreadCount > 0)
                              Text(
                                '$unreadCount unread',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _ink.withOpacity(0.6),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (unreadCount > 0)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              for (var notification in notifications) {
                                notification['unread'] = false;
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Marked all as read')),
                            );
                          },
                          child: Text(
                            'Mark all read',
                            style: TextStyle(
                              color: _ink.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Notifications List
                Expanded(
                  child: notifications.isEmpty
                      ? _buildEmptyState()
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

    return Dismissible(
      key: Key(notification['title'] + notification['time']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          notifications.remove(notification);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          setState(() {
            notification['unread'] = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening: ${notification['title']}')),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUnread
                ? Colors.white
                : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isUnread
                  ? (notification['color'] as Color).withOpacity(0.3)
                  : _ink.withOpacity(0.08),
              width: isUnread ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (notification['color'] as Color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification['icon'],
                  color: notification['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                              color: _ink,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: notification['color'],
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification['message'],
                      style: TextStyle(
                        fontSize: 13,
                        color: _ink.withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: _ink.withOpacity(0.4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          notification['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: _ink.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _ink.withOpacity(0.08),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 60,
              color: _ink,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: _ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: _ink.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
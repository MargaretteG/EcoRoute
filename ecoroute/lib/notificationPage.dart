import 'package:ecoroute/widgets/emptyPage.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      // {
      //   // 'icon': Icons.shopping_bag,
      //   // 'title': 'Product Ready',
      //   // 'description': 'Your product is now ready for pickup!',
      //   // 'time': 'Just now',
      // },
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 255, 240),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          backgroundColor: const Color(0xFF011901),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Container(
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: notifications.isEmpty
            ? EmptyState(
                imagePath: 'images/15.png',
                title: "No Notifications",
                description:
                    "Your Notification Page is as clear as the day! New notifications will appear here.",
                centerVertically: true,
              )
            : ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return _buildNotificationCard(
                    icon: notif['icon'],
                    title: notif['title'],
                    description: notif['description'],
                    time: notif['time'],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String description,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF143D15).withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF143D15).withOpacity(0.2),
            radius: 28,
            child: Icon(icon, color: const Color(0xFF143D15), size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

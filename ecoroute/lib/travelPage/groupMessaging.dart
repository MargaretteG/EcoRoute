import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GroupChatPage extends StatefulWidget {
  final String groupName;
  final Color bgColor;
  final List<Map<String, dynamic>> members;

  const GroupChatPage({
    super.key,
    required this.groupName,
    required this.bgColor,
    required this.members,
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'Alex Johnson',
      'avatar': 'https://i.pravatar.cc/150?img=1',
      'message': 'Hey team! Excited for our travel next week 🌴',
      'timestamp': DateTime.now().subtract(
        const Duration(hours: 3, minutes: 15),
      ),
    },
    {
      'sender': 'You',
      'avatar': '',
      'message': 'Same here! We should finalize our itinerary soon ✈️',
      'timestamp': DateTime.now().subtract(
        const Duration(hours: 3, minutes: 10),
      ),
    },
    {
      'sender': 'Sophie Chen',
      'avatar': 'https://i.pravatar.cc/150?img=4',
      'message': 'Agreed! I can help with that later today.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 25)),
    },
    {
      'sender': 'You',
      'avatar': '',
      'message': 'Perfect 😄 I’ll share the updated plan later.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 20)),
    },
  ];

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'sender': 'You',
        'avatar': '',
        'message': text,
        'timestamp': DateTime.now(),
      });
    });

    _messageController.clear();
  }

  bool _shouldShowTimestamp(int index) {
    if (index == 0) return true;
    final current = _messages[index]['timestamp'] as DateTime;
    final prev = _messages[index - 1]['timestamp'] as DateTime;
    return current.difference(prev).inHours >= 1;
  }

  // --- COLOR HELPERS ---
  Color getDarkerColor(Color color, [double amount = 0.2]) {
    final hsl = HSLColor.fromColor(color);
    final darker = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darker.toColor();
  }

  Color getDarkestColor(Color color) => Color.lerp(color, Colors.black, 0.3)!;

  Color getLighterColor(Color color) => Color.lerp(color, Colors.white, 0.6)!;

  Color getLightestColor(Color color) => Color.lerp(color, Colors.white, 0.9)!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
          decoration: BoxDecoration(
            color: (widget.bgColor),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CircleAvatar(
                    backgroundColor: getDarkerColor(widget.bgColor),
                    radius: 18,
                    child: Icon(
                      Icons.group_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      widget.groupName,

                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 15,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isMe = msg['sender'] == 'You';
                  final showTime = _shouldShowTimestamp(index);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showTime)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(
                              DateFormat(
                                'MMM d, h:mm a',
                              ).format(msg['timestamp']),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isMe)
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(msg['avatar']),
                            ),
                          if (!isMe) const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? getDarkestColor(
                                        widget.bgColor.withOpacity(0.85),
                                      )
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(15),
                                  topRight: const Radius.circular(15),
                                  bottomLeft: Radius.circular(isMe ? 15 : 3),
                                  bottomRight: Radius.circular(isMe ? 3 : 15),
                                ),
                              ),
                              child: Text(
                                msg['message'],
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          if (isMe) const SizedBox(width: 8),
                          // if (isMe)
                          //   const CircleAvatar(
                          //     radius: 16,
                          //     backgroundColor: Color(0xFF011901),
                          //     child: Icon(
                          //       Icons.person,
                          //       size: 16,
                          //       color: Colors.white,
                          //     ),
                          //   ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: widget.bgColor.withOpacity(0.4),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: widget.bgColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: widget.bgColor,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
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
}

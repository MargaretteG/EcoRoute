import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TravelContainer extends StatelessWidget {
  final String title;
  final String date;
  final Color iconBackgroundColor;
  final int travelId;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? type;
  final List<String>? memberImages;

  const TravelContainer({
    super.key,
    required this.title,
    required this.date,
    required this.iconBackgroundColor,
    required this.travelId,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.type,
    this.memberImages,
  });

  Color _getLighterColor(Color color) {
    return Color.lerp(color, Colors.white, 0.7)!;
  }

  Color _getDarkerColor(Color color) {
    return Color.lerp(color, const Color.fromARGB(255, 0, 0, 0), 0.2)!;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: _getLighterColor(iconBackgroundColor),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 7,
                offset: const Offset(6, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getDarkerColor(iconBackgroundColor),
                ),
                child: Icon(
                  Icons.wallet_travel_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE
                    Text(
                      title.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF011901),
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // DATE ROW
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          size: 16,
                          color: Color.fromARGB(157, 1, 25, 1),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: const TextStyle(
                            color: Color.fromARGB(157, 1, 25, 1),
                            fontWeight: FontWeight.w100,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    // MEMBER CIRCLES for GROUP TRAVEL
                    if (type == "GroupTravel" &&
                        memberImages != null &&
                        memberImages!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // show up to 4 members
                          for (
                            int i = 0;
                            i < memberImages!.length && i < 4;
                            i++
                          ) ...[
                            Container(
                              width: 26,
                              height: 26,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: iconBackgroundColor,
                                  width: 1.5,
                                ),
                                image: DecorationImage(
                                  image: memberImages![i].startsWith('http')
                                      ? NetworkImage(memberImages![i])
                                      : const AssetImage(
                                              'images/profile_picture.png',
                                            )
                                            as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                          if (memberImages!.length > 4)
                            Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: iconBackgroundColor,
                              ),
                              child: Text(
                                '+${memberImages!.length - 4}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  FontAwesomeIcons.ellipsisVertical,
                  size: 16,
                  color: Color(0xFF011901),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit?.call();
                  } else if (value == 'delete') {
                    onDelete?.call();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

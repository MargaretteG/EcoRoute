import 'package:flutter/material.dart';

class TravelHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool showBottomRow;
  final VoidCallback? onIconTap;
  final bool isIconActive;

  const TravelHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBottomRow = true,
    this.onIconTap,
    this.isIconActive = false,
  });

  @override
  State<TravelHeader> createState() => _TravelHeaderState();
}

class _TravelHeaderState extends State<TravelHeader>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.95);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white, thickness: 0.3),
          if (widget.showBottomRow)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: widget.onIconTap,
                      onTapDown: _onTapDown,
                      onTapUp: _onTapUp,
                      onTapCancel: _onTapCancel,
                      child: AnimatedScale(
                        scale: _scale,
                        duration: const Duration(milliseconds: 100),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.playlist_add_circle_rounded,
                            color: widget.isIconActive
                                ? Colors.orange
                                : Colors.white,
                            size: 70,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
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

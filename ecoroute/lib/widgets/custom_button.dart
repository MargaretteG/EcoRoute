import 'package:flutter/material.dart';

class LngButton extends StatelessWidget {
  final String text;
  final bool isOrange;
  final bool resize;
  final VoidCallback onPressed;
  final Widget? icon;

  const LngButton({
    super.key,
    required this.text,
    required this.isOrange,
    required this.onPressed,
    this.icon,
    this.resize = false,
  });

  factory LngButton.icon({
    Key? key,
    required String text,
    required bool isOrange,
    required VoidCallback onPressed,
    required Widget icon,
    bool resize = false,
  }) {
    return LngButton(
      key: key,
      text: text,
      isOrange: isOrange,
      onPressed: onPressed,
      icon: icon,
      resize: resize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = isOrange
        ? const Color(0xFFFF9616)
        : const Color(0xFF003F0C);

    return Padding(
      padding: resize
          ? const EdgeInsets.symmetric(horizontal: 25)
          : EdgeInsets.zero,
      child: SizedBox(
        width: resize ? null : MediaQuery.of(context).size.width * 0.70,
        height: 45,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            padding: resize ? const EdgeInsets.symmetric(horizontal: 25) : null,
          ),
          child: icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon!,
                    const SizedBox(width: 10),
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 17.5,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isFilled;
  final bool isSelected;
  final VoidCallback onTap;
  final bool useSheerBackground;

  const CategoryButton({
    super.key,
    required this.text,
    required this.icon,
    required this.isFilled,
    required this.isSelected,
    required this.onTap,
    this.useSheerBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color orange = const Color(0xFFFF9616);
    final Color green = const Color(0xFF003F0C);

    // Background color logic
    final Color bgColor = isFilled
        ? (isSelected ? orange : green)
        : (useSheerBackground
              ? (isSelected
                    ? Color.fromARGB(162, 255, 150, 22)
                    : Colors.transparent)
              : Colors.transparent);

    // Border logic
    final Color borderColor = isFilled
        ? Colors.transparent
        : (isSelected
              ? orange
              : const Color.fromARGB(255, 255, 255, 255).withOpacity(0.7));

    final Color iconTextColor = isFilled
        ? Colors.white
        : (useSheerBackground
              ? (isSelected ? Colors.white : orange)
              : (isSelected ? orange : Colors.white));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          side: BorderSide(color: borderColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconTextColor, size: 20),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: iconTextColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FloatingBtn extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color auraColor;
  final VoidCallback onPressed;

  const FloatingBtn({
    super.key,
    required this.icon,
    this.iconColor = const Color(0xFF64F67A),
    this.auraColor = const Color.fromARGB(255, 255, 146, 14),
    required this.onPressed,
  });

  @override
  State<FloatingBtn> createState() => _FloatingBtnState();
}

class _FloatingBtnState extends State<FloatingBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shadowAnimation;
  late Animation<double> _moveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _shadowAnimation = Tween<double>(
      begin: 6,
      end: 20,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _moveAnimation = Tween<double>(
      begin: -5,
      end: 5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _moveAnimation.value),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.auraColor.withOpacity(0.7),
                  blurRadius: _shadowAnimation.value,
                  spreadRadius: _shadowAnimation.value / 2,
                ),
              ],
            ),
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF003F0C),
              shape: const CircleBorder(),
              onPressed: widget.onPressed,
              child: Icon(widget.icon, color: widget.iconColor),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

class FlickerImageLoader extends StatefulWidget {
  final String imagePath;
  const FlickerImageLoader({super.key, required this.imagePath});

  @override
  State<FlickerImageLoader> createState() => _FlickerImageLoaderState();
}

class _FlickerImageLoaderState extends State<FlickerImageLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Image.asset(widget.imagePath, height: 200),
    );
  }
}

class _FlickerPlaceholder extends StatefulWidget {
  const _FlickerPlaceholder();

  @override
  State<_FlickerPlaceholder> createState() => _FlickerPlaceholderState();
}

class _FlickerPlaceholderState extends State<_FlickerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _opacity = Tween<double>(
      begin: 0.5,
      end: 1.0,
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
      animation: _opacity,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Image.asset(
            'images/image_load.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      },
    );
  }
}

// 👇 Add this at the bottom of your file (outside other classes)
class FlickerPlaceholder extends _FlickerPlaceholder {
  const FlickerPlaceholder();
}

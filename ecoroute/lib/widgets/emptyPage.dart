import 'package:flutter/material.dart';

Widget EmptyState({
  required String imagePath,
  required String title,
  required String description,
  bool centerVertically = true,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: centerVertically
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        Image.asset(imagePath, height: 200),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF011901),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    ),
  );
}

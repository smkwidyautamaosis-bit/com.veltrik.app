import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GeometricBackground extends StatelessWidget {
  final Widget child;

  const GeometricBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: const BoxDecoration(
              color: AppColors.shapeAccent,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: const BoxDecoration(
              color: AppColors.shapeAccent,
              shape: BoxShape.circle,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

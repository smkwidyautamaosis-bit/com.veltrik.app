import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Display / App Name: Inter Bold, 32sp, White
  static const TextStyle display = TextStyle(
    fontFamily: 'Inter',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // Heading H1: Inter SemiBold, 24sp, White
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Heading H2: Inter SemiBold, 20sp, White
  static const TextStyle h2 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body Regular: Calibri / Roboto, 14sp, #9CA3AF
  static const TextStyle bodyRegular = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecond,
  );

  // Body Emphasis: Roboto Medium, 14sp, White
  static const TextStyle bodyEmphasis = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Caption / Label: Roboto, 12sp, #6B7280
  static const TextStyle caption = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // Code / Invite Code: Courier New / RobotoMono, 16sp
  static const TextStyle code = TextStyle(
    fontFamily: 'RobotoMono',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 2.0,
  );

  // Button: Roboto Medium, 15sp, White
  static const TextStyle button = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
}

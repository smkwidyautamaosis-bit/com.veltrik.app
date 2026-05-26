import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Display / App Name: Plus Jakarta Sans Bold, 32sp
  static final TextStyle display = GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  // Heading H1: Plus Jakarta Sans Bold, 24sp
  static final TextStyle h1 = GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // Heading H2: Plus Jakarta Sans SemiBold, 20sp
  static final TextStyle h2 = GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body Regular: Plus Jakarta Sans, 14sp, Slate Gray
  static final TextStyle bodyRegular = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecond,
  );

  // Body Emphasis: Plus Jakarta Sans Medium, 14sp
  static final TextStyle bodyEmphasis = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Caption / Label: Plus Jakarta Sans, 12sp, Muted
  static final TextStyle caption = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // Code / Invite Code: RobotoMono, 16sp
  static final TextStyle code = TextStyle(
    fontFamily: 'RobotoMono',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 2.0,
  );

  // Button: Plus Jakarta Sans SemiBold, 15sp
  static final TextStyle button = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

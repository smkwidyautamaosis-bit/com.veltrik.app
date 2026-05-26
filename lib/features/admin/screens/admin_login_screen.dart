import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _pinController = TextEditingController();
  bool _obscure = true;

  void _login() {
    if (_pinController.text == '7777') {
      context.go('/admin/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: AppColors.danger, content: Text('PIN Salah')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        title: Text('Admin Access', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_rounded, size: 72, color: AppColors.accentBlue),
            ),
            const SizedBox(height: 12),
            Text(
              'Admin Panel',
              style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Masukkan PIN untuk melanjutkan',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecond),
            ),
            const SizedBox(height: 48),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: _obscure,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '••••',
                hintStyle: GoogleFonts.plusJakartaSans(letterSpacing: 8, color: AppColors.textMuted, fontSize: 24),
                fillColor: AppColors.bgPrimary,
                filled: true,
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _login,
                child: Text('Masuk ke Dashboard', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

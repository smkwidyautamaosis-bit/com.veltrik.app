import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class InviteCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    
    if (text.startsWith('VLTK')) {
      text = text.substring(4);
    }

    String formatted = 'VLTK-';
    for (int i = 0; i < text.length; i++) {
      if (i == 4) formatted += '-';
      formatted += text[i];
    }

    if (formatted.length > 14) {
      formatted = formatted.substring(0, 14);
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _codeController = TextEditingController();
  int _tapCount = 0;

  void _handleTap() {
    _tapCount++;
    if (_tapCount >= 5) {
      _tapCount = 0;
      context.go('/admin/login');
    }
  }

  void _handleLogin() async {
    final code = _codeController.text;
    if (code.length < 14) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: AppColors.danger, content: Text('Format kode tidak valid')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).login(
      code,
      onFirstLogin: (isFirst) {
        if (!mounted) return;
        if (isFirst) {
          context.go('/first-notice');
        } else {
          context.go('/app/library');
        }
      },
    );

    if (!success && mounted) {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.danger, content: Text(error ?? 'Login gagal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Logo
                GestureDetector(
                  onTap: _handleTap,
                  child: Image.asset('assets/images/logo.png', width: 120, fit: BoxFit.contain),
                ),
                const SizedBox(height: 12),
                Text(
                  'Veltrik',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Exclusive Content Platform',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecond),
                ),

                const Spacer(),

                // Login Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Masuk dengan Kode Akses',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Masukkan kode undangan Anda untuk masuk',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecond),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _codeController,
                        enabled: !isLoading,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary, letterSpacing: 2,
                        ),
                        textCapitalization: TextCapitalization.characters,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'VLTK-XXXX-XXXX',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 16, color: AppColors.textMuted, letterSpacing: 2,
                          ),
                          fillColor: AppColors.bgSurface,
                          filled: true,
                        ),
                        inputFormatters: [InviteCodeFormatter()],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          child: isLoading
                              ? const SizedBox(
                                  height: 22, width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                )
                              : Text(
                                  'Masuk',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  'Akses pribadi. Harap jaga kerahasiaan kode Anda.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

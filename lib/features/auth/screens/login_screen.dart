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
        child: CustomScrollView(
          slivers: [
            // Login Form Area & Original Top Section
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    
                    // Logo (with hidden admin access)
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentBlue.withValues(alpha: 0.12),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.bgSurface,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.key_rounded, color: AppColors.accentBlue, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Masuk dengan Kode Akses',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Masukkan kode undangan Anda',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecond),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Input Field
                          TextField(
                            controller: _codeController,
                            enabled: !isLoading,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16, fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary, letterSpacing: 2,
                            ),
                            textCapitalization: TextCapitalization.characters,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'VLTK-XXXX-XXXX',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 16, color: AppColors.textMuted, letterSpacing: 2,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: const Icon(Icons.confirmation_num_outlined, color: AppColors.textMuted),
                              suffixIcon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.textMuted),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.5), width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 20),
                            ),
                            inputFormatters: [InviteCodeFormatter()],
                          ),
                          const SizedBox(height: 20),

                          // Login Button (Gradient & Arrow)
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [AppColors.accentRoyal, AppColors.accentBlue],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentBlue.withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                )
                              ]
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: isLoading ? null : _handleLogin,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 48), // balance space
                                      Expanded(
                                        child: Center(
                                          child: isLoading
                                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                              : Text(
                                                  'Masuk',
                                                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                                                ),
                                        ),
                                      ),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.arrow_forward_rounded, color: AppColors.accentBlue),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Security Pill
                    Container(
                      margin: const EdgeInsets.only(top: 24, bottom: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentBlue.withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield_rounded, color: AppColors.accentBlue, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Akses pribadi. Harap jaga kerahasiaan.',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

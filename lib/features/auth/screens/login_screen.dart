import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgPrimary, Color(0xFF0D1F3C)],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _handleTap,
              child: Image.asset(
                'assets/images/logo.png',
                width: 150,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Exclusive Content Platform', style: AppTextStyles.bodyRegular),
            const SizedBox(height: 48),
            TextField(
              controller: _codeController,
              enabled: !isLoading,
              style: AppTextStyles.code,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                hintText: 'VLTK-XXXX-XXXX',
              ),
              inputFormatters: [
                InviteCodeFormatter(),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleLogin,
                child: isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Masuk'),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Akses pribadi. Harap jaga kerahasiaan kode Anda.', style: AppTextStyles.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

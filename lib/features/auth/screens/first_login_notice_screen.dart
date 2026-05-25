import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/device_service.dart';

class FirstLoginNoticeScreen extends StatelessWidget {
  const FirstLoginNoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceName = DeviceService.instance.deviceName;

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield, size: 80, color: AppColors.accentBlue),
            const SizedBox(height: 32),
            const Text('Perangkat Terdaftar', style: AppTextStyles.h1),
            const SizedBox(height: 16),
            const Text(
              'Akun Anda kini terikat pada perangkat ini. Akses hanya dapat dilakukan dari perangkat yang sama.',
              style: AppTextStyles.bodyRegular,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.smartphone, color: AppColors.textSecond),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      deviceName,
                      style: AppTextStyles.bodyEmphasis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/app/library');
                },
                child: const Text('Mengerti, Lanjutkan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

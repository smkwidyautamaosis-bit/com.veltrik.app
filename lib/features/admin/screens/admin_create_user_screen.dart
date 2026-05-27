import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/date_utils.dart';

class AdminCreateUserScreen extends StatefulWidget {
  const AdminCreateUserScreen({super.key});

  @override
  State<AdminCreateUserScreen> createState() => _AdminCreateUserScreenState();
}

class _AdminCreateUserScreenState extends State<AdminCreateUserScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  int _expiresDays = 365;
  bool _isLoading = false;
  String? _generatedCode;
  String? _generatedName;
  String? _expiresAt;

  Future<void> _generate() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Full Name is required')));
      return;
    }

    setState(() {
      _isLoading = true;
      _generatedCode = null; // Clear previous code
    });

    try {
      final response = await SupabaseService.instance.client.functions.invoke(
        'generate-invite-code',
        body: {
          'full_name': _nameController.text.trim(),
          'email': _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
          'expires_days': _expiresDays,
        },
      );
      
      if (response.status == 200 || response.status == 201) {
        final data = response.data;
        if (data != null && data['success'] == true) {
          setState(() {
            _generatedCode = data['invite_code'];
            _generatedName = _nameController.text.trim();
            // Compute expires_at from expires_days
            final expiresDate = DateTime.now().add(Duration(days: _expiresDays));
            _expiresAt = AppDateUtils.toWIBDateOnly(expiresDate);
            _nameController.clear();
            _emailController.clear();
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code generated successfully!')));
          }
        } else {
          throw Exception(data?['error'] ?? 'Unknown response format');
        }
      } else {
        throw Exception('Function failed with status: ${response.status}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to generate code: $e'),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 4),
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        title: Text('Buat User Baru', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.accentBlue, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text('Kode undangan akan digenerate secara otomatis dan dapat digunakan user untuk masuk.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.accentBlue))),
              ]),
            ),
            const SizedBox(height: 24),
            Text('Nama Lengkap *', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecond)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Nama lengkap member...'),
            ),
            const SizedBox(height: 16),
            Text('Email (Opsional)', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecond)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(hintText: 'email@example.com'),
            ),
            const SizedBox(height: 16),
            Text('Durasi Keanggotaan', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecond)),
            const SizedBox(height: 8),
            InputDecorator(
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _expiresDays,
                  isDense: true,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textPrimary),
                  items: const [
                    DropdownMenuItem(value: 30, child: Text('1 Bulan (30 Hari)')),
                    DropdownMenuItem(value: 90, child: Text('3 Bulan (90 Hari)')),
                    DropdownMenuItem(value: 180, child: Text('6 Bulan (180 Hari)')),
                    DropdownMenuItem(value: 365, child: Text('1 Tahun (365 Hari)')),
                    DropdownMenuItem(value: 730, child: Text('2 Tahun (730 Hari)')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _expiresDays = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generate,
                child: _isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Text('Generate Kode Undangan', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            if (_generatedCode != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 40),
                    const SizedBox(height: 12),
                    Text('Kode berhasil digenerate!', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.success, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    SelectableText(
                      _generatedCode!, 
                      style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: 2)
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: Text('Salin Kode', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _generatedCode!));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kode disalin!')));
                      },
                    ),
                    const SizedBox(height: 12),
                    // Veltrik Pass Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.credit_card_rounded, size: 20),
                        label: Text(
                          'Generate Veltrik Pass',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        onPressed: () {
                          context.push('/admin/veltrik-pass', extra: {
                            'memberName': _generatedName ?? '',
                            'inviteCode': _generatedCode ?? '',
                            'expiresAt': _expiresAt ?? '',
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

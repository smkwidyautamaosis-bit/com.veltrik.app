import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import '../../../app/theme/app_colors.dart';
import '../widgets/veltrik_pass_card.dart';

class AdminVeltrikPassScreen extends StatefulWidget {
  final String memberName;
  final String inviteCode;
  final String expiresAt;

  const AdminVeltrikPassScreen({
    super.key,
    required this.memberName,
    required this.inviteCode,
    required this.expiresAt,
  });

  @override
  State<AdminVeltrikPassScreen> createState() => _AdminVeltrikPassScreenState();
}

class _AdminVeltrikPassScreenState extends State<AdminVeltrikPassScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSaving = false;
  bool _isSharing = false;

  Future<Uint8List?> _captureCard() async {
    try {
      return await _screenshotController.capture(pixelRatio: 3.0);
    } catch (e) {
      debugPrint('Failed to capture card: $e');
      return null;
    }
  }

  Future<void> _saveToGallery() async {
    setState(() => _isSaving = true);
    final bytes = await _captureCard();
    if (bytes == null) {
      _showError('Gagal mengambil gambar kartu.');
      setState(() => _isSaving = false);
      return;
    }
    try {
      await Gal.putImageBytes(bytes, name: 'veltrik_pass_${widget.inviteCode}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Veltrik Pass berhasil disimpan ke galeri!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      _showError('Error menyimpan: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _shareToWhatsApp() async {
    setState(() => _isSharing = true);
    final bytes = await _captureCard();
    if (bytes == null) {
      _showError('Gagal mengambil gambar kartu.');
      setState(() => _isSharing = false);
      return;
    }
    try {
      final xFile = XFile.fromData(bytes, mimeType: 'image/png', name: 'veltrik_pass.png');
      await Share.shareXFiles(
        [xFile],
        text: '🎉 Veltrik Pass atas nama *${widget.memberName}*\nKode: *${widget.inviteCode}*\n\nSelamat bergabung di Veltrik! 🚀',
      );
    } catch (e) {
      _showError('Error berbagi: $e');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Veltrik Pass',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),

            // Tip text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card_rounded, color: Color(0xFF2563EB), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Kartu digital keanggotaan Veltrik untuk ${widget.memberName}. Simpan atau bagikan langsung via WhatsApp.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // The Card — wrapped in Screenshot
            Screenshot(
              controller: _screenshotController,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: VeltrikPassCard(
                  memberName: widget.memberName,
                  inviteCode: widget.inviteCode,
                  expiresAt: widget.expiresAt,
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Divider with label
            Row(children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('Aksi', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted)),
              ),
              const Expanded(child: Divider()),
            ]),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                // Save to Gallery
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: _isSaving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.download_rounded, size: 20),
                    label: Text(
                      _isSaving ? 'Menyimpan...' : 'Simpan ke Galeri',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    onPressed: _isSaving || _isSharing ? null : _saveToGallery,
                  ),
                ),
                const SizedBox(width: 12),
                // Share to WhatsApp
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: _isSharing
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.share_rounded, size: 20),
                    label: Text(
                      _isSharing ? 'Berbagi...' : 'WhatsApp',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    onPressed: _isSaving || _isSharing ? null : _shareToWhatsApp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

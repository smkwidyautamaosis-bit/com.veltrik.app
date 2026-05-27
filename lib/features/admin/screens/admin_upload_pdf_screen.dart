import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';

class AdminUploadPdfScreen extends StatefulWidget {
  const AdminUploadPdfScreen({super.key});

  @override
  State<AdminUploadPdfScreen> createState() => _AdminUploadPdfScreenState();
}

class _AdminUploadPdfScreenState extends State<AdminUploadPdfScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  File? _selectedFile;
  bool _isUploading = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _upload() async {
    if (_titleController.text.isEmpty || _selectedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(_selectedFile!.path)}';
      final storagePath = 'pdfs/$fileName';

      // 1. Upload to Storage
      await SupabaseService.instance.client.storage
          .from(SupabaseConstants.pdfsBucket)
          .upload(storagePath, _selectedFile!);

      // 2. Insert to documents table
      await SupabaseService.instance.client.from('documents').insert({
        'title': _titleController.text,
        'description': _descController.text,
        'file_path': storagePath,
        'category': 'general',
        'is_active': true,
        'access_type': 'all',
      });

      // 3. Send Push Notification via Edge Function
      try {
        await SupabaseService.instance.client.functions.invoke(
          'send-notification',
          body: {
            'title': 'Dokumen Baru 📄',
            'body': _titleController.text,
            'target': 'all',
            'notification_type': 'document',
            // FCM requires a public HTTPS URL to display images in Push Notifications.
            'image_url': 'https://idfmdjtkvvjyqbffjugt.supabase.co/storage/v1/object/public/veltrik-thumbnails/placeholder%20(1).png'
          },
        );
      } catch (e) {
        debugPrint('Failed to trigger notification: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload successful!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
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
        title: Text('Upload PDF', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Judul Dokumen', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecond)),
            const SizedBox(height: 8),
            TextField(controller: _titleController, decoration: const InputDecoration(hintText: 'Judul dokumen...')),
            const SizedBox(height: 16),
            Text('Deskripsi', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecond)),
            const SizedBox(height: 8),
            TextField(controller: _descController, decoration: const InputDecoration(hintText: 'Deskripsi singkat...'), maxLines: 3),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedFile != null ? AppColors.accentBlue : AppColors.border,
                    width: _selectedFile != null ? 2 : 1,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFile != null ? Icons.picture_as_pdf_rounded : Icons.upload_file_rounded,
                      color: _selectedFile != null ? AppColors.accentBlue : AppColors.textMuted,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedFile != null ? p.basename(_selectedFile!.path) : 'Tap untuk pilih file PDF',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: _selectedFile != null ? AppColors.accentBlue : AppColors.textMuted,
                        fontWeight: _selectedFile != null ? FontWeight.w600 : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _upload,
                child: _isUploading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Text('Upload Dokumen', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

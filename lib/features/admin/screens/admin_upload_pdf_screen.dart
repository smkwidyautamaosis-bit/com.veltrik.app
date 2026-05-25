import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
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
      appBar: AppBar(title: const Text('Upload PDF')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 16),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: Text(_selectedFile != null ? p.basename(_selectedFile!.path) : 'Select PDF File'),
              onPressed: _pickFile,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _upload,
                child: _isUploading ? const CircularProgressIndicator() : const Text('Upload Document'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

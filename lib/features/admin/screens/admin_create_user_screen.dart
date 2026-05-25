import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/supabase_service.dart';

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
      appBar: AppBar(title: const Text('Generate Invite Code')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generate an invite code and pre-register a user. They can use this code to log in directly.',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name *'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email (Optional)'),
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Membership Duration'),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _expiresDays,
                  isDense: true,
                  items: const [
                    DropdownMenuItem(value: 30, child: Text('1 Month (30 Days)')),
                    DropdownMenuItem(value: 90, child: Text('3 Months (90 Days)')),
                    DropdownMenuItem(value: 180, child: Text('6 Months (180 Days)')),
                    DropdownMenuItem(value: 365, child: Text('1 Year (365 Days)')),
                    DropdownMenuItem(value: 730, child: Text('2 Years (730 Days)')),
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
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generate,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Generate Code'),
              ),
            ),
            if (_generatedCode != null) ...[
              const SizedBox(height: 48),
              const Center(child: Text('Generated Code:', style: TextStyle(color: AppColors.textMuted))),
              const SizedBox(height: 8),
              Center(
                child: SelectableText(
                  _generatedCode!, 
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)
                )
              ),
              const SizedBox(height: 16),
              Center(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy to Clipboard'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _generatedCode!));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

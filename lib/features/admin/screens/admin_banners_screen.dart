import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../library/models/banner_model.dart';

class AdminBannersScreen extends StatefulWidget {
  const AdminBannersScreen({super.key});

  @override
  State<AdminBannersScreen> createState() => _AdminBannersScreenState();
}

class _AdminBannersScreenState extends State<AdminBannersScreen> {
  List<BannerModel> _banners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBanners();
  }

  Future<void> _fetchBanners() async {
    setState(() => _isLoading = true);
    try {
      final data = await SupabaseService.instance.client
          .from('banners')
          .select('*')
          .order('order', ascending: true);
      if (mounted) {
        setState(() {
          _banners = (data as List)
              .map((item) => BannerModel.fromJson(item as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _toggleActive(BannerModel banner) async {
    try {
      await SupabaseService.instance.client
          .from('banners')
          .update({'is_active': !banner.isActive})
          .eq('id', banner.id);
      _fetchBanners();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteBanner(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Banner?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: const Text('Banner ini akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await SupabaseService.instance.client.from('banners').delete().eq('id', id);
        _fetchBanners();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showAddEditSheet({BannerModel? banner}) {
    final titleCtrl = TextEditingController(text: banner?.title ?? '');
    final descCtrl = TextEditingController(text: banner?.description ?? '');
    final imageUrlCtrl = TextEditingController(text: banner?.imageUrl ?? '');
    final orderCtrl = TextEditingController(text: (banner?.order ?? 0).toString());
    bool isActive = banner?.isActive ?? true;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          decoration: const BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                banner == null ? 'Tambah Banner' : 'Edit Banner',
                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 20),
              _buildField('Judul *', titleCtrl, hint: 'Judul banner'),
              const SizedBox(height: 12),
              _buildField('Deskripsi', descCtrl, hint: 'Deskripsi singkat (opsional)', maxLines: 2),
              const SizedBox(height: 12),
              _buildField('URL Gambar', imageUrlCtrl, hint: 'https://...'),
              const SizedBox(height: 12),
              _buildField('Urutan', orderCtrl, hint: '0', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tampilkan Banner', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textPrimary)),
                  Switch(
                    value: isActive,
                    activeTrackColor: AppColors.accentBlue,
                    thumbColor: WidgetStateProperty.all(Colors.white),
                    onChanged: (val) => setModalState(() => isActive = val),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    if (titleCtrl.text.isEmpty) {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul tidak boleh kosong!')));
                      return;
                    }
                    setModalState(() => isSaving = true);
                    try {
                      final payload = {
                        'title': titleCtrl.text.trim(),
                        'description': descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                        'image_url': imageUrlCtrl.text.trim().isEmpty ? null : imageUrlCtrl.text.trim(),
                        'order': int.tryParse(orderCtrl.text) ?? 0,
                        'is_active': isActive,
                      };
                      if (banner == null) {
                        await SupabaseService.instance.client.from('banners').insert(payload);
                      } else {
                        await SupabaseService.instance.client.from('banners').update(payload).eq('id', banner.id);
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                        _fetchBanners();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(banner == null ? 'Banner berhasil ditambahkan!' : 'Banner berhasil diupdate!')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      setModalState(() => isSaving = false);
                    }
                  },
                  child: isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(banner == null ? 'Tambah Banner' : 'Simpan Perubahan'),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {String? hint, int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecond)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: Text('Kelola Banner', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditSheet(),
        backgroundColor: AppColors.accentBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Tambah Banner', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _banners.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image_not_supported_outlined, size: 64, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      Text('Belum ada banner', style: GoogleFonts.plusJakartaSans(fontSize: 16, color: AppColors.textSecond, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Tap tombol + untuk menambah banner', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _banners.length,
                  itemBuilder: (context, index) {
                    final banner = _banners[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 56, height: 56,
                            color: AppColors.accentBlue.withValues(alpha: 0.1),
                            child: banner.imageUrl != null && banner.imageUrl!.isNotEmpty
                                ? Image.network(banner.imageUrl!, fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const Icon(Icons.image, color: AppColors.accentBlue))
                                : const Icon(Icons.campaign_rounded, color: AppColors.accentBlue),
                          ),
                        ),
                        title: Text(
                          banner.title,
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        subtitle: Text(
                          banner.description ?? 'Tidak ada deskripsi',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: banner.isActive,
                              activeTrackColor: AppColors.accentBlue,
                              thumbColor: WidgetStateProperty.all(Colors.white),
                              onChanged: (v) => _toggleActive(banner),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                              onSelected: (value) {
                                if (value == 'edit') _showAddEditSheet(banner: banner);
                                if (value == 'delete') _deleteBanner(banner.id);
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(value: 'edit', child: Text('Edit', style: GoogleFonts.plusJakartaSans())),
                                PopupMenuItem(value: 'delete', child: Text('Hapus', style: GoogleFonts.plusJakartaSans(color: AppColors.danger))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

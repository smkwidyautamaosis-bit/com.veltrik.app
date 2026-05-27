import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../auth/providers/auth_provider.dart';

class PdfViewerScreen extends ConsumerStatefulWidget {
  final String documentId;
  final String title;

  const PdfViewerScreen({super.key, required this.documentId, required this.title});

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  String? _signedUrl;
  bool _isLoading = true;
  String? _error;
  
  static const platform = MethodChannel('com.veltrik.app/secure');
  
  // Search state
  final PdfViewerController _pdfViewerController = PdfViewerController();
  PdfTextSearchResult _searchResult = PdfTextSearchResult();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _hasTrackedView = false;

  @override
  void initState() {
    super.initState();
    _setSecure(true);
    _loadPdf();
  }

  @override
  void dispose() {
    _setSecure(false);
    _searchController.dispose();
    _pdfViewerController.dispose();
    super.dispose();
  }

  Future<void> _setSecure(bool secure) async {
    try {
      await platform.invokeMethod('secure', {'secure': secure});
    } on PlatformException catch (e) {
      debugPrint("Failed to set secure flag: '${e.message}'.");
    }
  }

  Future<void> _loadPdf() async {
    final url = await PdfService.instance.getSignedUrl(widget.documentId);
    if (mounted) {
      setState(() {
        _signedUrl = url;
        _isLoading = false;
        if (url == null) {
          _error = 'Gagal memuat dokumen. Sesi mungkin tidak valid.';
        }
      });
      
      // Track view if successfully loaded
      if (url != null && !_hasTrackedView) {
        _trackView();
      }
    }
  }
  
  Future<void> _trackView() async {
    try {
      final user = ref.read(authProvider).user;
      if (user != null) {
        await SupabaseService.instance.client.from('document_views').insert({
          'document_id': widget.documentId,
          'user_id': user.id,
        });
        _hasTrackedView = true;
      }
    } catch (e) {
      debugPrint('Failed to track document view: $e');
    }
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      _searchResult.clear();
      setState(() {});
      return;
    }
    _searchResult = _pdfViewerController.searchText(query);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authProvider).user;
    final userName = user?.fullName ?? 'Member';
    final codeFragment = user?.inviteCode.substring(math.max(0, (user.inviteCode.length) - 4)) ?? 'XXXX';
    final date = AppDateUtils.toWIBDateOnly(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isSearching) {
              setState(() {
                _isSearching = false;
                _searchController.clear();
                _searchResult.clear();
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Cari teks di PDF...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onSubmitted: _performSearch,
              )
            : Text(widget.title, style: AppTextStyles.h2),
        actions: _isSearching
            ? [
                if (_searchResult.hasResult) ...[
                  Center(
                    child: Text(
                      '${_searchResult.currentInstanceIndex}/${_searchResult.totalInstanceCount}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up),
                    onPressed: () {
                      _searchResult.previousInstance();
                      setState(() {});
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onPressed: () {
                      _searchResult.nextInstance();
                      setState(() {});
                    },
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    _searchResult.clear();
                    setState(() {});
                  },
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
              ],
      ),
      body: _isLoading
          ? Shimmer.fromColors(
              baseColor: AppColors.bgCard,
              highlightColor: AppColors.bgElevated,
              child: Container(color: Colors.white),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
                      const SizedBox(height: 16),
                      Text(_error!, style: AppTextStyles.bodyRegular.copyWith(color: Colors.white)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });
                          _loadPdf();
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    SfPdfViewer.network(
                      _signedUrl!,
                      controller: _pdfViewerController,
                      canShowScrollHead: false,
                      canShowScrollStatus: false,
                      pageSpacing: 4,
                    ),
                    IgnorePointer(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                height: 32,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '© Veltrik Hak Cipta Dilindungi',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '$userName · VLTK-$codeFragment',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                date,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

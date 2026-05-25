import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/pdf_service.dart';
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

  @override
  void initState() {
    super.initState();
    _setSecure(true);
    _loadPdf();
  }

  @override
  void dispose() {
    _setSecure(false);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authProvider).user;
    final userName = user?.fullName ?? 'Member';
    final codeFragment = user?.inviteCode.substring(math.max(0, (user.inviteCode.length) - 4)) ?? 'XXXX';
    final date = DateFormat('dd MMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title, style: AppTextStyles.h2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                      Text(_error!, style: AppTextStyles.bodyRegular),
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
                      canShowScrollHead: false,
                      canShowScrollStatus: false,
                      pageSpacing: 4,
                    ),
                    IgnorePointer(
                      child: CustomPaint(
                        painter: WatermarkPainter(
                          userName: userName,
                          codeFragment: codeFragment,
                          date: date,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ],
                ),
    );
  }
}

class WatermarkPainter extends CustomPainter {
  final String userName;
  final String codeFragment;
  final String date;

  WatermarkPainter({required this.userName, required this.codeFragment, required this.date});

  @override
  void paint(Canvas canvas, Size size) {
    final text = "$userName · VLTK-••••-$codeFragment · $date";
    final textStyle = const TextStyle(
      color: Color(0x33000000), // 20% opacity black so it shows over white PDF
      fontSize: 16,
      fontFamily: 'monospace',
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();

    canvas.save();
    
    // Create a tiled pattern
    final double stepX = textPainter.width + 100;
    final double stepY = 150;
    
    // Rotate canvas by -30 degrees
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-math.pi / 6);
    canvas.translate(-size.width, -size.height);

    for (double x = -size.width; x < size.width * 2; x += stepX) {
      for (double y = -size.height; y < size.height * 2; y += stepY) {
        textPainter.paint(canvas, Offset(x, y));
      }
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VeltrikPassCard extends StatefulWidget {
  final String memberName;
  final String inviteCode;
  final String expiresAt;

  const VeltrikPassCard({
    super.key,
    required this.memberName,
    required this.inviteCode,
    required this.expiresAt,
  });

  @override
  State<VeltrikPassCard> createState() => _VeltrikPassCardState();
}

class _VeltrikPassCardState extends State<VeltrikPassCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Format invite code as VLTK-XXXX-XXXX
  String _formatCode(String raw) {
    final clean = raw.replaceAll('-', '').toUpperCase();
    if (clean.length >= 8) {
      return 'VLTK-${clean.substring(0, 4)}-${clean.substring(4, 8)}';
    }
    return 'VLTK-$raw'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final formattedCode = _formatCode(widget.inviteCode);

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF0F7FF), Color(0xFFDBEAFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // --- Background geometric pattern ---
              Positioned.fill(child: CustomPaint(painter: _GeometricPainter())),

              // --- Card Content ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Logo + VELTRIK PASS label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('assets/images/logo.png', height: 28),
                        Text(
                          'VELTRIK PASS',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2563EB),
                            letterSpacing: 2.5,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Member Name
                    Text(
                      widget.memberName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Invite Code (like credit card number)
                    Text(
                      formattedCode,
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2563EB),
                        letterSpacing: 3,
                      ),
                    ),

                    const Spacer(),

                    // Bottom Row: Status + Expires + Barcode
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Status + Expires
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Active indicator
                            Row(
                              children: [
                                AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, _) => Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E).withValues(
                                          alpha: _pulseAnimation.value),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF22C55E)
                                              .withValues(alpha: 0.5),
                                          blurRadius: 6,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'ACTIVE MEMBER',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF16A34A),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Berlaku hingga: ${widget.expiresAt}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Decorative barcode
                        CustomPaint(
                          painter: _BarcodePainter(),
                          size: const Size(80, 36),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Decorative subtle geometric background
class _GeometricPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final random = Random(42); // fixed seed for consistent pattern
    for (int i = 0; i < 8; i++) {
      final cx = random.nextDouble() * size.width;
      final cy = random.nextDouble() * size.height;
      final r = 30.0 + random.nextDouble() * 60;
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    // A few diagonal lines
    final linePaint = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (int i = 0; i < 5; i++) {
      final x = size.width * (i / 4);
      canvas.drawLine(Offset(x, 0), Offset(x + 80, size.height), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Decorative fake barcode
class _BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final random = Random(99);
    double x = 0;
    while (x < size.width) {
      final barWidth = 1.0 + random.nextDouble() * 3;
      final gap = 1.0 + random.nextDouble() * 2;
      canvas.drawRect(Rect.fromLTWH(x, 0, barWidth, size.height), paint);
      x += barWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app/theme/app_colors.dart';
import '../providers/protection_toggles_provider.dart';

// Global state to remember if the user has activated the shield in this session
final isSecurityEnabledProvider = StateProvider<bool>((ref) => false);

enum ShieldState { unsecured, activating, secured }

class SystemStatusScreen extends ConsumerStatefulWidget {
  const SystemStatusScreen({super.key});

  @override
  ConsumerState<SystemStatusScreen> createState() => _SystemStatusScreenState();
}

class _SystemStatusScreenState extends ConsumerState<SystemStatusScreen> with SingleTickerProviderStateMixin {
  late ShieldState _state;
  final List<String> _terminalLogs = [];
  Timer? _typingTimer;
  int _currentLogIndex = 0;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> _hackSequence = [
    "Initiating Veltrik Secure Protocol...",
    "Scanning for vulnerabilities... [0 FOUND]",
    "Bypassing external tracking modules...",
    "Encrypting data tunnels via AES-256...",
    "Injecting Sandi Nutrya protection sequence...",
    "Masking IP Address... [HIDDEN]",
    "System override complete."
  ];

  @override
  void initState() {
    super.initState();
    
    // Check if user already activated it in this session
    final isAlreadySecured = ref.read(isSecurityEnabledProvider);

    if (isAlreadySecured) {
      _state = ShieldState.secured;
      _terminalLogs.addAll(_hackSequence);
      
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat(reverse: true);
    } else {
      _state = ShieldState.unsecured;
      _terminalLogs.add("Status: Connection Vulnerable.");
      _terminalLogs.add("Action Required: Enable protection.");
      
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      )..repeat(reverse: true);
    }

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _activateShield() {
    setState(() {
      _state = ShieldState.activating;
      _terminalLogs.clear();
      _currentLogIndex = 0;
    });
    
    // Speed up pulse during processing
    _pulseController.duration = const Duration(milliseconds: 500);
    _pulseController.repeat(reverse: true);

    _typingTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (_currentLogIndex < _hackSequence.length) {
        setState(() {
          _terminalLogs.add(_hackSequence[_currentLogIndex]);
          _currentLogIndex++;
        });
      } else {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _state = ShieldState.secured;
            });
            // Save the state globally so it persists when switching tabs
            ref.read(isSecurityEnabledProvider.notifier).state = true;
            
            // Slow down pulse for secured state
            _pulseController.duration = const Duration(seconds: 3);
            _pulseController.repeat(reverse: true);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                // Header
                Center(
                  child: Text(
                    'Security Status',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Manage your connection privacy',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Shield Visual (Modern & Elegant)
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: _buildShieldVisual(),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 30),

                // Status Output Area (Clean Card) or Toggles
                _state == ShieldState.secured ? _buildToggles() : SizedBox(height: 300, child: _buildTerminalLogs()),
                
                const SizedBox(height: 24),

                // Action Button / Final Status
                if (_state != ShieldState.secured) _buildActionButton(),
                
                if (_state == ShieldState.secured)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Developer Sandi Nutrya sudah mengamankan Device Anda. Koneksi Anda kini tidak dapat dilacak.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.accentRoyal,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  
                const SizedBox(height: 80), // Space for floating navbar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getThemeColor() {
    switch (_state) {
      case ShieldState.unsecured:
        return AppColors.warning;
      case ShieldState.activating:
        return AppColors.accentBlue;
      case ShieldState.secured:
        return AppColors.success;
    }
  }

  Widget _buildShieldVisual() {
    Color themeColor = _getThemeColor();
    IconData icon;
    
    switch (_state) {
      case ShieldState.unsecured:
        icon = Icons.lock_open_rounded;
        break;
      case ShieldState.activating:
        icon = Icons.sync_rounded;
        break;
      case ShieldState.secured:
        icon = Icons.lock_rounded;
        break;
    }

    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.bgPrimary,
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                themeColor.withValues(alpha: 0.1),
                themeColor.withValues(alpha: 0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 60,
              color: themeColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (_state == ShieldState.unsecured) {
      return ElevatedButton(
        onPressed: _activateShield,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          'Enable Veltrik Protection',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    } else if (_state == ShieldState.activating) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.accentBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Authenticating Protocol...',
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: AppColors.accentBlue, 
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildTerminalLogs() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        border: Border.all(
          color: _state == ShieldState.secured 
              ? AppColors.success.withValues(alpha: 0.3) 
              : AppColors.borderLight,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListView.builder(
        itemCount: _terminalLogs.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.arrow_right_rounded,
                  color: _getThemeColor(),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _terminalLogs[index],
                    style: TextStyle(
                      color: AppColors.textSecond,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggles() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const Text(
          'Active Protections',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        _buildToggleItem(
          title: 'No deteksi Aktif Data',
          icon: Icons.cell_tower_rounded,
          color: Colors.blueAccent,
          provider: dataProtectionProvider,
        ),
        _buildToggleItem(
          title: 'No deteksi WhatsApp',
          icon: FontAwesomeIcons.whatsapp,
          color: const Color(0xFF25D366),
          provider: whatsappProtectionProvider,
        ),
        _buildToggleItem(
          title: 'No deteksi Instagram',
          icon: FontAwesomeIcons.instagram,
          color: const Color(0xFFE1306C),
          provider: instagramProtectionProvider,
        ),
        _buildAIToggleItem(),
      ],
    );
  }

  Widget _buildToggleItem({
    required String title,
    required IconData icon,
    required Color color,
    required StateProvider<bool> provider,
  }) {
    final value = ref.watch(provider);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: value ? color.withValues(alpha: 0.3) : AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: SwitchListTile(
        value: value,
        onChanged: (val) => ref.read(provider.notifier).state = val,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: FaIcon(icon, color: color, size: 20),
        ),
        activeTrackColor: color.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildAIToggleItem() {
    final value = ref.watch(aiProtectionProvider);
    const color = Color(0xFF8B5CF6); // Purple
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: value ? color.withValues(alpha: 0.3) : AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          SwitchListTile(
            value: value,
            onChanged: (val) => ref.read(aiProtectionProvider.notifier).state = val,
            title: const Text('No deteksi Semua Aplikasi AI', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome_rounded, color: color, size: 20),
            ),
            activeTrackColor: color.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
          // AI Logos
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildAILocalLogo('assets/images/gemini.svg'),
                _buildAILocalLogo('assets/images/openai.png'),
                _buildAILocalLogo('assets/images/claude-ai-icon.svg'),
                _buildAILocalLogo('assets/images/deepseek.svg'),
                _buildAILocalLogo('assets/images/metaai-color.png'),
                _buildAILocalLogo('assets/images/dola_ai.png'),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Gemini, ChatGPT, Claude, DeepSeek, Meta, Dola', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAILocalLogo(String assetPath) {
    final bool isSvg = assetPath.toLowerCase().endsWith('.svg');
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderLight, width: 2),
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: isSvg 
            ? SvgPicture.asset(assetPath, fit: BoxFit.cover)
            : Image.asset(assetPath, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.smart_toy_rounded, size: 16)),
        ),
      ),
    );
  }
}

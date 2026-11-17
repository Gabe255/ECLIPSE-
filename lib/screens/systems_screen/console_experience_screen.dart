import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/system_model.dart';
import '../../providers/file_provider.dart';
import '../game_screen/my_games_list.dart';

/// A console-specific layer between the systems carousel and the existing
/// game library. The original library remains responsible for game browsing
/// and launching; this screen gives each platform its own boot and home flow.
class ConsoleExperienceScreen extends StatefulWidget {
  const ConsoleExperienceScreen({
    super.key,
    required this.system,
    required this.fileProvider,
  });

  final SystemModel system;
  final FileProvider fileProvider;

  @override
  State<ConsoleExperienceScreen> createState() =>
      _ConsoleExperienceScreenState();
}

class _ConsoleExperienceScreenState extends State<ConsoleExperienceScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bootController;
  Timer? _bootTimer;
  bool _booting = true;

  Color get _accent => widget.system.colorAsColor;

  String get _platformKey =>
      '${widget.system.folderName} ${widget.system.shortName ?? ''}'
          .toLowerCase();

  bool get _isPsp => _platformKey.contains('psp');
  bool get _isWii => _platformKey.contains('wii');
  bool get _isDsFamily =>
      _platformKey.contains('3ds') || _platformKey.contains('nintendo ds');

  @override
  void initState() {
    super.initState();
    _bootController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..forward();
    _bootTimer = Timer(const Duration(milliseconds: 1450), _finishBoot);
  }

  @override
  void dispose() {
    _bootTimer?.cancel();
    _bootController.dispose();
    super.dispose();
  }

  void _finishBoot() {
    if (!mounted || !_booting) return;
    setState(() => _booting = false);
  }

  Future<void> _openLibrary() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SystemGamesList(
          system: widget.system,
          fileProvider: widget.fileProvider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_booting,
      child: Scaffold(
        backgroundColor: const Color(0xFF090B10),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          child: _booting ? _buildBoot() : _buildHome(),
        ),
      ),
    );
  }

  Widget _buildBoot() {
    final name = widget.system.shortName ?? widget.system.realName;
    return GestureDetector(
      key: const ValueKey('console-boot'),
      behavior: HitTestBehavior.opaque,
      onTap: _finishBoot,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.05,
            colors: [
              _accent.withValues(alpha: 0.25),
              const Color(0xFF090B10),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _bootController,
            builder: (context, _) {
              final scale = 0.92 + (_bootController.value * 0.08);
              return Opacity(
                opacity: _bootController.value.clamp(0.15, 1),
                child: Transform.scale(
                  scale: scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SystemMark(system: widget.system, size: 92),
                      const SizedBox(height: 24),
                      Text(
                        name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'STARTING SYSTEM',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.58),
                          fontSize: 11,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: 150,
                        child: LinearProgressIndicator(
                          value: _bootController.value,
                          minHeight: 3,
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(_accent),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'TAP TO SKIP',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 9,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHome() {
    if (_isPsp) return _buildPspHome();
    if (_isWii) return _buildWiiHome();
    if (_isDsFamily) return _buildDsHome();
    return _buildConsoleHome();
  }

  Widget _buildShell({required Widget child, String? eyebrow}) {
    return Container(
      key: const ValueKey('console-home'),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _accent.withValues(alpha: 0.22),
            const Color(0xFF111722),
            const Color(0xFF080A0F),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 22, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _SystemMark(system: widget.system, size: 34),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.system.realName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Back to systems',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),
              if (eyebrow != null) ...[
                const SizedBox(height: 30),
                Text(
                  eyebrow.toUpperCase(),
                  style: TextStyle(
                    color: _accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsoleHome() {
    return _buildShell(
      eyebrow: 'Console home',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            widget.system.shortName ?? widget.system.realName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.system.romCount} games in your library',
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 34),
          _HomeTile(
            accent: _accent,
            icon: Icons.sports_esports_rounded,
            title: 'Game library',
            subtitle: 'Browse and launch your games',
            onTap: _openLibrary,
          ),
          const SizedBox(height: 12),
          _HomeTile(
            accent: _accent,
            icon: Icons.info_outline_rounded,
            title: 'System information',
            subtitle: widget.system.manufacturer ?? 'Console details',
            onTap: _showSystemInfo,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildPspHome() {
    return _buildShell(
      eyebrow: 'XMB-inspired home',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Row(
            children: [
              Icon(Icons.sports_esports_rounded, color: _accent, size: 34),
              const SizedBox(width: 14),
              const Text(
                'GAME',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _HomeTile(
            accent: _accent,
            icon: Icons.album_rounded,
            title: 'Memory Stick',
            subtitle: '${widget.system.romCount} titles available',
            onTap: _openLibrary,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildWiiHome() {
    return _buildShell(
      eyebrow: 'Channel menu',
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Wrap(
                spacing: 14,
                runSpacing: 14,
                alignment: WrapAlignment.center,
                children: [
                  _ChannelTile(
                    accent: _accent,
                    icon: Icons.sports_esports_rounded,
                    label: 'Disc Channel',
                    onTap: _openLibrary,
                  ),
                  _ChannelTile(
                    accent: _accent,
                    icon: Icons.grid_view_rounded,
                    label: 'Game Library',
                    onTap: _openLibrary,
                  ),
                  _ChannelTile(
                    accent: _accent,
                    icon: Icons.settings_rounded,
                    label: 'System Info',
                    onTap: _showSystemInfo,
                  ),
                ],
              ),
            ),
          ),
          Text(
            '${widget.system.romCount} games available',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDsHome() {
    return _buildShell(
      eyebrow: 'HOME menu',
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.32),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _accent.withValues(alpha: 0.45)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SystemMark(system: widget.system, size: 54),
                    const SizedBox(height: 12),
                    Text(
                      widget.system.shortName ?? widget.system.realName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.system.romCount} games',
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 104,
            child: Row(
              children: [
                Expanded(
                  child: _ChannelTile(
                    accent: _accent,
                    icon: Icons.gamepad_rounded,
                    label: 'Game Library',
                    onTap: _openLibrary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ChannelTile(
                    accent: _accent,
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    onTap: _showSystemInfo,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSystemInfo() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.system.realName),
        content: Text(
          [
            if (widget.system.manufacturer?.isNotEmpty == true)
              widget.system.manufacturer!,
            if (widget.system.launchDate?.isNotEmpty == true)
              'Released: ${widget.system.launchDate}',
            '${widget.system.romCount} games detected',
            if (widget.system.description?.isNotEmpty == true)
              widget.system.description!,
          ].join('\n\n'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SystemMark extends StatelessWidget {
  const _SystemMark({required this.system, required this.size});

  final SystemModel system;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = system.iconImage.startsWith('assets/')
        ? system.iconImage
        : 'assets${system.iconImage}';
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        color: system.colorAsColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(size * 0.24),
        border: Border.all(
          color: system.colorAsColor.withValues(alpha: 0.55),
        ),
      ),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.videogame_asset_rounded,
          color: system.colorAsColor,
          size: size * 0.58,
        ),
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  const _HomeTile({
    required this.accent,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, color: accent, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  const _ChannelTile({
    required this.accent,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Color accent;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: accent, size: 27),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

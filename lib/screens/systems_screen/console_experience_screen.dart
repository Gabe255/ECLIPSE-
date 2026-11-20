import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';
import 'package:video_player/video_player.dart';

import '../../models/system_model.dart';
import '../../providers/file_provider.dart';
import '../../services/android_service.dart';
import '../../services/game_service.dart';
import '../../utils/gamepad_nav.dart';
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
  VideoPlayerController? _featuredVideoController;
  String? _featuredGameTitle;
  bool _loadingFeaturedVideo = false;
  Timer? _bootTimer;
  StreamSubscription<GamepadEvent>? _wiiPointerSubscription;
  bool _booting = true;
  Offset _wiiPointer = const Offset(0.5, 0.5);
  DateTime _lastWiiAxisUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  static int _navigationSequence = 0;
  late final String _navigationLayerId =
      'console_experience#${++_navigationSequence}';
  late final GamepadNavigation _gamepadNav;

  Color get _accent => widget.system.colorAsColor;

  String get _platformKey =>
      '${widget.system.folderName} ${widget.system.shortName ?? ''} ${widget.system.realName}'
          .toLowerCase();

  bool get _isPsp => _platformKey.contains('psp');
  bool get _isWii => _platformKey.contains('wii');
  bool get _isDsFamily =>
      _platformKey.contains('3ds') ||
      _platformKey.contains('nintendo ds') ||
      _platformKey.contains('nds');

  bool _hasAny(List<String> terms) =>
      terms.any((term) => _platformKey.contains(term));

  bool _isFolderCode(List<String> codes) =>
      codes.contains(widget.system.folderName.toLowerCase());

  String get _interfaceFamily {
    if (_isPsp || _isFolderCode(['psp', 'pspminis'])) {
      return 'psp';
    }
    if (_isWii) {
      return 'wii';
    }
    if (_isDsFamily || _isFolderCode(['ds', '3ds'])) {
      return 'ds';
    }
    if (_isFolderCode(['xbox360']) ||
        _hasAny(['xbox 360', 'xbox360', 'xb360', '360'])) {
      return 'xbox360';
    }
    if (_isFolderCode(['xbox']) ||
        _hasAny(['original xbox', 'microsoft xbox'])) {
      return 'xbox';
    }
    if (_isFolderCode(['ps1', 'psx']) ||
        _hasAny(['ps1', 'playstation 1', 'playstation (1994)', 'psx'])) {
      return 'playstation-ps1';
    }
    if (_isFolderCode(['ps2']) || _hasAny(['ps2', 'playstation 2'])) {
      return 'playstation-ps2';
    }
    if (_isFolderCode(['ps4']) || _hasAny(['ps4', 'playstation 4'])) {
      return 'playstation-ps4';
    }
    if (_hasAny(['ps5', 'playstation 5'])) {
      return 'playstation-modern';
    }
    if (_hasAny(['ps3', 'playstation 3'])) {
      return 'playstation-xmb';
    }
    if (_hasAny(['switch', 'nintendo switch']) || _isFolderCode(['switch'])) {
      return 'switch';
    }
    if (_hasAny(['gamecube']) || _isFolderCode(['gc'])) {
      return 'gamecube';
    }
    if (_hasAny(['n64', 'nintendo 64']) || _isFolderCode(['n64'])) {
      return 'n64';
    }
    if (_hasAny([
          'gba',
          'game boy advance',
          'gbc',
          'game boy color',
          'gameboy',
        ]) ||
        _isFolderCode([
          'gb',
          'gbc',
          'gba',
          'gb-hacks',
          'gba-hacks',
          'gbc-hacks',
          'lynx',
          'ngp',
          'ngpc',
          'ws',
          'wsc',
        ])) {
      return 'gameboy';
    }
    if (_hasAny(['dreamcast']) || _isFolderCode(['dc'])) {
      return 'dreamcast';
    }
    if (_hasAny(['genesis', 'megadrive', 'mega drive', 'sega']) ||
        _isFolderCode([
          'genesis',
          'genesis-hacks',
          'md',
          'md-hacks',
          'sms',
          'gg',
          'gg-hacks',
          'mark3',
          'sat',
          'scd',
          'mcd',
          'sg1k',
        ])) {
      return 'sega';
    }
    if (_hasAny(['snes', 'super nintendo', 'nes', 'famicom']) ||
        _isFolderCode([
          'nes',
          'nes-hacks',
          'snes',
          'snes-hacks',
          'sfc',
          'sfc-hacks',
          'fc',
          'fds',
        ])) {
      return 'nintendo-classic';
    }
    if (_isFolderCode([
      'mame',
      'fbneo',
      'cps1',
      'cps2',
      'cps3',
      'neogeo',
      'ngcd',
      'naomi',
      'naomi2',
      'naomigd',
      'model3',
      'triforce',
    ])) {
      return 'arcade';
    }
    return 'desktop';
  }

  @override
  void initState() {
    super.initState();
    _loadFeaturedGameplay();
    GameService.deviceScreenOn.addListener(_syncPreviewPlayback);
    _gamepadNav = GamepadNavigation(
      onNavigateUp: () {
        if (!_booting && _interfaceFamily == 'wii') {
          _moveWiiPointer(const Offset(0, -0.055));
        }
      },
      onNavigateDown: () {
        if (!_booting && _interfaceFamily == 'wii') {
          _moveWiiPointer(const Offset(0, 0.055));
        }
      },
      onNavigateLeft: () {
        if (!_booting && _interfaceFamily == 'wii') {
          _moveWiiPointer(const Offset(-0.055, 0));
        }
      },
      onNavigateRight: () {
        if (!_booting && _interfaceFamily == 'wii') {
          _moveWiiPointer(const Offset(0.055, 0));
        }
      },
      onSelectItem: () {
        if (_booting) {
          _finishBoot();
        } else {
          _openLibrary();
        }
      },
      onBack: () {
        if (_booting) {
          _finishBoot();
        } else {
          Navigator.of(context).maybePop();
        }
      },
      onSettings: () {
        if (!_booting) _showSystemInfo();
      },
    );
    _bootController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..forward();
    _bootTimer = Timer(const Duration(milliseconds: 1450), _finishBoot);
    if (_interfaceFamily == 'wii') _listenForWiiStick();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _gamepadNav.initialize();
      final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
      GamepadNavigationManager.pushLayer(
        _navigationLayerId,
        onActivate: _gamepadNav.activate,
        onDeactivate: _gamepadNav.deactivate,
        background: !isCurrentRoute,
      );
    });
  }

  @override
  void dispose() {
    _bootTimer?.cancel();
    GameService.deviceScreenOn.removeListener(_syncPreviewPlayback);
    _featuredVideoController?.dispose();
    _wiiPointerSubscription?.cancel();
    GamepadNavigationManager.popLayer(_navigationLayerId);
    _gamepadNav.dispose();
    _bootController.dispose();
    super.dispose();
  }

  void _syncPreviewPlayback() {
    final controller = _featuredVideoController;
    if (!mounted || controller == null || !controller.value.isInitialized) {
      return;
    }
    final routeIsCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    final shouldPlay = GameService.deviceScreenOn.value &&
        !GameService.isGameLaunchInProgress && routeIsCurrent;
    if (shouldPlay && !controller.value.isPlaying) {
      controller.play();
    } else if (!shouldPlay && controller.value.isPlaying) {
      controller.pause();
    }
  }

  Future<void> _loadFeaturedGameplay() async {
    if (_loadingFeaturedVideo || widget.system.romCount == 0) return;
    _loadingFeaturedVideo = true;
    try {
      final games = await GameService.loadGamesForSystem(widget.system);
      for (final game in games) {
        final videoPath = game.getVideoPath(
          widget.system.folderName,
          widget.fileProvider,
        );
        if (!await widget.fileProvider.fileExists(videoPath)) continue;
        final controller = VideoPlayerController.file(File(videoPath));
        try {
          await controller.initialize();
          await controller.setLooping(true);
          await controller.setVolume(0);
          if (GameService.deviceScreenOn.value &&
              !GameService.isGameLaunchInProgress) {
            await controller.play();
          }
          if (!mounted) {
            await controller.dispose();
            return;
          }
          setState(() {
            _featuredVideoController = controller;
            _featuredGameTitle = game.name;
          });
          return;
        } catch (_) {
          await controller.dispose();
        }
      }
    } catch (_) {
      // A missing preview is normal: the system artwork remains the fallback.
    } finally {
      _loadingFeaturedVideo = false;
    }
  }

  void _finishBoot() {
    if (!mounted || !_booting) return;
    setState(() => _booting = false);
  }

  Future<void> _openPs4Emulator() async {
    if (!Platform.isAndroid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bachata S4 is currently supported on Android only.'),
        ),
      );
      return;
    }
    final installed = await AndroidService.isPackageInstalled(
      'com.bachatas4.android',
    );
    if (!mounted) return;
    if (!installed) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Bachata S4 is not installed'),
          content: const Text(
            'Install Bachata S4 to import and run your legally-owned PS4 game packages. ECLIPSE can hand off .pkg files to it once installed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Got it'),
            ),
          ],
        ),
      );
      return;
    }
    final opened = await AndroidService.launchPackage('com.bachatas4.android');
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Bachata S4.')),
      );
    }
  }

  Future<void> _openLibrary() async {
    await _featuredVideoController?.pause();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SystemGamesList(
          system: widget.system,
          fileProvider: widget.fileProvider,
        ),
      ),
    );
    if (mounted) _syncPreviewPlayback();
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

  String get _bootLabel {
    switch (_interfaceFamily) {
      case 'psp':
        return 'PLAYSTATION PORTABLE';
      case 'wii':
        return 'WII MENU';
      case 'ds':
        return 'DUAL SCREEN SYSTEM';
      case 'xbox':
        return 'XBOX DASHBOARD';
      case 'xbox360':
        return 'XBOX 360 DASHBOARD';
      case 'playstation-ps1':
        return 'PLAYSTATION BIOS';
      case 'playstation-ps2':
        return 'PLAYSTATION 2 BROWSER';
      case 'playstation-ps4':
        return 'PLAYSTATION 4 SYSTEM SOFTWARE';
      case 'playstation-xmb':
        return 'XMB INTERFACE';
      case 'playstation-modern':
        return 'PLAYSTATION HOME';
      case 'switch':
        return 'NINTENDO SWITCH';
      case 'gamecube':
        return 'GAMECUBE SYSTEM MENU';
      case 'n64':
        return 'NINTENDO 64';
      case 'gameboy':
        return 'HANDHELD SYSTEM';
      case 'dreamcast':
        return 'DREAMCAST CONSOLE';
      case 'sega':
        return 'SEGA SYSTEM';
      case 'nintendo-classic':
        return 'NINTENDO SYSTEM';
      case 'arcade':
        return 'ARCADE SYSTEM';
      default:
        return 'ECLIPSE CONSOLE ENVIRONMENT';
    }
  }

  String get _bootStatus {
    if (widget.system.romCount == 0) return 'Preparing your console space';
    return 'Preparing ${widget.system.romCount} games for your library';
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
            colors: [_accent.withValues(alpha: 0.25), const Color(0xFF090B10)],
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
                        _bootLabel,
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
                        _bootStatus.toUpperCase(),
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
    switch (_interfaceFamily) {
      case 'psp':
        return _buildPspHome();
      case 'wii':
        return _buildWiiHome();
      case 'ds':
        return _buildDsHome();
      case 'xbox':
        return _buildXboxHome();
      case 'xbox360':
        return _buildXbox360Home();
      case 'playstation-ps1':
        return _buildPs1Home();
      case 'playstation-ps2':
        return _buildPs2Home();
      case 'playstation-ps4':
        return _buildPlayStation4Home();
      case 'playstation-modern':
        return _buildPlayStationModernHome();
      case 'playstation-xmb':
        return _buildPlayStationXmbHome();
      case 'playstation-classic':
        return _buildPlayStationClassicHome();
      case 'switch':
        return _buildSwitchHome();
      case 'gamecube':
        return _buildGameCubeHome();
      case 'n64':
        return _buildN64Home();
      case 'gameboy':
        return _buildGameBoyHome();
      case 'dreamcast':
        return _buildDreamcastHome();
      case 'sega':
        return _buildSegaHome();
      case 'nintendo-classic':
        return _buildNintendoClassicHome();
      case 'arcade':
        return _buildArcadeHome();
      default:
        return _buildConsoleHome();
    }
  }

  Widget _buildXboxHome() {
    return _buildShell(
      eyebrow: 'Xbox dashboard',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HOME',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _FeaturePanel(
                    accent: _accent,
                    icon: Icons.sports_esports,
                    title: 'My games',
                    subtitle: '${widget.system.romCount} games ready',
                    onTap: _openLibrary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: _FeaturePanel(
                          accent: _accent,
                          icon: Icons.person,
                          title: 'Profile',
                          subtitle: 'Player space',
                          onTap: _showSystemInfo,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _FeaturePanel(
                          accent: _accent,
                          icon: Icons.settings,
                          title: 'Settings',
                          subtitle: 'Console info',
                          onTap: _showSystemInfo,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXbox360Home() {
    return _buildShell(
      eyebrow: 'Xbox 360 dashboard',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'XBOX 360',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Welcome to your dashboard',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _FeaturePanel(
                    accent: _accent,
                    icon: Icons.sports_esports,
                    title: 'Game Library',
                    subtitle: '${widget.system.romCount} games ready',
                    onTap: _openLibrary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: _FeaturePanel(
                          accent: _accent,
                          icon: Icons.person_outline,
                          title: 'Player Profile',
                          subtitle: 'Console profile',
                          onTap: _showSystemInfo,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _FeaturePanel(
                          accent: _accent,
                          icon: Icons.settings,
                          title: 'System Settings',
                          subtitle: 'Console details',
                          onTap: _showSystemInfo,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPs1Home() {
    return _buildShell(
      eyebrow: 'PlayStation memory card',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.album_outlined, color: Colors.white70, size: 68),
            const SizedBox(height: 14),
            const Text(
              'SONY PLAYSTATION',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Insert a virtual disc',
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 26),
            _HomeTile(
              accent: _accent,
              icon: Icons.album,
              title: 'CD Player / Game Disc',
              subtitle: '${widget.system.romCount} titles in your collection',
              onTap: _openLibrary,
            ),
            const SizedBox(height: 12),
            _HomeTile(
              accent: _accent,
              icon: Icons.sd_storage,
              title: 'Memory Card',
              subtitle: 'Browse saved game collection',
              onTap: _showSystemInfo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPs2Home() {
    return _buildShell(
      eyebrow: 'PlayStation 2 browser',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _accent.withValues(alpha: .65),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.videogame_asset_rounded,
                color: _accent,
                size: 76,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'BROWSER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.system.romCount} games available',
              style: const TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 22),
            _HomeTile(
              accent: _accent,
              icon: Icons.sports_esports,
              title: 'Start Game',
              subtitle: 'Open your PS2 game collection',
              onTap: _openLibrary,
            ),
            const SizedBox(height: 12),
            _HomeTile(
              accent: _accent,
              icon: Icons.settings,
              title: 'Console Settings',
              subtitle: 'System information',
              onTap: _showSystemInfo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayStation4Home() {
    const ps4Blue = Color(0xFF0070D1);
    return _buildShell(
      eyebrow: 'PlayStation 4 home',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'PLAYSTATION 4',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
              const Spacer(),
              Icon(Icons.wifi, color: Colors.white.withValues(alpha: .65)),
              const SizedBox(width: 12),
              Icon(
                Icons.notifications_none,
                color: Colors.white.withValues(alpha: .65),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.person_outline,
                color: Colors.white.withValues(alpha: .65),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _XmbCategory(
                icon: Icons.auto_awesome,
                label: "What's New",
                accent: ps4Blue,
                selected: true,
              ),
              const SizedBox(width: 14),
              _XmbCategory(
                icon: Icons.explore_outlined,
                label: 'Explore',
                accent: ps4Blue,
              ),
              const SizedBox(width: 14),
              _XmbCategory(
                icon: Icons.sports_esports,
                label: 'Library',
                accent: ps4Blue,
              ),
              const SizedBox(width: 14),
              _XmbCategory(
                icon: Icons.settings_outlined,
                label: 'Settings',
                accent: ps4Blue,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _FeaturePanel(
                    accent: ps4Blue,
                    icon: Icons.grid_view_rounded,
                    title: 'Game Library',
                    subtitle:
                        '${widget.system.romCount} PS4 packages in your ECLIPSE library',
                    onTap: _openLibrary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: _HomeTile(
                          accent: ps4Blue,
                          icon: Icons.folder_open_rounded,
                          title: 'Your Games',
                          subtitle: 'Browse your PS4 collection',
                          onTap: _openLibrary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _HomeTile(
                          accent: ps4Blue,
                          icon: Icons.sports_esports_rounded,
                          title: 'Bachata S4',
                          subtitle: 'Open the PS4 emulator',
                          onTap: _openPs4Emulator,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _HomeTile(
                          accent: ps4Blue,
                          icon: Icons.tune_rounded,
                          title: 'Console Settings',
                          subtitle: 'ECLIPSE system options',
                          onTap: _showSystemInfo,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayStationModernHome() {
    return _buildShell(
      eyebrow: 'PlayStation home',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your games',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _FeaturePanel(
                    accent: _accent,
                    icon: Icons.grid_view_rounded,
                    title: 'Game library',
                    subtitle: '${widget.system.romCount} installed titles',
                    onTap: _openLibrary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FeaturePanel(
                    accent: _accent,
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    subtitle: 'System information',
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

  Widget _buildPlayStationXmbHome() {
    return _buildShell(
      eyebrow: 'XMB home',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          Row(
            children: [
              _XmbCategory(
                icon: Icons.person_outline,
                label: 'Users',
                accent: _accent,
              ),
              const SizedBox(width: 18),
              _XmbCategory(
                icon: Icons.settings_outlined,
                label: 'Settings',
                accent: _accent,
              ),
              const SizedBox(width: 18),
              _XmbCategory(
                icon: Icons.photo_library_outlined,
                label: 'Photo',
                accent: _accent,
              ),
              const SizedBox(width: 18),
              _XmbCategory(
                icon: Icons.music_note,
                label: 'Music',
                accent: _accent,
              ),
              const SizedBox(width: 18),
              _XmbCategory(
                icon: Icons.sports_esports,
                label: 'Game',
                accent: _accent,
                selected: true,
              ),
            ],
          ),
          const SizedBox(height: 26),
          _HomeTile(
            accent: _accent,
            icon: Icons.folder_open,
            title: 'Game Library',
            subtitle: '${widget.system.romCount} titles available',
            onTap: _openLibrary,
          ),
          const SizedBox(height: 12),
          _HomeTile(
            accent: _accent,
            icon: Icons.info_outline,
            title: 'System Information',
            subtitle: 'Console details',
            onTap: _showSystemInfo,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayStationClassicHome() {
    return _buildShell(
      eyebrow: 'PlayStation menu',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle_outlined, size: 68, color: _accent),
            const SizedBox(height: 14),
            const Text(
              'MEMORY CARD',
              style: TextStyle(
                color: Colors.white70,
                letterSpacing: 3,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 24),
            _HomeTile(
              accent: _accent,
              icon: Icons.album_outlined,
              title: 'Game Disc',
              subtitle: 'Browse your game collection',
              onTap: _openLibrary,
            ),
            const SizedBox(height: 12),
            _HomeTile(
              accent: _accent,
              icon: Icons.sd_storage_outlined,
              title: 'Memory Card',
              subtitle: '${widget.system.romCount} games in library',
              onTap: _openLibrary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchHome() {
    return _buildShell(
      eyebrow: 'Nintendo Switch home',
      child: Column(
        children: [
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _RoundMenuButton(
                  icon: Icons.sports_esports,
                  label: 'Game Library',
                  accent: _accent,
                  onTap: _openLibrary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RoundMenuButton(
                  icon: Icons.photo_library,
                  label: 'Albums',
                  accent: _accent,
                  onTap: _showSystemInfo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RoundMenuButton(
                  icon: Icons.settings,
                  label: 'System Settings',
                  accent: _accent,
                  onTap: _showSystemInfo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '${widget.system.romCount} games',
            style: const TextStyle(color: Colors.white60),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildGameCubeHome() {
    return _buildShell(
      eyebrow: 'Nintendo GameCube',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withValues(alpha: .14),
                border: Border.all(color: _accent, width: 3),
              ),
              child: Icon(
                Icons.videogame_asset_rounded,
                size: 82,
                color: _accent,
              ),
            ),
            const SizedBox(height: 28),
            _HomeTile(
              accent: _accent,
              icon: Icons.sports_esports,
              title: 'Start Game',
              subtitle: '${widget.system.romCount} games available',
              onTap: _openLibrary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildN64Home() {
    return _buildShell(
      eyebrow: 'Nintendo 64 select',
      child: Center(
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            _ChannelTile(
              accent: _accent,
              icon: Icons.sports_esports,
              label: 'Game Pak',
              onTap: _openLibrary,
            ),
            _ChannelTile(
              accent: _accent,
              icon: Icons.settings,
              label: 'Options',
              onTap: _showSystemInfo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameBoyHome() {
    return _buildShell(
      eyebrow: 'Handheld library',
      child: Center(
        child: Container(
          width: 230,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFB8C9A0),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white24, width: 5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'DOT MATRIX',
                style: TextStyle(
                  color: Color(0xFF273526),
                  letterSpacing: 3,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              const Icon(
                Icons.videogame_asset,
                color: Color(0xFF273526),
                size: 52,
              ),
              const SizedBox(height: 18),
              _DarkMenuButton(label: 'START', onTap: _openLibrary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDreamcastHome() {
    return _buildShell(
      eyebrow: 'Dreamcast menu',
      child: Center(
        child: Wrap(
          spacing: 18,
          runSpacing: 18,
          alignment: WrapAlignment.center,
          children: [
            _ChannelTile(
              accent: _accent,
              icon: Icons.sports_esports,
              label: 'Play',
              onTap: _openLibrary,
            ),
            _ChannelTile(
              accent: _accent,
              icon: Icons.sd_storage,
              label: 'Memory',
              onTap: _showSystemInfo,
            ),
            _ChannelTile(
              accent: _accent,
              icon: Icons.settings,
              label: 'Settings',
              onTap: _showSystemInfo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegaHome() {
    return _buildShell(
      eyebrow: 'SEGA collection',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SEGA',
              style: TextStyle(
                color: _accent,
                fontSize: 54,
                fontWeight: FontWeight.w900,
                letterSpacing: 7,
              ),
            ),
            const SizedBox(height: 28),
            _HomeTile(
              accent: _accent,
              icon: Icons.sports_esports,
              title: 'Cartridge Select',
              subtitle: '${widget.system.romCount} games ready',
              onTap: _openLibrary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNintendoClassicHome() {
    return _buildShell(
      eyebrow: 'Nintendo game select',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'SELECT GAME',
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 22),
            _HomeTile(
              accent: _accent,
              icon: Icons.grid_view_rounded,
              title: 'Game Library',
              subtitle: '${widget.system.romCount} titles',
              onTap: _openLibrary,
            ),
          ],
        ),
      ),
    );
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
          padding: EdgeInsets.fromLTRB(
            MediaQuery.sizeOf(context).width < 600 ? 18 : 32,
            MediaQuery.sizeOf(context).height < 520 ? 14 : 22,
            MediaQuery.sizeOf(context).width < 600 ? 18 : 32,
            MediaQuery.sizeOf(context).height < 520 ? 14 : 24,
          ),
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
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildPlatformSpotlight(),
              if (eyebrow != null) ...[
                const SizedBox(height: 18),
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
              const SizedBox(height: 12),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }

  /// A Daijisho-style platform showcase with a Cocoon-inspired hardware
  /// foreground. Uses the system's configured artwork as the backdrop; it
  /// never invents gameplay footage or downloads copyrighted media.
  Widget _buildPlatformSpotlight() {
    final system = widget.system;
    final backdrop = system.carouselImagePath;
    final iconPath = system.iconImage;
    final hasBackdrop = backdrop.isNotEmpty && File(backdrop).existsSync();
    final hasIcon = iconPath.isNotEmpty && File(iconPath).existsSync();

    return Container(
      height: MediaQuery.sizeOf(context).height < 520 ? 142 : 184,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        color: const Color(0xFF111522),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_featuredVideoController?.value.isInitialized == true)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _featuredVideoController!.value.size.width,
                height: _featuredVideoController!.value.size.height,
                child: VideoPlayer(_featuredVideoController!),
              ),
            )
          else if (hasBackdrop)
            Image.file(
              File(backdrop),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.expand(),
            )
          else
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accent.withValues(alpha: 0.48),
                    const Color(0xFF111522),
                    const Color(0xFF080A0F),
                  ],
                ),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFF080A0F).withValues(alpha: 0.94),
                  const Color(0xFF080A0F).withValues(alpha: 0.62),
                  const Color(0xFF080A0F).withValues(alpha: 0.12),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _featuredGameTitle == null
                            ? 'PLATFORM SPOTLIGHT'
                            : 'GAMEPLAY PREVIEW  ·  ${_featuredGameTitle!.toUpperCase()}',
                        maxLines: 1,
                        style: TextStyle(
                          color: _accent,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.2,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        (system.shortName ?? system.realName).toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          height: 1.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.7,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${system.romCount} GAMES  ·  ${system.manufacturer ?? 'YOUR COLLECTION'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 112,
                      height: 112,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.30),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: hasIcon
                          ? Image.file(
                              File(iconPath),
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => Icon(
                                Icons.videogame_asset_rounded,
                                color: Colors.white,
                                size: 58,
                              ),
                            )
                          : Icon(
                              Icons.videogame_asset_rounded,
                              color: Colors.white,
                              size: 58,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  void _moveWiiPointer(Offset delta) {
    setState(() {
      _wiiPointer = Offset(
        (_wiiPointer.dx + delta.dx).clamp(0.02, 0.98),
        (_wiiPointer.dy + delta.dy).clamp(0.02, 0.98),
      );
    });
  }

  void _listenForWiiStick() {
    _wiiPointerSubscription?.cancel();
    double? axisX;
    double? axisY;
    _wiiPointerSubscription = Gamepads.events.listen((event) {
      if (!mounted || _booting || _interfaceFamily != 'wii') return;
      final key = event.key.toLowerCase();
      final raw = event.value;
      final normalized = raw.abs() > 1.5
          ? (raw / 32767.0).clamp(-1.0, 1.0)
          : raw.clamp(-1.0, 1.0);
      if (key.contains('left') &&
          (key.contains('x') || key.contains('horizontal'))) {
        axisX = normalized;
      } else if ((key.contains('axis_x') ||
          key == 'x' ||
          key.contains('abs_x'))) {
        axisX = normalized;
      } else if (key.contains('left') &&
          (key.contains('y') || key.contains('vertical'))) {
        axisY = normalized;
      } else if ((key.contains('axis_y') ||
          key == 'y' ||
          key.contains('abs_y'))) {
        axisY = normalized;
      } else {
        return;
      }
      final now = DateTime.now();
      if (now.difference(_lastWiiAxisUpdate).inMilliseconds < 16) return;
      _lastWiiAxisUpdate = now;
      final x = (axisX ?? 0).abs() < .16 ? 0.0 : axisX!;
      final y = (axisY ?? 0).abs() < .16 ? 0.0 : axisY!;
      if (x != 0 || y != 0) {
        _moveWiiPointer(Offset(x * .025, y * .025));
      }
    });
  }

  Widget _buildWiiHome() {
    return _buildShell(
      eyebrow: 'Wii channel menu',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (details) => _moveWiiPointer(
              Offset(details.delta.dx / width, details.delta.dy / height),
            ),
            onTapDown: (details) {
              setState(
                () => _wiiPointer = Offset(
                  (details.localPosition.dx / width).clamp(.02, .98),
                  (details.localPosition.dy / height).clamp(.02, .98),
                ),
              );
            },
            child: Stack(
              children: [
                Column(
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
                              icon: Icons.album_rounded,
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
                              label: 'Wii Settings',
                              onTap: _showSystemInfo,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      '${widget.system.romCount} games available  •  Move pointer to select a channel',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: (_wiiPointer.dx * width - 13).clamp(0.0, width - 26),
                  top: (_wiiPointer.dy * height - 13).clamp(0.0, height - 26),
                  child: IgnorePointer(
                    child: Icon(
                      Icons.ads_click_rounded,
                      color: Colors.white,
                      size: 26,
                      shadows: const [
                        Shadow(color: Colors.black, blurRadius: 8),
                      ],
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

  Widget _buildArcadeHome() {
    return _buildShell(
      eyebrow: 'Arcade machine select',
      child: Column(
        children: [
          const Spacer(),
          Icon(Icons.sports_esports_rounded, size: 70, color: _accent),
          const SizedBox(height: 18),
          const Text(
            'INSERT COIN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.system.romCount} arcade titles ready',
            style: const TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 26),
          _HomeTile(
            accent: _accent,
            icon: Icons.play_arrow_rounded,
            title: 'Start',
            subtitle: 'Open arcade game library',
            onTap: _openLibrary,
          ),
          const Spacer(),
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

class _FeaturePanel extends StatelessWidget {
  const _FeaturePanel({
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
  Widget build(BuildContext context) => Material(
    color: Colors.white.withValues(alpha: .08),
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 34),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RoundMenuButton extends StatelessWidget {
  const _RoundMenuButton({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Column(
      children: [
        Container(
          height: 66,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .08),
            shape: BoxShape.circle,
            border: Border.all(color: accent.withValues(alpha: .6)),
          ),
          child: Center(child: Icon(icon, color: accent, size: 27)),
        ),
        const SizedBox(height: 9),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    ),
  );
}

class _XmbCategory extends StatelessWidget {
  const _XmbCategory({
    required this.icon,
    required this.label,
    required this.accent,
    this.selected = false,
  });
  final IconData icon;
  final String label;
  final Color accent;
  final bool selected;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(
        icon,
        size: selected ? 33 : 26,
        color: selected ? accent : Colors.white54,
      ),
      const SizedBox(height: 6),
      Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.white54,
          fontSize: 9,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ],
  );
}

class _DarkMenuButton extends StatelessWidget {
  const _DarkMenuButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFF273526),
        foregroundColor: const Color(0xFFB8C9A0),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
      ),
    ),
  );
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
        border: Border.all(color: system.colorAsColor.withValues(alpha: 0.55)),
      ),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(
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
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
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

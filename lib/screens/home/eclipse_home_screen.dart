import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';

import '../../models/system_model.dart';
import '../../models/game_model.dart';
import '../../services/game_service.dart';
import '../../providers/sqlite_config_provider.dart';
import '../../providers/file_provider.dart';
import '../../l10n/app_locale.dart';

/// The ECLIPSE landing page. The existing Systems screen remains the full
/// library and first-run ROM setup; this page is the console-style front door.
class EclipseHomeScreen extends StatefulWidget {
  const EclipseHomeScreen({
    super.key,
    required this.onOpenSystems,
    required this.onOpenEntertainment,
    required this.onOpenAchievements,
    required this.onOpenSettings,
    required this.onOpenSearch,
    required this.onOpenAi,
  });

  final VoidCallback onOpenSystems;
  final VoidCallback onOpenEntertainment;
  final VoidCallback onOpenAchievements;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenAi;

  static const Color _void = Color(0xFF100C19);
  static const Color _plum = Color(0xFF211832);
  static const Color _violet = Color(0xFF9B7BFF);
  static const Color _cyan = Color(0xFF65D9E8);
  static const Color _lunar = Color(0xFFF3EEFF);

  static bool navigateLeft() => _EclipseHomeScreenState._current?._move(-1) ?? false;
  static bool navigateRight() => _EclipseHomeScreenState._current?._move(1) ?? false;
  static bool navigateUp() => _EclipseHomeScreenState._current?._moveVertical(-1) ?? false;
  static bool navigateDown() => _EclipseHomeScreenState._current?._moveVertical(1) ?? false;
  static void selectCurrent() => _EclipseHomeScreenState._current?._activate();

  @override
  State<EclipseHomeScreen> createState() => _EclipseHomeScreenState();
}

class _EclipseHomeScreenState extends State<EclipseHomeScreen>
    with WidgetsBindingObserver {
  static _EclipseHomeScreenState? _current;
  int _selectedActionIndex = 0;
  int _actionColumns = 2;
  List<VoidCallback> _actionCallbacks = const [];
  Future<List<GameModel>>? _recentGamesFuture;
  List<GameModel> _libraryGames = const [];
  VideoPlayerController? _featuredVideoController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _current = this;
    GameService.deviceScreenOn.addListener(_syncPreviewPlayback);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final config = context.read<SqliteConfigProvider>();
      setState(() => _recentGamesFuture = _loadRecentGames(config));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    GameService.deviceScreenOn.removeListener(_syncPreviewPlayback);
    _featuredVideoController?.dispose();
    if (identical(_current, this)) _current = null;
    super.dispose();
  }

  Future<List<GameModel>> _loadRecentGames(SqliteConfigProvider config) async {
    final supportedSystems = config.detectedSystems.where(
      (system) =>
          system.id != null &&
          system.folderName != 'android' &&
          system.folderName != 'music',
    );
    final lists = await Future.wait(
      supportedSystems.map((system) => GameService.loadGamesForSystem(system)),
    );
    final allGames = lists.expand((games) => games).toList();
    if (mounted) {
      setState(() => _libraryGames = allGames);
    }
    final recent = GameService.getRecentlyPlayedGames(allGames);
    await _loadFeaturedPreview(recent);
    return recent;
  }

  Future<void> _loadFeaturedPreview(List<GameModel> games) async {
    final fileProvider = context.read<FileProvider>();
    for (final game in games) {
      final systemFolder = game.systemFolderName;
      if (systemFolder == null || systemFolder.isEmpty) continue;
      final videoPath = game.getVideoPath(systemFolder, fileProvider);
      if (!await fileProvider.fileExists(videoPath)) continue;

      final controller = VideoPlayerController.file(File(videoPath));
      try {
        await controller.initialize();
        await controller.setLooping(true);
        await controller.setVolume(0);
        if (!mounted) {
          await controller.dispose();
          return;
        }
        setState(() => _featuredVideoController = controller);
        _syncPreviewPlayback();
        return;
      } catch (_) {
        await controller.dispose();
      }
    }
  }

  void _syncPreviewPlayback() {
    final controller = _featuredVideoController;
    if (!mounted || controller == null || !controller.value.isInitialized) {
      return;
    }
    final shouldPlay =
        GameService.deviceScreenOn.value &&
        !GameService.isGameLaunchInProgress &&
        (ModalRoute.of(context)?.isCurrent ?? true);
    if (shouldPlay && !controller.value.isPlaying) {
      controller.play();
    } else if (!shouldPlay && controller.value.isPlaying) {
      controller.pause();
    }
  }

  Future<void> _launchRandomGame(
    BuildContext context,
    SqliteConfigProvider config,
  ) async {
    if (_libraryGames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocale.noGamesAvailable.getString(context)),
        ),
      );
      return;
    }
    final game = _libraryGames[math.Random().nextInt(_libraryGames.length)];
    await _launchRecentGame(context, config, game);
  }

  Future<void> _launchRecentGame(
    BuildContext context,
    SqliteConfigProvider config,
    GameModel game,
  ) async {
    SystemModel? system;
    for (final candidate in config.detectedSystems) {
      if (candidate.folderName == game.systemFolderName) {
        system = candidate;
        break;
      }
    }
    if (system == null) return;
    await _featuredVideoController?.pause();
    if (!context.mounted) return;
    await GameService.launchGame(context, system, game);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncPreviewPlayback();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _featuredVideoController?.pause();
    }
  }

  bool _move(int delta) {
    if (_actionCallbacks.isEmpty) return false;
    final next = (_selectedActionIndex + delta)
        .clamp(0, _actionCallbacks.length - 1)
        .toInt();
    if (next == _selectedActionIndex) return false;
    setState(() => _selectedActionIndex = next);
    return true;
  }

  bool _moveVertical(int direction) => _move(direction * _actionColumns);

  void _activate() {
    if (_actionCallbacks.isEmpty) return;
    _actionCallbacks[_selectedActionIndex]();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SqliteConfigProvider>(
      builder: (context, config, _) {
        final systems = config.detectedSystems;
        final featured = systems.isEmpty ? null : systems.first;
        final showEntertainment =
            Platform.isAndroid && config.config.androidAppsAsTab;

        return SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  wide ? 30 : 16,
                  58,
                  wide ? 30 : 16,
                  28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopline(context),
                        const SizedBox(height: 18),
                        _buildHero(
                          context,
                          totalGames: config.totalGames,
                          systems: systems.length,
                          featured: featured,
                          onOpenSystems: widget.onOpenSystems,
                          onOpenSearch: widget.onOpenSearch,
                          wide: wide,
                        ),
                        _buildContinuePlaying(context, config),
                        const SizedBox(height: 24),
                        _sectionHeading('YOUR SPACE', 'Jump back into ECLIPSE'),
                        const SizedBox(height: 12),
                        _buildActionGrid(
                          context,
                          wide: wide,
                          showEntertainment: showEntertainment,
                        ),
                        if (systems.isNotEmpty) ...[
                          const SizedBox(height: 26),
                          _sectionHeading(
                            'YOUR SYSTEMS',
                            'Pick a world to explore',
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 142,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: systems.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) => _SystemTile(
                                system: systems[index],
                                onTap: widget.onOpenSystems,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        _buildAssistantStrip(context),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openCommandPalette() async {
    final commands = <({String title, String detail, IconData icon, VoidCallback run})>[
      (title: 'Open game library', detail: 'Browse every system and game', icon: Icons.sports_esports_rounded, run: widget.onOpenSystems),
      (title: 'Search your library', detail: 'Find a game by name', icon: Icons.search_rounded, run: widget.onOpenSearch),
      (title: 'Achievements', detail: 'View your achievement progress', icon: Icons.emoji_events_rounded, run: widget.onOpenAchievements),
      (title: 'Entertainment', detail: 'Open installed Android apps', icon: Icons.live_tv_rounded, run: widget.onOpenEntertainment),
      (title: 'Settings', detail: 'Configure your ECLIPSE setup', icon: Icons.tune_rounded, run: widget.onOpenSettings),
      (title: 'ECLIPSE assistant', detail: 'Ask the assistant for help', icon: Icons.auto_awesome_rounded, run: widget.onOpenAi),
    ];
    final searchController = TextEditingController();
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refresh) {
          final query = searchController.text.trim().toLowerCase();
          final visible = commands.where((item) =>
            item.title.toLowerCase().contains(query) ||
            item.detail.toLowerCase().contains(query)).toList();
          return Dialog(
            backgroundColor: const Color(0xFF171122),
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: EclipseHomeScreen._violet.withValues(alpha: 0.38)),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560, maxHeight: 620),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.bolt_rounded, color: EclipseHomeScreen._cyan, size: 24),
                      const SizedBox(width: 10),
                      const Expanded(child: Text('ECLIPSE COMMAND', style: TextStyle(color: EclipseHomeScreen._lunar, fontWeight: FontWeight.w900, letterSpacing: 1.8))),
                      IconButton(onPressed: () => Navigator.pop(dialogContext), icon: const Icon(Icons.close_rounded, color: Colors.white70)),
                    ]),
                    const SizedBox(height: 6),
                    Text('Your universe, one command away.', style: TextStyle(color: EclipseHomeScreen._lunar.withValues(alpha: 0.62), fontSize: 12)),
                    const SizedBox(height: 18),
                    TextField(
                      controller: searchController,
                      autofocus: true,
                      onChanged: (_) => refresh(() {}),
                      style: const TextStyle(color: EclipseHomeScreen._lunar),
                      decoration: InputDecoration(
                        hintText: 'Search actions…',
                        hintStyle: TextStyle(color: EclipseHomeScreen._lunar.withValues(alpha: 0.42)),
                        prefixIcon: const Icon(Icons.search_rounded, color: EclipseHomeScreen._cyan),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.045),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: EclipseHomeScreen._violet.withValues(alpha: 0.25))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: EclipseHomeScreen._violet.withValues(alpha: 0.25))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: EclipseHomeScreen._violet)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Flexible(
                      child: visible.isEmpty
                        ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('No matching commands', style: TextStyle(color: EclipseHomeScreen._lunar.withValues(alpha: 0.55)))))
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: visible.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 7),
                            itemBuilder: (context, index) {
                              final item = visible[index];
                              return ListTile(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                tileColor: Colors.white.withValues(alpha: 0.035),
                                leading: Icon(item.icon, color: EclipseHomeScreen._cyan),
                                title: Text(item.title, style: const TextStyle(color: EclipseHomeScreen._lunar, fontWeight: FontWeight.w700)),
                                subtitle: Text(item.detail, style: TextStyle(color: EclipseHomeScreen._lunar.withValues(alpha: 0.55), fontSize: 11)),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
                                onTap: () {
                                  Navigator.pop(dialogContext);
                                  item.run();
                                },
                              );
                            },
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text('QUICK ACCESS  •  ECLIPSE', style: TextStyle(color: EclipseHomeScreen._cyan.withValues(alpha: 0.65), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.3)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    searchController.dispose();
  }

  Widget _buildTopline(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: EclipseHomeScreen._violet.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: EclipseHomeScreen._violet.withValues(alpha: 0.35)),
          ),
          child: SvgPicture.asset(
            'assets/branding/eclipse-mark.svg',
            fit: BoxFit.contain,
            semanticsLabel: 'ECLIPSE',
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'ECLIPSE',
          style: TextStyle(
            color: EclipseHomeScreen._lunar,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.2,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'ECLIPSE Command',
          onPressed: _openCommandPalette,
          icon: const Icon(Icons.bolt_rounded, color: EclipseHomeScreen._cyan),
          style: IconButton.styleFrom(
            backgroundColor: EclipseHomeScreen._violet.withValues(alpha: 0.12),
            side: BorderSide(color: EclipseHomeScreen._violet.withValues(alpha: 0.3)),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'YOUR GAMING UNIVERSE',
          style: TextStyle(
            color: EclipseHomeScreen._cyan.withValues(alpha: 0.82),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHero(
    BuildContext context, {
    required int totalGames,
    required int systems,
    required SystemModel? featured,
    required VoidCallback onOpenSystems,
    required VoidCallback onOpenSearch,
    required bool wide,
  }) {
    final heroHeight = wide ? 310.0 : 278.0;
    return Container(
      height: heroHeight,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: EclipseHomeScreen._violet.withValues(alpha: 0.32)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [EclipseHomeScreen._plum, EclipseHomeScreen._void, Color(0xFF101B2A)],
        ),
        boxShadow: [
          BoxShadow(
            color: EclipseHomeScreen._violet.withValues(alpha: 0.12),
            blurRadius: 32,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Stack(
        children: [
          if (_featuredVideoController?.value.isInitialized == true)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _featuredVideoController!.value.size.width,
                  height: _featuredVideoController!.value.size.height,
                  child: VideoPlayer(_featuredVideoController!),
                ),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    EclipseHomeScreen._void.withValues(alpha: 0.94),
                    EclipseHomeScreen._void.withValues(alpha: 0.68),
                    EclipseHomeScreen._void.withValues(alpha: 0.30),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -40,
            top: -90,
            child: Container(
              width: wide ? 360 : 270,
              height: wide ? 360 : 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: EclipseHomeScreen._violet.withValues(alpha: 0.20),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: EclipseHomeScreen._violet.withValues(alpha: 0.17),
                    blurRadius: 65,
                    spreadRadius: 12,
                  ),
                ],
              ),
            ),
          ),
          if (featured != null)
            Positioned(
              right: wide ? 78 : 16,
              bottom: -18,
              child: Opacity(
                opacity: 0.16,
                child: SizedBox(
                  width: wide ? 250 : 175,
                  height: wide ? 250 : 175,
                  child: _systemArtwork(featured, fit: BoxFit.contain),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(wide ? 30 : 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: EclipseHomeScreen._cyan.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: EclipseHomeScreen._cyan.withValues(alpha: 0.25)),
                  ),
                  child: const Text(
                    'THE UNIVERSE IS YOURS',
                    style: TextStyle(
                      color: EclipseHomeScreen._cyan,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Ready when\nyou are.',
                  style: TextStyle(
                    color: EclipseHomeScreen._lunar,
                    fontSize: wide ? 40 : 34,
                    height: 0.98,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$totalGames games  •  $systems systems',
                  style: TextStyle(
                    color: EclipseHomeScreen._lunar.withValues(alpha: 0.66),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: onOpenSystems,
                      icon: const Icon(Icons.sports_esports_rounded, size: 18),
                      label: const Text('Open library'),
                      style: FilledButton.styleFrom(
                        backgroundColor: EclipseHomeScreen._violet,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 13,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onOpenSearch,
                      icon: const Icon(Icons.search_rounded, size: 18),
                      label: const Text('Search'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: EclipseHomeScreen._lunar,
                        side: BorderSide(
                          color: EclipseHomeScreen._lunar.withValues(alpha: 0.25),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinuePlaying(
    BuildContext context,
    SqliteConfigProvider config,
  ) {
    final future = _recentGamesFuture;
    if (future == null) return const SizedBox.shrink();

    return FutureBuilder<List<GameModel>>(
      future: future,
      builder: (context, snapshot) {
        final games = snapshot.data ?? const <GameModel>[];
        if (games.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeading('PICK UP WHERE YOU LEFT OFF', 'Continue playing'),
            const SizedBox(height: 12),
            SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: games.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final game = games[index];
                  return _RecentGameTile(
                    game: game,
                    onTap: () => _launchRecentGame(context, config, game),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionHeading(String eyebrow, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: EclipseHomeScreen._cyan,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: EclipseHomeScreen._lunar,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid(
    BuildContext context, {
    required bool wide,
    required bool showEntertainment,
  }) {
    final actions = <_HomeAction>[
      _HomeAction(
        icon: Icons.grid_view_rounded,
        title: 'Game library',
        subtitle: 'All your systems and games',
        onTap: widget.onOpenSystems,
        accent: EclipseHomeScreen._violet,
      ),
      _HomeAction(
        icon: Icons.emoji_events_rounded,
        title: 'Achievements',
        subtitle: 'Your unlocks and progress',
        onTap: widget.onOpenAchievements,
        accent: EclipseHomeScreen._cyan,
      ),
      if (showEntertainment)
        _HomeAction(
          icon: Icons.live_tv_rounded,
          title: 'Entertainment',
          subtitle: 'Your installed media apps',
          onTap: widget.onOpenEntertainment,
          accent: const Color(0xFFE5A8FF),
        ),
      _HomeAction(
        icon: Icons.tune_rounded,
        title: 'Settings',
        subtitle: 'Make ECLIPSE yours',
        onTap: widget.onOpenSettings,
        accent: const Color(0xFFB8A6FF),
      ),
      _HomeAction(
        icon: Icons.shuffle_rounded,
        title: AppLocale.randomGame.getString(context),
        subtitle: AppLocale.play.getString(context),
        onTap: () => _launchRandomGame(
          context,
          context.read<SqliteConfigProvider>(),
        ),
        accent: EclipseHomeScreen._cyan,
      ),
    ];

    _actionColumns = wide ? 4 : 2;
    _actionCallbacks = actions.map((action) => action.onTap).toList();
    if (_selectedActionIndex >= actions.length) {
      _selectedActionIndex = actions.length - 1;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: wide ? 4 : 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 112,
      ),
      itemBuilder: (context, index) => _ActionTile(
        action: actions[index],
        selected: index == _selectedActionIndex,
      ),
    );
  }

  Widget _buildAssistantStrip(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.045),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: widget.onOpenAi,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: EclipseHomeScreen._violet, size: 22),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ECLIPSE AI',
                      style: TextStyle(
                        color: EclipseHomeScreen._lunar,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Ask, search, or jump to a section',
                      style: TextStyle(color: Colors.white60, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _systemArtwork(SystemModel system, {BoxFit fit = BoxFit.contain}) {
    final path = system.iconImage.startsWith('assets/')
        ? system.iconImage
        : 'assets${system.iconImage}';
    return Image.asset(
      path,
      fit: fit,
      errorBuilder: (_, _, _) => const Icon(
        Icons.videogame_asset_rounded,
        color: EclipseHomeScreen._lunar,
      ),
    );
  }
}

class _HomeAction {
  const _HomeAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color accent;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action, this.selected = false});

  final _HomeAction action;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.055),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? const Color(0xFF9B7BFF)
                  : Colors.white.withValues(alpha: 0.08),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(action.icon, color: action.accent, size: 23),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: const TextStyle(
                      color: Color(0xFFF3EEFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    action.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentGameTile extends StatelessWidget {
  const _RecentGameTile({required this.game, required this.onTap});

  final GameModel game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 238,
      child: Material(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9B7BFF).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Color(0xFFBDAAFF),
                    size: 25,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFF3EEFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        game.systemRealName ?? game.systemShortName ?? 'Game',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SystemTile extends StatelessWidget {
  const _SystemTile({required this.system, required this.onTap});

  final SystemModel system;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final path = system.iconImage.startsWith('assets/')
        ? system.iconImage
        : 'assets${system.iconImage}';

    return SizedBox(
      width: 176,
      child: Material(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                SizedBox(
                  width: 42,
                  height: 42,
                  child: Image.asset(
                    path,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.videogame_asset_rounded,
                      color: Color(0xFF9B7BFF),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        system.realName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFF3EEFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${system.romCount} games',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

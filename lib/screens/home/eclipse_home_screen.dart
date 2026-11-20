import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../models/system_model.dart';
import '../../providers/sqlite_config_provider.dart';

/// The ECLIPSE landing page. The existing Systems screen remains the full
/// library and first-run ROM setup; this page is the console-style front door.
class EclipseHomeScreen extends StatelessWidget {
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
                          onOpenSystems: onOpenSystems,
                          onOpenSearch: onOpenSearch,
                          wide: wide,
                        ),
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
                                onTap: onOpenSystems,
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

  Widget _buildTopline(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: _violet.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: _violet.withValues(alpha: 0.35)),
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
            color: _lunar,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.2,
          ),
        ),
        const Spacer(),
        Text(
          'YOUR GAMING UNIVERSE',
          style: TextStyle(
            color: _cyan.withValues(alpha: 0.82),
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
        border: Border.all(color: _violet.withValues(alpha: 0.32)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_plum, _void, Color(0xFF101B2A)],
        ),
        boxShadow: [
          BoxShadow(
            color: _violet.withValues(alpha: 0.12),
            blurRadius: 32,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -90,
            child: Container(
              width: wide ? 360 : 270,
              height: wide ? 360 : 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _violet.withValues(alpha: 0.20),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _violet.withValues(alpha: 0.17),
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
                    color: _cyan.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: _cyan.withValues(alpha: 0.25)),
                  ),
                  child: const Text(
                    'THE UNIVERSE IS YOURS',
                    style: TextStyle(
                      color: _cyan,
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
                    color: _lunar,
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
                    color: _lunar.withValues(alpha: 0.66),
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
                        backgroundColor: _violet,
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
                        foregroundColor: _lunar,
                        side: BorderSide(
                          color: _lunar.withValues(alpha: 0.25),
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

  Widget _sectionHeading(String eyebrow, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: _cyan,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: _lunar,
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
        onTap: onOpenSystems,
        accent: _violet,
      ),
      _HomeAction(
        icon: Icons.emoji_events_rounded,
        title: 'Achievements',
        subtitle: 'Your unlocks and progress',
        onTap: onOpenAchievements,
        accent: _cyan,
      ),
      if (showEntertainment)
        _HomeAction(
          icon: Icons.live_tv_rounded,
          title: 'Entertainment',
          subtitle: 'Your installed media apps',
          onTap: onOpenEntertainment,
          accent: const Color(0xFFE5A8FF),
        ),
      _HomeAction(
        icon: Icons.tune_rounded,
        title: 'Settings',
        subtitle: 'Make ECLIPSE yours',
        onTap: onOpenSettings,
        accent: const Color(0xFFB8A6FF),
      ),
    ];

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
      itemBuilder: (context, index) => _ActionTile(action: actions[index]),
    );
  }

  Widget _buildAssistantStrip(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.045),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onOpenAi,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: _violet, size: 22),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ECLIPSE AI',
                      style: TextStyle(
                        color: _lunar,
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
        color: _lunar,
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
  const _ActionTile({required this.action});

  final _HomeAction action;

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
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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

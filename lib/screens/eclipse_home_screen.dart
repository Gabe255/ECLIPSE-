import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neostation/providers/sqlite_config_provider.dart';
import 'package:neostation/providers/sqlite_database_provider.dart';
import 'package:provider/provider.dart';

import '../models/eclipse_experience_catalog.dart';
import '../widgets/eclipse_experience_switcher.dart';

import 'systems_screen/system_content.dart';

/// ECLIPSE's rebuilt main landing experience.
///
/// This deliberately composes the existing systems flow instead of reimplementing
/// ROM discovery or system launch routing. The console-specific experience remains
/// the destination after a platform is selected.
class EclipseHomeScreen extends StatefulWidget {
  const EclipseHomeScreen({
    super.key,
    this.selectedSystemIndex = 0,
    this.onSystemSelected,
    this.onOpenDiscovery,
    this.onOpenSettings,
    this.onOpenEntertainment,
    this.onQuickMenu,
    this.onSearch,
  });

  final int selectedSystemIndex;
  final ValueChanged<int>? onSystemSelected;
  final VoidCallback? onOpenDiscovery;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenEntertainment;
  final VoidCallback? onQuickMenu;
  final VoidCallback? onSearch;

  @override
  State<EclipseHomeScreen> createState() => _EclipseHomeScreenState();
}

class _EclipseHomeScreenState extends State<EclipseHomeScreen> {
  static const _ink = Color(0xFF080711);
  static const _violet = Color(0xFF9A72FF);
  static const _lavender = Color(0xFFD9CCFF);
  static const _experiencePreferenceKey = 'eclipse.selected_experience';
  String _selectedExperienceId = EclipseExperienceCatalog.defaultExperienceId;

  EclipseExperience get _experience =>
      EclipseExperienceCatalog.byId(_selectedExperienceId) ??
      EclipseExperienceCatalog.experiences.first;

  Color get _accent => switch (_experience.category) {
    'Xbox' => const Color(0xFF78D65B),
    'Nintendo' => const Color(0xFFFF6B73),
    'Sega' => const Color(0xFF70A9FF),
    'Arcade & Retro' => const Color(0xFFFFB45E),
    'Computers' || 'PC Gaming' => const Color(0xFF66D9D0),
    'Entertainment' => const Color(0xFFFF83C5),
    _ => const Color(0xFF9A72FF),
  };

  @override
  void initState() {
    super.initState();
    _loadExperience();
  }

  Future<void> _loadExperience() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_experiencePreferenceKey);
    if (!mounted ||
        saved == null ||
        EclipseExperienceCatalog.byId(saved) == null) {
      return;
    }
    setState(() => _selectedExperienceId = saved);
  }

  void _handleExperienceChanged(EclipseExperience experience) {
    setState(() => _selectedExperienceId = experience.id);
  }


  @override
  Widget build(BuildContext context) {
    return Consumer2<SqliteConfigProvider, SqliteDatabaseProvider>(
      builder: (context, config, database, _) {
        final systems = config.detectedRealSystems;
        final recent = database.getRecentlyPlayedGames(1);
        final gameCount = systems.fold<int>(
          0,
          (sum, system) => sum + system.romCount,
        );
        final ready =
            !config.isLoading && !config.isScanning && systems.isNotEmpty;

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _ink,
                Color.alphaBlend(
                  _accent.withValues(alpha: .13),
                  const Color(0xFF100C20),
                ),
                _ink,
              ],
            ),
          ),
          child: Column(
            children: [
              if (ready)
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 22, 28, 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 620;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: const LinearGradient(
                                    colors: [_violet, Color(0xFF5536A6)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _violet.withValues(alpha: .24),
                                      blurRadius: 22,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.blur_on_rounded,
                                  color: Colors.white,
                                  size: 27,
                                ),
                              ),
                              const SizedBox(width: 13),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ECLIPSE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 19,
                                        letterSpacing: 4.2,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'YOUR GAMING UNIVERSE',
                                      style: TextStyle(
                                        color: _lavender,
                                        fontSize: 9,
                                        letterSpacing: 2.1,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Search games',
                                onPressed: widget.onSearch,
                                icon: const Icon(Icons.search_rounded),
                                color: _lavender,
                                visualDensity: VisualDensity.compact,
                              ),
                              IconButton(
                                tooltip: 'Quick Menu',
                                onPressed: widget.onQuickMenu,
                                icon: const Icon(Icons.grid_view_rounded),
                                color: _lavender,
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: EclipseExperienceSwitcher(
                              onChanged: _handleExperienceChanged,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(compact ? 18 : 23),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: _accent.withValues(alpha: .32),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.alphaBlend(
                                    _accent.withValues(alpha: .20),
                                    const Color(0xFF292044),
                                  ),
                                  const Color(0xFF171326),
                                  const Color(0xFF100D1B),
                                ],
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_experience.name.toUpperCase()}  •  ${_experience.category.toUpperCase()}',
                                        style: TextStyle(
                                          color: _lavender,
                                          fontSize: 10,
                                          letterSpacing: 2.4,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        recent.isNotEmpty
                                            ? 'Ready when you are.'
                                            : 'Your next adventure starts here.',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: compact ? 19 : 25,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      if (recent.isNotEmpty) ...[
                                        const SizedBox(height: 5),
                                        Text(
                                          'CONTINUE PLAYING  •  ${recent.first.displayTitle}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFFC7B8EE),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ] else ...[
                                        const SizedBox(height: 5),
                                        const Text(
                                          'Choose a console below to jump into your library.',
                                          style: TextStyle(
                                            color: Color(0xFFB9B2CA),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (!compact) ...[
                                  const SizedBox(width: 18),
                                  Container(
                                    width: 1,
                                    height: 58,
                                    color: Colors.white.withValues(alpha: .12),
                                  ),
                                  const SizedBox(width: 20),
                                  _Stat(
                                    value: '${systems.length}',
                                    label: 'CONSOLES',
                                  ),
                                  const SizedBox(width: 24),
                                  _Stat(value: '$gameCount', label: 'GAMES'),
                                ],
                              ],
                            ),
                          ),
                          if (compact) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _CompactStat(
                                  value: '${systems.length}',
                                  label: 'CONSOLES',
                                ),
                                const SizedBox(width: 10),
                                _CompactStat(
                                  value: '$gameCount',
                                  label: 'GAMES',
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 18),
                          const Row(
                            children: [
                              Text(
                                'YOUR CONSOLES',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  letterSpacing: 2.1,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Spacer(),
                              Text(
                                'SELECT A SYSTEM TO ENTER',
                                style: TextStyle(
                                  color: Color(0xFF9289A7),
                                  fontSize: 9,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              Expanded(
                child: SystemContent(
                  selectedIndex: widget.selectedSystemIndex,
                  onCardTapped: widget.onSystemSelected,
                ),
              ),
              _EclipseDock(
                onDiscover: widget.onOpenDiscovery,
                onEntertainment: widget.onOpenEntertainment,
                onSettings: widget.onOpenSettings,
                onExperienceChanged: _handleExperienceChanged,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 23,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFFAAA0C5),
          fontSize: 8,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _CompactStat extends StatelessWidget {
  static const _panel = Color(0xFF171326);
  static const _violet = Color(0xFF9A72FF);
  const _CompactStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _violet.withValues(alpha: .15)),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFAAA0C5),
              fontSize: 9,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );
}

class _EclipseDock extends StatelessWidget {
  const _EclipseDock({
    required this.onDiscover,
    required this.onEntertainment,
    required this.onSettings,
    required this.onExperienceChanged,
  });

  final VoidCallback? onDiscover;
  final VoidCallback? onEntertainment;
  final VoidCallback? onSettings;
  final ValueChanged<EclipseExperience> onExperienceChanged;

  static const _violet = Color(0xFF9A72FF);
  void _openSystems(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF100C1D),
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CONSOLE EXPERIENCES',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            EclipseExperienceSwitcher(onChanged: onExperienceChanged),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 720),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xE8171424),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _violet.withValues(alpha: .28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .28),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const _DockItem(
                  icon: Icons.grid_view_rounded,
                  label: 'LIBRARY',
                  selected: true,
                  onPressed: null,
                ),
                _DockItem(
                  icon: Icons.explore_outlined,
                  label: 'DISCOVER',
                  onPressed: onDiscover,
                ),
                _DockItem(
                  icon: Icons.gamepad_rounded,
                  label: 'SYSTEMS',
                  onPressed: () => _openSystems(context),
                ),
                _DockItem(
                  icon: Icons.live_tv_rounded,
                  label: 'ENTERTAINMENT',
                  onPressed: onEntertainment,
                ),
                _DockItem(
                  icon: Icons.tune_rounded,
                  label: 'SETTINGS',
                  onPressed: onSettings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFD9CCFF) : const Color(0xFFAAA1C0);
    return Expanded(
      child: Semantics(
        button: onPressed != null,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 21,
                  color: selected ? const Color(0xFFB99AFF) : color,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      color: color,
                      fontSize: 8,
                      letterSpacing: .65,
                      fontWeight: FontWeight.w800,
                    ),
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

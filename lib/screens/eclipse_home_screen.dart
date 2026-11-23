import 'package:flutter/material.dart';
import 'package:neostation/providers/sqlite_config_provider.dart';
import 'package:neostation/providers/sqlite_database_provider.dart';
import 'package:provider/provider.dart';

import '../widgets/eclipse_experience_switcher.dart';

import 'systems_screen/system_content.dart';

/// ECLIPSE's rebuilt main landing experience.
///
/// This deliberately composes the existing systems flow instead of reimplementing
/// ROM discovery or system launch routing. The console-specific experience remains
/// the destination after a platform is selected.
class EclipseHomeScreen extends StatelessWidget {
  const EclipseHomeScreen({
    super.key,
    this.selectedSystemIndex = 0,
    this.onSystemSelected,
    this.onOpenDiscovery,
    this.onOpenSettings,
  });

  final int selectedSystemIndex;
  final ValueChanged<int>? onSystemSelected;
  final VoidCallback? onOpenDiscovery;
  final VoidCallback? onOpenSettings;

  static const _ink = Color(0xFF080711);
  static const _panel = Color(0xFF171326);
  static const _violet = Color(0xFF9A72FF);
  static const _lavender = Color(0xFFD9CCFF);

  @override
  Widget build(BuildContext context) {
    return Consumer2<SqliteConfigProvider, SqliteDatabaseProvider>(
      builder: (context, config, database, _) {
        final systems = config.detectedRealSystems;
        final recent = database.getRecentlyPlayedGames(1);
        final gameCount = systems.fold<int>(0, (sum, system) => sum + system.romCount);
        final ready = !config.isLoading && !config.isScanning && systems.isNotEmpty;

        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_ink, Color(0xFF100C20), _ink],
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
                                child: const Icon(Icons.blur_on_rounded, color: Colors.white, size: 27),
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
                              _HeaderAction(
                                icon: Icons.explore_outlined,
                                label: 'DISCOVER',
                                onPressed: onOpenDiscovery,
                              ),
                              const SizedBox(width: 8),
                              _HeaderAction(
                                icon: Icons.tune_rounded,
                                label: 'SYSTEM',
                                onPressed: onOpenSettings,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: EclipseExperienceSwitcher(),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(compact ? 18 : 23),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: _violet.withValues(alpha: .22)),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF292044), Color(0xFF171326), Color(0xFF100D1B)],
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'WELCOME BACK',
                                        style: TextStyle(
                                          color: _lavender,
                                          fontSize: 10,
                                          letterSpacing: 2.4,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        recent.isNotEmpty ? 'Ready when you are.' : 'Your next adventure starts here.',
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
                                          style: TextStyle(color: Color(0xFFB9B2CA), fontSize: 12),
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
                                  _Stat(value: '${systems.length}', label: 'CONSOLES'),
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
                                _CompactStat(value: '${systems.length}', label: 'CONSOLES'),
                                const SizedBox(width: 10),
                                _CompactStat(value: '$gameCount', label: 'GAMES'),
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
                  selectedIndex: selectedSystemIndex,
                  onCardTapped: onSystemSelected,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({required this.icon, required this.label, this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFD9CCFF),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        backgroundColor: Colors.white.withValues(alpha: .055),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 17),
      label: Text(label, style: const TextStyle(fontSize: 9, letterSpacing: 1.1, fontWeight: FontWeight.w800)),
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
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: Color(0xFFAAA0C5), fontSize: 8, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
    ],
  );
}

class _CompactStat extends StatelessWidget {
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
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Color(0xFFAAA0C5), fontSize: 9, letterSpacing: 1.1, fontWeight: FontWeight.w800)),
        ],
      ),
    ),
  );
}

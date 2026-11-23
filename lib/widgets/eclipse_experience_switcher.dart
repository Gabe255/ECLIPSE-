import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/eclipse_experience_catalog.dart';

/// Persistent picker for ECLIPSE dashboard experience profiles.
///
/// Choosing a profile stores the user's preference. Emulator availability is
/// deliberately kept separate from the presentation catalog.
class EclipseExperienceSwitcher extends StatefulWidget {
  const EclipseExperienceSwitcher({super.key, this.onChanged});

  final ValueChanged<EclipseExperience>? onChanged;

  @override
  State<EclipseExperienceSwitcher> createState() =>
      _EclipseExperienceSwitcherState();
}

class _EclipseExperienceSwitcherState extends State<EclipseExperienceSwitcher> {
  static const _preferenceKey = 'eclipse.selected_experience';
  static const _violet = Color(0xFF9A72FF);

  String _selectedId = 'ps5';
  bool _ready = false;

  EclipseExperience get _selected =>
      EclipseExperienceCatalog.byId(_selectedId) ??
      EclipseExperienceCatalog.experiences.first;

  @override
  void initState() {
    super.initState();
    _loadSelection();
  }

  Future<void> _loadSelection() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_preferenceKey);
    if (!mounted) return;
    setState(() {
      if (saved != null && EclipseExperienceCatalog.byId(saved) != null) {
        _selectedId = saved;
      }
      _ready = true;
    });
  }

  Future<void> _chooseExperience(EclipseExperience experience) async {
    setState(() => _selectedId = experience.id);
    widget.onChanged?.call(experience);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_preferenceKey, experience.id);
  }

  Future<void> _openPicker() async {
    var query = '';
    final selected = await showModalBottomSheet<EclipseExperience>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF100D1B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = EclipseExperienceCatalog.experiences
                .where((experience) {
                  final value = '${experience.name} ${experience.category}'
                      .toLowerCase();
                  return value.contains(query.toLowerCase());
                })
                .toList(growable: false);

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.82,
                child: Column(
                  children: [
                    const SizedBox(height: 14),
                    Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Choose a console experience',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        autofocus: false,
                        onChanged: (value) =>
                            setSheetState(() => query = value),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search systems and experiences',
                          hintStyle: const TextStyle(color: Colors.white38),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Colors.white54,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.06),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'No matching experiences',
                                style: TextStyle(color: Colors.white60),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 5),
                              itemBuilder: (context, index) {
                                final experience = filtered[index];
                                final isSelected = experience.id == _selectedId;
                                return ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  tileColor: isSelected
                                      ? _violet.withValues(alpha: 0.15)
                                      : Colors.white.withValues(alpha: 0.035),
                                  leading: CircleAvatar(
                                    backgroundColor: _violet.withValues(
                                      alpha: 0.18,
                                    ),
                                    child: const Icon(
                                      Icons.videogame_asset_rounded,
                                      color: Color(0xFFD9CCFF),
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    experience.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${experience.category} • ${experience.description}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFFC7B4FF),
                                        )
                                      : const Icon(
                                          Icons.chevron_right_rounded,
                                          color: Colors.white38,
                                        ),
                                  onTap: () =>
                                      Navigator.pop(context, experience),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      await _chooseExperience(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _ready ? _openPicker : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFD9CCFF),
        side: BorderSide(color: _violet.withValues(alpha: 0.35)),
        backgroundColor: Colors.white.withValues(alpha: 0.045),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.dashboard_customize_rounded, size: 17),
      label: Text(
        _ready
            ? '${_selected.name.toUpperCase()} EXPERIENCE'
            : 'LOADING EXPERIENCE',
        style: const TextStyle(
          fontSize: 9,
          letterSpacing: 1,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

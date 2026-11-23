import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../l10n/app_locale.dart';
import '../services/gamepad/gamepad_navigation_manager.dart';
import '../utils/gamepad_nav.dart';

enum EclipseQuickAction {
  resumeLibrary,
  entertainment,
  discovery,
  rescan,
  settings,
}

/// Controller-first shortcut panel available from the app-wide Menu button.
class EclipseQuickMenu extends StatefulWidget {
  const EclipseQuickMenu({
    super.key,
    required this.onAction,
    required this.onClose,
  });

  final ValueChanged<EclipseQuickAction> onAction;
  final VoidCallback onClose;

  @override
  State<EclipseQuickMenu> createState() => _EclipseQuickMenuState();
}

class _EclipseQuickMenuState extends State<EclipseQuickMenu> {
  static int _sequence = 0;
  late final String _layerId = 'eclipse_quick_menu#${++_sequence}';

  static const _items = <_QuickMenuItem>[
    _QuickMenuItem(
      EclipseQuickAction.resumeLibrary,
      AppLocale.quickMenuResumeLibrary,
      AppLocale.quickMenuResumeLibrarySubtitle,
      Icons.sports_esports_rounded,
    ),
    _QuickMenuItem(
      EclipseQuickAction.entertainment,
      AppLocale.entertainment,
      AppLocale.entertainmentYourApps,
      Icons.live_tv_rounded,
    ),
    _QuickMenuItem(
      EclipseQuickAction.discovery,
      AppLocale.discovery,
      AppLocale.searchCardSubtitle,
      Icons.explore_rounded,
    ),
    _QuickMenuItem(
      EclipseQuickAction.rescan,
      AppLocale.rescanAllFolders,
      AppLocale.rescanAllFoldersSubtitle,
      Icons.refresh_rounded,
    ),
    _QuickMenuItem(
      EclipseQuickAction.settings,
      AppLocale.settings,
      null,
      Icons.settings_rounded,
    ),
  ];

  int _selectedIndex = 0;
  bool _layerRegistered = false;

  late final GamepadNavigation _navigation = GamepadNavigation(
    onNavigateUp: () => _moveVertical(-1),
    onNavigateDown: () => _moveVertical(1),
    onNavigateLeft: () => _moveHorizontal(-1),
    onNavigateRight: () => _moveHorizontal(1),
    onSelectItem: _select,
    onBack: widget.onClose,
    accelerateRepeats: false,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _navigation.initialize();
      GamepadNavigationManager.pushLayer(
        _layerId,
        modal: true,
        onActivate: _navigation.activate,
        onDeactivate: _navigation.deactivate,
      );
      _layerRegistered = true;
    });
  }

  @override
  void dispose() {
    if (_layerRegistered) {
      GamepadNavigationManager.popLayer(_layerId);
    }
    _navigation.dispose();
    super.dispose();
  }

  void _moveHorizontal(int direction) {
    final rowStart = (_selectedIndex ~/ 2) * 2;
    final rowEnd = (rowStart + 1).clamp(0, _items.length - 1).toInt();
    final next = (_selectedIndex + direction).clamp(rowStart, rowEnd).toInt();
    if (next == _selectedIndex) return;
    setState(() => _selectedIndex = next);
  }

  void _moveVertical(int direction) {
    final column = _selectedIndex % 2;
    final row = _selectedIndex ~/ 2;
    final lastRow = (_items.length - 1) ~/ 2;
    final nextRow = (row + direction).clamp(0, lastRow).toInt();
    final next = (nextRow * 2 + column).clamp(0, _items.length - 1).toInt();
    if (next == _selectedIndex) return;
    setState(() => _selectedIndex = next);
  }

  void _select() => widget.onAction(_items[_selectedIndex].action);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: 720.r, maxHeight: 430.r),
          margin: EdgeInsets.all(18.r),
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: const Color(0xFF11101C),
            borderRadius: BorderRadius.circular(26.r),
            border: Border.all(
              color: const Color(0xFF8C70D8).withValues(alpha: 0.38),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7655D9).withValues(alpha: 0.2),
                blurRadius: 36.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7655D9).withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: Color(0xFFC7B4FF),
                    ),
                  ),
                  SizedBox(width: 12.r),
                  Expanded(
                    child: Text(
                      AppLocale.quickMenu.getString(context),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: AppLocale.back.getString(context),
                    onPressed: widget.onClose,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.r),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: _items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 78.r,
                    crossAxisSpacing: 10.r,
                    mainAxisSpacing: 10.r,
                  ),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final selected = index == _selectedIndex;
                    return InkWell(
                      borderRadius: BorderRadius.circular(16.r),
                      onTap: () {
                        setState(() => _selectedIndex = index);
                        _select();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.r,
                          vertical: 10.r,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF493276)
                              : Colors.white.withValues(alpha: 0.055),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFFBCA5FF)
                                : Colors.white.withValues(alpha: 0.08),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFFC7B4FF),
                              size: 24.r,
                            ),
                            SizedBox(width: 12.r),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.titleKey.getString(context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.r,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (item.subtitleKey != null)
                                    Text(
                                      item.subtitleKey!.getString(context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.58,
                                        ),
                                        fontSize: 9.r,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickMenuItem {
  const _QuickMenuItem(this.action, this.titleKey, this.subtitleKey, this.icon);

  final EclipseQuickAction action;
  final String titleKey;
  final String? subtitleKey;
  final IconData icon;
}

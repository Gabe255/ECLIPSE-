import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neostation/models/my_systems.dart';
import 'package:neostation/services/sfx_service.dart';
import 'package:neostation/services/gamepad/gamepad_navigation_manager.dart';
import 'package:neostation/utils/gamepad_nav.dart';

import 'eclipse_platform_card.dart';

/// ECLIPSE's two-row library: recently played games above the platform shelf.
class EclipsePlatformShelf extends StatefulWidget {
  const EclipsePlatformShelf({
    super.key,
    required this.systems,
    required this.selectedIndex,
    required this.onSelected,
    required this.onOpen,
    required this.onOptions,
    required this.onSearch,
    required this.onQuickMenu,
  });

  final List<SystemInfo> systems;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final ValueChanged<int> onOpen;
  final ValueChanged<int> onOptions;
  final VoidCallback onSearch;
  final VoidCallback onQuickMenu;

  @override
  State<EclipsePlatformShelf> createState() => _EclipsePlatformShelfState();
}

class _EclipsePlatformShelfState extends State<EclipsePlatformShelf> {
  static const _navLayerId = 'eclipse_platform_shelf';

  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _recentScrollController = ScrollController();
  final ScrollController _platformScrollController = ScrollController();
  final GlobalKey _recentRowKey = GlobalKey();
  final GlobalKey _platformRowKey = GlobalKey();

  late final GamepadNavigation _navigation;
  late int _selectedIndex;
  int _activeRow = 1;
  double _cardWidth = 220;
  bool _layerRegistered = false;

  List<int> _indicesForRow(int row) {
    final indices = <int>[];
    for (var index = 0; index < widget.systems.length; index++) {
      if (widget.systems[index].isGame == (row == 0)) {
        indices.add(index);
      }
    }
    return indices;
  }

  int _safeIndex(int index) {
    if (widget.systems.isEmpty) return 0;
    return index.clamp(0, widget.systems.length - 1);
  }

  int _rowForIndex(int index) {
    if (widget.systems.isEmpty) return 1;
    return widget.systems[_safeIndex(index)].isGame ? 0 : 1;
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = _safeIndex(widget.selectedIndex);
    _activeRow = _rowForIndex(_selectedIndex);
    _navigation = GamepadNavigation(
      onNavigateLeft: (_) => _moveSelection(-1),
      onNavigateRight: (_) => _moveSelection(1),
      onNavigateUp: (_) => _moveRow(-1),
      onNavigateDown: (_) => _moveRow(1),
      onSelectItem: _openSelected,
      onSettings: widget.onQuickMenu,
      onFavorite: _openOptions,
      onWestButton: widget.onSearch,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _navigation.initialize();
      final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
      GamepadNavigationManager.pushLayer(
        _navLayerId,
        onActivate: () => _navigation.activate(),
        onDeactivate: () => _navigation.deactivate(),
        background: !isCurrentRoute,
      );
      _layerRegistered = true;
      _scrollToSelection(animate: false);
    });
  }

  @override
  void didUpdateWidget(EclipsePlatformShelf oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.systems.length != widget.systems.length ||
        oldWidget.selectedIndex != widget.selectedIndex) {
      _selectedIndex = _safeIndex(widget.selectedIndex);
      _activeRow = _rowForIndex(_selectedIndex);
      _scrollToSelection(animate: false);
    }
  }

  void _moveSelection(int delta) {
    final indices = _indicesForRow(_activeRow);
    if (indices.isEmpty) return;

    final currentLocal = indices.indexOf(_selectedIndex);
    final safeLocal = currentLocal < 0 ? 0 : currentLocal;
    final nextLocal = (safeLocal + delta).clamp(0, indices.length - 1);
    if (nextLocal == safeLocal) return;

    SfxService().playNavSound();
    _select(indices[nextLocal]);
  }

  void _moveRow(int delta) {
    if (_indicesForRow(0).isEmpty) return;
    final targetRow = delta < 0 ? 0 : 1;
    if (targetRow == _activeRow) return;

    final currentIndices = _indicesForRow(_activeRow);
    final targetIndices = _indicesForRow(targetRow);
    if (targetIndices.isEmpty) return;

    final currentLocal = currentIndices.indexOf(_selectedIndex);
    final safeLocal = currentLocal < 0 ? 0 : currentLocal;
    final nextLocal = safeLocal.clamp(0, targetIndices.length - 1);

    SfxService().playNavSound();
    _select(targetIndices[nextLocal]);
  }

  void _select(int index) {
    final next = _safeIndex(index);
    if (next == _selectedIndex && _rowForIndex(next) == _activeRow) return;

    setState(() {
      _selectedIndex = next;
      _activeRow = _rowForIndex(next);
    });
    widget.onSelected(next);
    _scrollToSelection();
  }

  void _scrollToSelection({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final indices = _indicesForRow(_activeRow);
      final localIndex = indices.indexOf(_selectedIndex);
      final controller = _activeRow == 0
          ? _recentScrollController
          : _platformScrollController;

      if (localIndex >= 0 && controller.hasClients) {
        final rowCardWidth = _activeRow == 0 ? _cardWidth * 1.08 : _cardWidth;
        final target = (localIndex * (rowCardWidth + 10.r))
            .clamp(0.0, controller.position.maxScrollExtent)
            .toDouble();
        if (animate) {
          controller.animateTo(
            target,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        } else {
          controller.jumpTo(target);
        }
      }

      final rowContext =
          (_activeRow == 0 ? _recentRowKey : _platformRowKey).currentContext;
      if (rowContext != null && _verticalScrollController.hasClients) {
        Scrollable.ensureVisible(
          rowContext,
          alignment: _activeRow == 0 ? 0 : 1,
          duration: animate ? const Duration(milliseconds: 200) : Duration.zero,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _openSelected() {
    if (widget.systems.isEmpty) return;
    SfxService().playEnterSound();
    widget.onOpen(_selectedIndex);
  }

  void _openOptions() {
    if (widget.systems.isEmpty) return;
    widget.onOptions(_selectedIndex);
  }

  @override
  void dispose() {
    if (_layerRegistered) {
      GamepadNavigationManager.popLayer(_navLayerId);
    }
    _navigation.dispose();
    _verticalScrollController.dispose();
    _recentScrollController.dispose();
    _platformScrollController.dispose();
    super.dispose();
  }

  Widget _buildRow({
    required String title,
    required List<int> indices,
    required bool recent,
  }) {
    final rowKey = recent ? _recentRowKey : _platformRowKey;
    final controller = recent
        ? _recentScrollController
        : _platformScrollController;
    final rowCardWidth = recent ? _cardWidth * 1.08 : _cardWidth;

    return Padding(
      key: rowKey,
      padding: EdgeInsets.fromLTRB(12.r, 12.r, 12.r, 2.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.r),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: 0.78),
                    fontSize: 9.r,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.35.r,
                  ),
                ),
                const Spacer(),
                Text(
                  recent ? 'D-PAD / SWIPE' : '${indices.length} PLATFORMS',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: 0.38),
                    fontSize: 8.r,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.85.r,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 9.r),
          SizedBox(
            height: 148.r,
            child: ListView.separated(
              controller: controller,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 2.r, vertical: 3.r),
              physics: const BouncingScrollPhysics(),
              itemCount: indices.length,
              separatorBuilder: (context, index) => SizedBox(width: 10.r),
              itemBuilder: (context, localIndex) {
                final index = indices[localIndex];
                final system = widget.systems[index];
                return SizedBox(
                  width: rowCardWidth,
                  child: EclipsePlatformCard(
                    key: ValueKey(
                      'eclipse-${recent ? 'recent' : 'platform'}-${system.folderName}-$index',
                    ),
                    info: system,
                    selected: index == _selectedIndex,
                    onTap: () {
                      if (index == _selectedIndex) {
                        _openSelected();
                      } else {
                        _select(index);
                      }
                    },
                    onLongPress: () => widget.onOptions(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    _cardWidth = (width * 0.42).clamp(176.0, 252.0).toDouble();
    final recentIndices = _indicesForRow(0);
    final platformIndices = _indicesForRow(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView(
            controller: _verticalScrollController,
            physics: const BouncingScrollPhysics(),
            children: [
              if (recentIndices.isNotEmpty)
                _buildRow(
                  title: 'RECENTLY PLAYED',
                  indices: recentIndices,
                  recent: true,
                ),
              if (platformIndices.isNotEmpty)
                _buildRow(
                  title: 'YOUR PLATFORMS',
                  indices: platformIndices,
                  recent: false,
                ),
              SizedBox(height: 14.r),
            ],
          ),
        ),
      ],
    );
  }
}

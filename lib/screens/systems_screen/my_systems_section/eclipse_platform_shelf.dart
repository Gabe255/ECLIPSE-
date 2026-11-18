import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neostation/models/my_systems.dart';
import 'package:neostation/services/sfx_service.dart';
import 'package:neostation/services/gamepad/gamepad_navigation_manager.dart';
import 'package:neostation/utils/gamepad_nav.dart';

import 'eclipse_platform_card.dart';

/// ECLIPSE's horizontal platform shelf with touch and controller navigation.
class EclipsePlatformShelf extends StatefulWidget {
  const EclipsePlatformShelf({
    super.key,
    required this.systems,
    required this.selectedIndex,
    required this.onSelected,
    required this.onOpen,
    required this.onOptions,
    required this.onSearch,
  });

  final List<SystemInfo> systems;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final ValueChanged<int> onOpen;
  final ValueChanged<int> onOptions;
  final VoidCallback onSearch;

  @override
  State<EclipsePlatformShelf> createState() => _EclipsePlatformShelfState();
}

class _EclipsePlatformShelfState extends State<EclipsePlatformShelf> {
  static const _navLayerId = 'eclipse_platform_shelf';

  final ScrollController _scrollController = ScrollController();
  late final GamepadNavigation _navigation;
  late int _selectedIndex;
  double _cardWidth = 220;
  bool _layerRegistered = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _safeIndex(widget.selectedIndex);
    _navigation = GamepadNavigation(
      onNavigateLeft: (_) => _moveSelection(-1),
      onNavigateRight: (_) => _moveSelection(1),
      onSelectItem: _openSelected,
      onSettings: _openOptions,
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

  int _safeIndex(int index) {
    if (widget.systems.isEmpty) return 0;
    return index.clamp(0, widget.systems.length - 1);
  }

  @override
  void didUpdateWidget(EclipsePlatformShelf oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.systems.length != widget.systems.length ||
        oldWidget.selectedIndex != widget.selectedIndex) {
      _selectedIndex = _safeIndex(widget.selectedIndex);
      _scrollToSelection(animate: false);
    }
  }

  void _moveSelection(int delta) {
    if (widget.systems.isEmpty) return;
    final next = (_selectedIndex + delta).clamp(0, widget.systems.length - 1);
    if (next == _selectedIndex) return;
    SfxService().playNavSound();
    _select(next);
  }

  void _select(int index) {
    final next = _safeIndex(index);
    if (next == _selectedIndex) return;
    setState(() => _selectedIndex = next);
    widget.onSelected(next);
    _scrollToSelection();
  }

  void _scrollToSelection({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final target = (_selectedIndex * (_cardWidth + 10.r))
          .clamp(0.0, _scrollController.position.maxScrollExtent)
          .toDouble();
      if (animate) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(target);
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    _cardWidth = (width * 0.42).clamp(176.0, 252.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 4.r),
          child: Row(
            children: [
              Text(
                'YOUR PLATFORMS',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface
                      .withValues(alpha: 0.68),
                  fontSize: 9.r,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.35.r,
                ),
              ),
              const Spacer(),
              Text(
                'SWIPE TO EXPLORE',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface
                      .withValues(alpha: 0.38),
                  fontSize: 8.r,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9.r,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(12.r, 8.r, 12.r, 16.r),
            physics: const BouncingScrollPhysics(),
            itemCount: widget.systems.length,
            separatorBuilder: (context, index) => SizedBox(width: 10.r),
            itemBuilder: (context, index) {
              final system = widget.systems[index];
              return SizedBox(
                width: _cardWidth,
                child: EclipsePlatformCard(
                  key: ValueKey('eclipse-platform-${system.folderName}-$index'),
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
    );
  }
}

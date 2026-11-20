import 'package:flutter/material.dart';

import 'header.dart';

class FixedHeader extends StatelessWidget {
  final int selectedTabIndex;
  final Function(int) onTabSelected;
  final VoidCallback? onSearch;
  final VoidCallback? onQuickMenu;

  const FixedHeader({
    super.key,
    required this.selectedTabIndex,
    required this.onTabSelected,
    this.onSearch,
    this.onQuickMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Header(
      selectedTabIndex: selectedTabIndex,
      onTabSelected: onTabSelected,
      onSearch: onSearch,
      onQuickMenu: onQuickMenu,
    );
  }
}

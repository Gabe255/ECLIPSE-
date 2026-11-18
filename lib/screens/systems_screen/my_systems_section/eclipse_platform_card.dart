import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neostation/models/my_systems.dart';

/// ECLIPSE's own landscape platform tile.
///
/// This is intentionally independent of the inherited SystemCard: it uses
/// the platform's existing artwork and metadata, but owns the layout,
/// typography, focus treatment, and touch interaction.
class EclipsePlatformCard extends StatelessWidget {
  const EclipsePlatformCard({
    super.key,
    required this.info,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final SystemInfo info;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  Color get _accent => info.color ?? const Color(0xFF9B7BFF);

  @override
  Widget build(BuildContext context) {
    final customBackground = info.customBackgroundPath;
    final hasCustomBackground =
        customBackground != null &&
        customBackground.isNotEmpty &&
        File(customBackground).existsSync();
    final customLogo = info.customLogoPath;
    final hasCustomLogo =
        customLogo != null &&
        customLogo.isNotEmpty &&
        File(customLogo).existsSync();
    final customWheel = info.customWheelImage;
    final hasCustomWheel =
        info.isGame &&
        customWheel != null &&
        customWheel.isNotEmpty &&
        File(customWheel).existsSync();
    final logoFolder = info.primaryFolderName?.isNotEmpty == true
        ? info.primaryFolderName!
        : (info.folderName?.isNotEmpty == true ? info.folderName! : 'all');
    final logoAssetPath = 'assets/images/logos/$logoFolder.webp';
    final title = info.title ?? info.shortName ?? 'Platform';
    final count = info.numOfRoms ?? 0;

    return AnimatedScale(
      scale: selected ? 1 : 0.965,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected
                ? _accent.withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.10),
            width: selected ? 2.r : 1.r,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: _accent.withValues(alpha: 0.22),
                blurRadius: 22.r,
                spreadRadius: 1.r,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19.r),
          child: Material(
            color: const Color(0xFF100C19),
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              splashColor: _accent.withValues(alpha: 0.18),
              highlightColor: Colors.white.withValues(alpha: 0.035),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasCustomBackground)
                    Image.file(
                      File(customBackground!),
                      fit: BoxFit.cover,
                      cacheWidth: 720,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    )
                  else
                    Image.asset(
                      info.carouselImagePath,
                      fit: BoxFit.cover,
                      cacheWidth: 720,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.18),
                          _accent.withValues(alpha: 0.16),
                          const Color(0xFF090611).withValues(alpha: 0.96),
                        ],
                        stops: const [0, 0.42, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12.r,
                    left: 13.r,
                    child: Text(
                      'ECLIPSE  /  PLATFORM',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.70),
                        fontSize: 8.r,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.25.r,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 9.r,
                    right: 10.r,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.r,
                        vertical: 5.r,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.46),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Text(
                        '$count GAMES',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.r,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6.r,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 13.r,
                    top: 36.r,
                    bottom: 48.r,
                    child: SizedBox(
                      width: 78.r,
                      child: Opacity(
                        opacity: 0.92,
                        child: hasCustomWheel
                            ? Image.file(
                                File(customWheel!),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildFallbackMark(),
                              )
                            : hasCustomLogo
                            ? Image.file(
                                File(customLogo!),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildFallbackMark(),
                              )
                            : Image.asset(
                                logoAssetPath,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildFallbackMark(),
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14.r,
                    right: 92.r,
                    bottom: 13.r,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          (info.shortName ?? info.folderName ?? 'SYSTEM')
                              .toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _accent.withValues(alpha: 0.98),
                            fontSize: 8.r,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5.r,
                          ),
                        ),
                        SizedBox(height: 4.r),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.r,
                            height: 1.02,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.35.r,
                          ),
                        ),
                        SizedBox(height: 7.r),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'OPEN LIBRARY',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.76),
                                fontSize: 8.r,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0.r,
                              ),
                            ),
                            SizedBox(width: 5.r),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 12.r,
                              color: _accent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 3.r,
                        color: _accent,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackMark() {
    return Icon(
      Icons.sports_esports_rounded,
      color: Colors.white.withValues(alpha: 0.78),
      size: 38.r,
    );
  }
}

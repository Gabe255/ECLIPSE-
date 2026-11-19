import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_locale.dart';
import '../services/android_service.dart';
import '../services/gamepad/gamepad_navigation_manager.dart';
import '../utils/gamepad_nav.dart';

/// A couch-first streaming and media hub. Android launches installed packages;
/// missing apps open their Play Store listing, while desktop builds open the
/// service website.
class EntertainmentScreen extends StatefulWidget {
  const EntertainmentScreen({
    super.key,
    required this.onBack,
    this.onQuickMenu,
  });

  final VoidCallback onBack;
  final VoidCallback? onQuickMenu;

  @override
  State<EntertainmentScreen> createState() => _EntertainmentScreenState();
}

class _EntertainmentScreenState extends State<EntertainmentScreen> {
  static const _favoritesKey = 'eclipse_entertainment_favorites_v1';
  static const _recentKey = 'eclipse_entertainment_recent_v1';
  static const _navLayerId = 'entertainment_screen';

  static const List<_EntertainmentApp> _catalog = [
    _EntertainmentApp(
      'YouTube',
      'com.google.android.youtube',
      'video',
      'https://www.youtube.com',
    ),
    _EntertainmentApp(
      'YouTube TV',
      'com.google.android.youtube.tvunplugged',
      'live',
      'https://tv.youtube.com',
    ),
    _EntertainmentApp(
      'Netflix',
      'com.netflix.mediaclient',
      'video',
      'https://www.netflix.com',
    ),
    _EntertainmentApp(
      'Prime Video',
      'com.amazon.avod.thirdpartyclient',
      'video',
      'https://www.primevideo.com',
    ),
    _EntertainmentApp(
      'Disney+',
      'com.disney.disneyplus',
      'video',
      'https://www.disneyplus.com',
    ),
    _EntertainmentApp('Hulu', 'com.hulu.plus', 'video', 'https://www.hulu.com'),
    _EntertainmentApp('Tubi', 'com.tubitv', 'video', 'https://tubitv.com'),
    _EntertainmentApp('Max', 'com.hbo.hbonow', 'video', 'https://www.max.com'),
    _EntertainmentApp(
      'Peacock',
      'com.peacocktv.peacockandroid',
      'video',
      'https://www.peacocktv.com',
    ),
    _EntertainmentApp(
      'Paramount+',
      'com.cbs.app',
      'video',
      'https://www.paramountplus.com',
    ),
    _EntertainmentApp(
      'Apple TV',
      'com.apple.atve.androidtv.appletv',
      'video',
      'https://tv.apple.com',
    ),
    _EntertainmentApp(
      'Crunchyroll',
      'com.crunchyroll.crunchyroid',
      'video',
      'https://www.crunchyroll.com',
    ),
    _EntertainmentApp(
      'Plex',
      'com.plexapp.android',
      'video',
      'https://www.plex.tv',
    ),
    _EntertainmentApp(
      'Pluto TV',
      'tv.pluto.android',
      'live',
      'https://pluto.tv',
    ),
    _EntertainmentApp(
      'Twitch',
      'tv.twitch.android.app',
      'live',
      'https://www.twitch.tv',
    ),
    _EntertainmentApp(
      'ESPN',
      'com.espn.score_center',
      'live',
      'https://www.espn.com',
    ),
    _EntertainmentApp(
      'Spotify',
      'com.spotify.music',
      'music',
      'https://open.spotify.com',
    ),
    _EntertainmentApp(
      'YouTube Music',
      'com.google.android.apps.youtube.music',
      'music',
      'https://music.youtube.com',
    ),
    _EntertainmentApp(
      'SoundCloud',
      'com.soundcloud.android',
      'music',
      'https://soundcloud.com',
    ),
    _EntertainmentApp(
      'Amazon Music',
      'com.amazon.mp3',
      'music',
      'https://music.amazon.com',
    ),
    _EntertainmentApp(
      'Apple Music',
      'com.apple.android.music',
      'music',
      'https://music.apple.com',
    ),
    _EntertainmentApp(
      'Deezer',
      'deezer.android.app',
      'music',
      'https://www.deezer.com',
    ),
    _EntertainmentApp(
      'Pandora',
      'com.pandora.android',
      'music',
      'https://www.pandora.com',
    ),
    _EntertainmentApp('Fubo', 'tv.fubo.mobile', 'live', 'https://www.fubo.tv'),
    _EntertainmentApp('Sling TV', 'com.sling', 'live', 'https://www.sling.com'),
    _EntertainmentApp('DAZN', 'com.dazn', 'live', 'https://www.dazn.com'),
    _EntertainmentApp(
      'Viki',
      'com.viki.android',
      'video',
      'https://www.viki.com',
    ),
    _EntertainmentApp('MUBI', 'com.mubi', 'video', 'https://mubi.com'),
    _EntertainmentApp(
      'Audible',
      'com.audible.application',
      'music',
      'https://www.audible.com',
    ),
    _EntertainmentApp(
      'VLC',
      'org.videolan.vlc',
      'video',
      'https://www.videolan.org/vlc',
    ),
    _EntertainmentApp('Kodi', 'org.xbmc.kodi', 'video', 'https://kodi.tv'),
    _EntertainmentApp(
      'TIDAL',
      'com.aspiro.tidal',
      'music',
      'https://tidal.com',
    ),
  ];

  late final GamepadNavigation _gamepadNav = GamepadNavigation(
    onNavigateUp: () => _moveRow(-1),
    onNavigateDown: () => _moveRow(1),
    onNavigateLeft: () => _moveItem(-1),
    onNavigateRight: () => _moveItem(1),
    onSelectItem: _launchSelected,
    onFavorite: _toggleSelectedFavorite,
    onSettings: widget.onQuickMenu,
    onBack: widget.onBack,
    accelerateRepeats: false,
  );

  final TextEditingController _searchController = TextEditingController();
  final Map<int, ScrollController> _rowControllers = {};
  final Set<String> _favorites = {};
  final List<String> _recentPackages = [];
  List<_EntertainmentApp> _discoveredApps = [];
  String _activeCategory = 'all';
  final Map<String, Future<Uint8List?>> _iconRequests = {};
  Set<String> _installedPackages = {};
  bool _loading = true;
  int _selectedRow = 0;
  int _selectedItem = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadHub();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _gamepadNav.initialize();
      _gamepadNav.activate();
      GamepadNavigationManager.pushLayer(
        _navLayerId,
        onActivate: _gamepadNav.activate,
        onDeactivate: _gamepadNav.deactivate,
      );
    });
  }

  @override
  void dispose() {
    GamepadNavigationManager.popLayer(_navLayerId);
    _gamepadNav.dispose();
    _searchController.dispose();
    for (final controller in _rowControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadHub() async {
    final prefs = await SharedPreferences.getInstance();
    final installed = Platform.isAndroid
        ? await AndroidService.getInstalledApps(includeSystemApps: false)
        : <Map<String, dynamic>>[];
    if (!mounted) return;
    final knownPackages = _catalog.map((app) => app.packageName).toSet();
    final discovered = <_EntertainmentApp>[];
    for (final entry in installed) {
      final name = entry['name']?.toString().trim() ?? '';
      final packageName = entry['package']?.toString().trim() ?? '';
      if (name.isEmpty ||
          packageName.isEmpty ||
          knownPackages.contains(packageName)) {
        continue;
      }
      final category = _detectCategory(name, packageName);
      if (category != null) {
        discovered.add(_EntertainmentApp(name, packageName, category, ''));
      }
    }
    setState(() {
      _favorites
        ..clear()
        ..addAll(prefs.getStringList(_favoritesKey) ?? const []);
      _recentPackages
        ..clear()
        ..addAll(prefs.getStringList(_recentKey) ?? const []);
      _installedPackages = installed
          .map((app) => app['package']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toSet();
      _discoveredApps = discovered;
      _loading = false;
    });
  }

  List<_EntertainmentApp> get _apps => [
    ..._catalog,
    ..._discoveredApps.where(
      (app) => !_catalog.any((known) => known.packageName == app.packageName),
    ),
  ];

  static String? _detectCategory(String name, String packageName) {
    final value = '$name $packageName'.toLowerCase();
    if (RegExp(
      r'spotify|soundcloud|tidal|deezer|pandora|music|podcast|audible|radio',
    ).hasMatch(value)) {
      return 'music';
    }
    if (RegExp(r'twitch|espn|fubo|sling|pluto|sports|live tv|livestream')
        .hasMatch(value)) {
      return 'live';
    }
    if (RegExp(
      r'youtube|netflix|prime video|amazon video|disney|hulu|tubi|max|peacock|paramount|crunchyroll|plex|mubi|viki|roku|freevee|movie|stream|video|tv',
    ).hasMatch(value)) {
      return 'video';
    }
    return null;
  }

  List<_EntertainmentRow> get _rows {
    final query = _query.trim().toLowerCase();
    List<_EntertainmentApp> filter(List<_EntertainmentApp> apps) => apps
        .where((app) {
          final matchesQuery =
              query.isEmpty ||
              app.name.toLowerCase().contains(query) ||
              app.packageName.toLowerCase().contains(query);
          final matchesCategory = switch (_activeCategory) {
            'video' => app.category == 'video',
            'live' => app.category == 'live',
            'music' => app.category == 'music',
            'favorites' => _favorites.contains(app.packageName),
            'recent' => _recentPackages.contains(app.packageName),
            'installed' => _installedPackages.contains(app.packageName),
            _ => true,
          };
          return matchesQuery && matchesCategory;
        })
        .toList(growable: false);

    final all = filter(_apps);
    if (all.isEmpty) return const <_EntertainmentRow>[];
    if (_activeCategory != 'all') {
      final titleKey = switch (_activeCategory) {
        'video' => AppLocale.entertainmentMoviesTv,
        'live' => AppLocale.entertainmentLiveSports,
        'music' => AppLocale.entertainmentMusicCreators,
        'favorites' => AppLocale.favorite,
        'recent' => AppLocale.entertainmentRecentlyOpened,
        'installed' => AppLocale.entertainmentInstalled,
        _ => AppLocale.entertainmentYourApps,
      };
      return [_EntertainmentRow(titleKey, all)];
    }
    if (all.isEmpty) return const <_EntertainmentRow>[];
    final rows = <_EntertainmentRow>[
      _EntertainmentRow(AppLocale.entertainmentYourApps, all),
    ];
    final favoriteApps = filter(
      _apps.where((app) => _favorites.contains(app.packageName)).toList(),
    );
    if (favoriteApps.isNotEmpty) {
      rows.add(_EntertainmentRow(AppLocale.favorite, favoriteApps));
    }
    final recentApps = filter(
      _recentPackages
          .map(
            (packageName) => _apps
                .where((app) => app.packageName == packageName)
                .firstOrNull,
          )
          .whereType<_EntertainmentApp>()
          .toList(),
    );
    if (recentApps.isNotEmpty) {
      rows.add(
        _EntertainmentRow(AppLocale.entertainmentRecentlyOpened, recentApps),
      );
    }
    final video = filter(
      _apps.where((app) => app.category == 'video').toList(),
    );
    final live = filter(_apps.where((app) => app.category == 'live').toList());
    final music = filter(
      _apps.where((app) => app.category == 'music').toList(),
    );
    if (video.isNotEmpty) {
      rows.add(_EntertainmentRow(AppLocale.entertainmentMoviesTv, video));
    }
    if (live.isNotEmpty) {
      rows.add(_EntertainmentRow(AppLocale.entertainmentLiveSports, live));
    }
    if (music.isNotEmpty) {
      rows.add(_EntertainmentRow(AppLocale.entertainmentMusicCreators, music));
    }
    return rows;
  }

  ScrollController _controllerFor(int row) =>
      _rowControllers.putIfAbsent(row, ScrollController.new);

  void _moveRow(int direction) {
    final rows = _rows;
    if (rows.isEmpty) return;
    setState(() {
      _selectedRow = (_selectedRow + direction)
          .clamp(0, rows.length - 1)
          .toInt();
      _selectedItem = _selectedItem
          .clamp(0, rows[_selectedRow].apps.length - 1)
          .toInt();
    });
    _revealSelection();
  }

  void _moveItem(int direction) {
    final rows = _rows;
    if (rows.isEmpty) return;
    final count = rows[_selectedRow].apps.length;
    if (count == 0) return;
    setState(() {
      _selectedItem = (_selectedItem + direction).clamp(0, count - 1).toInt();
    });
    _revealSelection();
  }

  void _revealSelection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = _controllerFor(_selectedRow);
      if (!controller.hasClients) return;
      final target = (_selectedItem * 196.r)
          .clamp(0.0, controller.position.maxScrollExtent)
          .toDouble();
      controller.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _toggleFavorite(_EntertainmentApp app) async {
    setState(() {
      if (!_favorites.add(app.packageName)) {
        _favorites.remove(app.packageName);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, _favorites.toList());
  }

  Future<void> _toggleSelectedFavorite() async {
    final rows = _rows;
    if (rows.isEmpty || rows[_selectedRow].apps.isEmpty) return;
    await _toggleFavorite(rows[_selectedRow].apps[_selectedItem]);
  }

  Future<void> _launchSelected() async {
    final rows = _rows;
    if (rows.isEmpty || rows[_selectedRow].apps.isEmpty) return;
    await _launchApp(rows[_selectedRow].apps[_selectedItem]);
  }

  Future<void> _launchApp(_EntertainmentApp app) async {
    if (Platform.isAndroid && _installedPackages.contains(app.packageName)) {
      final launched = await AndroidService.launchPackage(app.packageName);
      if (launched) {
        await _recordRecent(app.packageName);
        return;
      }
    }

    final uri = Platform.isAndroid
        ? Uri.parse(
            'https://play.google.com/store/apps/details?id=${app.packageName}',
          )
        : Uri.parse(app.website);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!Platform.isAndroid) await _recordRecent(app.packageName);
  }

  Future<void> _refreshApps() async {
    if (!Platform.isAndroid) return;
    setState(() => _loading = true);
    await _loadHub();
  }

  void _selectCategory(String category) {
    setState(() {
      _activeCategory = category;
      _selectedRow = 0;
      _selectedItem = 0;
    });
    _revealSelection();
  }

  Widget _categoryChip(String category, String labelKey, ThemeData theme) {
    final selected = _activeCategory == category;
    return Padding(
      padding: EdgeInsets.only(right: 8.r),
      child: ChoiceChip(
        label: Text(labelKey.getString(context)),
        selected: selected,
        onSelected: (_) => _selectCategory(category),
        showCheckmark: false,
        labelStyle: TextStyle(
          fontSize: 11.r,
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : theme.colorScheme.onSurface,
        ),
        selectedColor: const Color(0xFF7450D5),
        backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.42,
        ),
        side: BorderSide(
          color: selected
              ? const Color(0xFFB8A0FF)
              : Colors.white.withValues(alpha: 0.08),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 3.r),
      ),
    );
  }

  Future<void> _recordRecent(String packageName) async {
    _recentPackages.remove(packageName);
    _recentPackages.insert(0, packageName);
    if (_recentPackages.length > 12) {
      _recentPackages.removeRange(12, _recentPackages.length);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, _recentPackages);
    if (mounted) setState(() {});
  }

  Future<Uint8List?> _loadIcon(String packageName) {
    return _iconRequests.putIfAbsent(
      packageName,
      () => AndroidService.getAppIcon(packageName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = _rows;
    if (_selectedRow >= rows.length) {
      _selectedRow = rows.isEmpty ? 0 : rows.length - 1;
      _selectedItem = 0;
    }
    return SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 54.r),
                Padding(
                  padding: EdgeInsets.fromLTRB(34.r, 10.r, 34.r, 14.r),
                  child: Row(
                    children: [
                      Text(
                        'ECLIPSE',
                        style: TextStyle(
                          fontSize: 15.r,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.2,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 18.r),
                      Text(
                        AppLocale.entertainment.getString(context),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      if (Platform.isAndroid)
                        IconButton(
                          tooltip: AppLocale.refresh.getString(context),
                          onPressed: _refreshApps,
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      SizedBox(
                        width: 250.r,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() {
                            _query = value;
                            _selectedRow = 0;
                            _selectedItem = 0;
                          }),
                          decoration: InputDecoration(
                            hintText: AppLocale.entertainmentSearchHint
                                .getString(context),
                            prefixIcon: const Icon(Icons.search),
                            isDense: true,
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.52),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24.r),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 34.r),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _categoryChip(
                          'all',
                          AppLocale.entertainmentYourApps,
                          theme,
                        ),
                        _categoryChip(
                          'video',
                          AppLocale.entertainmentMoviesTv,
                          theme,
                        ),
                        _categoryChip(
                          'live',
                          AppLocale.entertainmentLiveSports,
                          theme,
                        ),
                        _categoryChip(
                          'music',
                          AppLocale.entertainmentMusicCreators,
                          theme,
                        ),
                        _categoryChip('favorites', AppLocale.favorite, theme),
                        _categoryChip(
                          'recent',
                          AppLocale.entertainmentRecentlyOpened,
                          theme,
                        ),
                        if (Platform.isAndroid)
                          _categoryChip(
                            'installed',
                            AppLocale.entertainmentInstalled,
                            theme,
                          ),
                      ],
                    ),
                  ),
                ),
                if (rows.isNotEmpty) ...[
                  SizedBox(height: 12.r),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 34.r),
                    child: _buildSpotlight(theme),
                  ),
                  SizedBox(height: 18.r),
                ],
                Expanded(
                  child: rows.isEmpty
                      ? Center(
                          child: Text(
                            AppLocale.entertainmentEmpty.getString(context),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(bottom: 30.r),
                          itemCount: rows.length,
                          itemBuilder: (context, index) =>
                              _buildAppRow(theme, rows[index], index),
                        ),
                ),
              ],
            ),
    );
  }

  Future<void> _openYouTubeExplore(String query) async {
    final uri = Uri.parse(
      'https://www.youtube.com/results?search_query=${Uri.encodeQueryComponent(query)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildSpotlight(ThemeData theme) {
    final youtubeInstalled =
        _installedPackages.contains('com.google.android.youtube');
    final exploreTopics = <(String, String, IconData)>[
      (AppLocale.games.getString(context), 'gaming', Icons.sports_esports_rounded),
      (AppLocale.systems.getString(context), 'retro gaming', Icons.videogame_asset_rounded),
      (AppLocale.discovery.getString(context), 'gaming handhelds', Icons.gamepad_rounded),
      (AppLocale.entertainment.getString(context), 'gameplay walkthroughs', Icons.play_circle_outline_rounded),
    ];
    return Container(
      height: 206.r,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF33236D),
            Color(0xFF17152E),
            Color(0xFF080A12),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF9C7BFF).withValues(alpha: 0.32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF865BFF).withValues(alpha: 0.16),
            blurRadius: 26.r,
            spreadRadius: 1.r,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 24.r,
            top: 12.r,
            child: Icon(
              Icons.play_circle_filled_rounded,
              size: 142.r,
              color: Colors.white.withValues(alpha: 0.075),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(26.r, 18.r, 26.r, 16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.smart_display_rounded,
                      color: Color(0xFFFF4545),
                      size: 19,
                    ),
                    SizedBox(width: 8.r),
                    Text(
                      AppLocale.discovery.getString(context).toUpperCase(),
                      style: TextStyle(
                        color: const Color(0xFFD5C9FF),
                        fontSize: 10.r,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.r,
                      ),
                    ),
                    const Spacer(),
                    if (youtubeInstalled)
                      Text(
                        AppLocale.entertainmentInstalled.getString(context).toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.56),
                          fontSize: 8.r,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.r,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 9.r),
                Text(
                  AppLocale.entertainmentFeatured.getString(context),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.r,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5.r,
                  ),
                ),
                SizedBox(height: 5.r),
                Text(
                  AppLocale.entertainmentMoviesTv.getString(context),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 10.r,
                  ),
                ),
                SizedBox(height: 13.r),
                Wrap(
                  spacing: 7.r,
                  runSpacing: 6.r,
                  children: [
                    for (final topic in exploreTopics)
                      ActionChip(
                        avatar: Icon(
                          topic.$3,
                          size: 14.r,
                          color: Colors.white,
                        ),
                        label: Text(
                          topic.$1,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.r,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                        onPressed: () => _openYouTubeExplore(topic.$2),
                      ),
                  ],
                ),
                SizedBox(height: 8.r),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () async {
                      final youtube = _apps.firstWhere(
                        (app) => app.packageName == 'com.google.android.youtube',
                      );
                      await _launchApp(youtube);
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 14),
                    label: Text(AppLocale.launch.getString(context)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 8.r),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppRow(ThemeData theme, _EntertainmentRow row, int rowIndex) {
    final selectedIndex = rowIndex == _selectedRow ? _selectedItem : -1;
    final controller = _controllerFor(rowIndex);
    return Padding(
      padding: EdgeInsets.only(top: 15.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 36.r),
            child: Text(
              row.titleKey.getString(context),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
          SizedBox(height: 9.r),
          SizedBox(
            height: 132.r,
            child: ListView.separated(
              controller: controller,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 34.r, vertical: 4.r),
              itemCount: row.apps.length,
              separatorBuilder: (context, index) => SizedBox(width: 10.r),
              itemBuilder: (context, index) {
                final app = row.apps[index];
                final selected = selectedIndex == index;
                final installed = _installedPackages.contains(app.packageName);
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedRow = rowIndex;
                      _selectedItem = index;
                    });
                    _launchApp(app);
                  },
                  onLongPress: () => _toggleFavorite(app),
                  borderRadius: BorderRadius.circular(15.r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: selected ? 204.r : 194.r,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: selected
                            ? const [Color(0xFF51358D), Color(0xFF211A3A)]
                            : [
                                theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.62),
                                theme.colorScheme.surface.withValues(
                                  alpha: 0.38,
                                ),
                              ],
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.24,
                                ),
                                blurRadius: 18.r,
                                spreadRadius: 1.r,
                              ),
                            ]
                          : const [],
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.055,
                              ),
                        width: selected ? 2.r : 1.r,
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildAppIcon(app, installed),
                        SizedBox(width: 10.r),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.r,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 5.r),
                              Text(
                                installed
                                    ? AppLocale.entertainmentInstalled
                                          .getString(context)
                                    : Platform.isAndroid
                                    ? AppLocale.entertainmentNotInstalled
                                          .getString(context)
                                    : AppLocale.launch.getString(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9.r,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.55,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _toggleFavorite(app),
                          icon: Icon(
                            _favorites.contains(app.packageName)
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 17.r,
                            color: _favorites.contains(app.packageName)
                                ? const Color(0xFFFFD36B)
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.42,
                                  ),
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
    );
  }

  Widget _buildAppIcon(_EntertainmentApp app, bool installed, {double? size}) {
    final iconSize = size ?? 42.r;
    if (Platform.isAndroid && installed) {
      return FutureBuilder<Uint8List?>(
        future: _loadIcon(app.packageName),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(iconSize * 0.2),
              child: Image.memory(
                snapshot.data!,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            );
          }
          return _fallbackIcon(app, size: iconSize);
        },
      );
    }
    return _fallbackIcon(app, size: iconSize);
  }

  Widget _fallbackIcon(_EntertainmentApp app, {required double size}) {
    final icon = switch (app.category) {
      'music' => Icons.music_note_rounded,
      'live' => Icons.live_tv_rounded,
      _ => Icons.movie_rounded,
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF7655D9).withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Icon(icon, size: size * 0.52, color: const Color(0xFFC7B4FF)),
    );
  }
}

class _EntertainmentRow {
  const _EntertainmentRow(this.titleKey, this.apps);

  final String titleKey;
  final List<_EntertainmentApp> apps;
}

class _EntertainmentApp {
  const _EntertainmentApp(
    this.name,
    this.packageName,
    this.category,
    this.website,
  );

  final String name;
  final String packageName;
  final String category;
  final String website;
}

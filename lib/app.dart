import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import 'data/home_widget_service.dart';
import 'data/open_meteo_service.dart';
import 'data/prefs_service.dart';
import 'data/weather_data.dart';
import 'logic/weather_logic.dart';
import 'screens/day_sheet.dart';
import 'screens/home_screen.dart';
import 'screens/locations_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/style_guide_screen.dart';
import 'theme/colors.dart';
import 'theme/text_styles.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/mascot_widget.dart';
import 'widgets/pixel_panel.dart';
import 'widgets/sky_background.dart';
import 'widgets/status_chrome.dart';

/// Root app state — mirrors the design's `Component` class: one screen enum,
/// one time-of-day, one weather condition, driven by a live clock. Weather
/// numbers themselves come from Open-Meteo, fetched once per saved city.
class PixelWeatherApp extends StatefulWidget {
  const PixelWeatherApp({super.key});

  @override
  State<PixelWeatherApp> createState() => _PixelWeatherAppState();
}

class _PixelWeatherAppState extends State<PixelWeatherApp> {
  String _screen = 'splash';
  late String _tod;
  String _cond = 'clear';
  String _unit = 'C';
  bool _notif = true;
  String _theme = 'Tự động';
  String _char = 'fu';
  String _city = 'Đà Lạt';
  late DateTime _now;

  final Map<String, WeatherSnapshot> _weather = {};
  final Set<String> _failedCities = {};

  /// The current city when it isn't one of the fixed [appCities] — i.e. it
  /// came from the search box's geocoding results, or was restored from a
  /// previous session's search pick. Needed because such a city's
  /// coordinates aren't known anywhere else.
  CityInfo? _customCity;

  bool _splashMinTimeElapsed = false;
  bool _prefsRestored = false;
  String _postSplashScreen = 'home';

  Timer? _splashTimer;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _tod = autoTimeOfDay(_now.hour);
    _splashTimer = Timer(const Duration(milliseconds: 2100), () {
      _splashMinTimeElapsed = true;
      _maybeFinishSplash();
    });
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    for (final c in appCities) {
      _loadCity(c);
    }
    _restoreSavedPrefs();
  }

  /// Re-applies whatever the user picked last session (unit/theme/mascot),
  /// and the saved city if there is one. On a genuinely first launch (no
  /// city ever saved), sends the user to the location picker instead of
  /// silently defaulting to Đà Lạt.
  Future<void> _restoreSavedPrefs() async {
    final prefs = await loadPrefs();
    if (!mounted) return;
    if (prefs.unit != null) setState(() => _unit = prefs.unit!);
    if (prefs.char != null) setState(() => _char = prefs.char!);
    if (prefs.notif != null) setState(() => _notif = prefs.notif!);
    if (prefs.theme != null && prefs.theme != _theme) _pickTheme(prefs.theme!);

    final saved = prefs.city;
    if (saved == null) {
      _postSplashScreen = 'loc';
    } else {
      setState(() => _city = saved.name);
      if (!appCities.any((c) => c.name == saved.name)) {
        setState(() => _customCity = saved);
        _loadCity(saved);
      }
      _postSplashScreen = 'home';
    }
    _prefsRestored = true;
    _maybeFinishSplash();
  }

  void _maybeFinishSplash() {
    if (_splashMinTimeElapsed && _prefsRestored && mounted) {
      setState(() => _screen = _postSplashScreen);
    }
  }

  /// Resolves a city name back to its coordinates — either a fixed entry in
  /// [appCities] or the dynamically-picked [_customCity].
  CityInfo? _resolveCity(String name) {
    if (_customCity != null && _customCity!.name == name) return _customCity;
    for (final c in appCities) {
      if (c.name == name) return c;
    }
    return null;
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCity(CityInfo c) async {
    _failedCities.remove(c.name);
    try {
      final snap = await fetchWeather(c.lat, c.lon);
      if (!mounted) return;
      setState(() {
        _weather[c.name] = snap;
        if (c.name == _city) _cond = snap.cond;
      });
      if (c.name == _city) _pushWidgetUpdate();
    } catch (_) {
      if (!mounted) return;
      setState(() => _failedCities.add(c.name));
    }
  }

  /// Re-renders the Android home-screen widget's snapshot with whatever the
  /// currently selected city/settings show right now. No-ops until that
  /// city's weather has actually loaded once.
  void _pushWidgetUpdate() {
    final snap = _weather[_city];
    if (snap == null) return;
    unawaited(updateWeatherWidget(weather: snap, city: _city, cond: _cond, tod: _tod, unit: _unit, char: _char));
  }

  void _goto(String screen) => setState(() => _screen = screen);

  void _pickTheme(String label) {
    setState(() {
      _theme = label;
      _tod = todForTheme(label, _now.hour);
    });
    unawaited(saveTheme(label));
    _pushWidgetUpdate();
  }

  void _setUnit(String u) {
    setState(() => _unit = u);
    unawaited(saveUnit(u));
    _pushWidgetUpdate();
  }

  void _toggleNotif() {
    setState(() => _notif = !_notif);
    unawaited(saveNotif(_notif));
  }

  void _pickChar(String c) {
    setState(() => _char = c);
    unawaited(saveChar(c));
    _pushWidgetUpdate();
  }

  void _pickCity(CityInfo city) {
    final isBuiltIn = appCities.any((c) => c.name == city.name);
    setState(() {
      _city = city.name;
      if (!isBuiltIn) _customCity = city;
      _cond = _weather[city.name]?.cond ?? _cond;
      _screen = 'home';
    });
    if (!isBuiltIn) _loadCity(city);
    unawaited(saveCity(city));
    _pushWidgetUpdate();
  }

  Color get _chromeColor =>
      (_screen == 'loc' || _screen == 'set' || _screen == 'guide') ? PixelColors.ink : PixelColors.cream;

  @override
  Widget build(BuildContext context) {
    final clock = '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: PixelColors.appBg,
      body: SkyBackground(
        timeOfDay: _tod,
        condition: _cond,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(child: _buildScreen()),
              Positioned(top: 0, left: 0, right: 0, child: StatusChrome(clock: clock, color: _chromeColor)),
              if (_screen != 'splash')
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: PixelBottomNav(current: _screen, onSelect: _goto),
                ),
              if (kDebugMode)
                Positioned(top: 4, right: 4, child: _DebugMenuButton(onTap: () => _openDebugMenu(context))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreen() {
    switch (_screen) {
      case 'home':
        final weather = _weather[_city];
        if (weather == null) {
          return _LoadingOrError(
            char: _char,
            failed: _failedCities.contains(_city),
            onRetry: () {
              final c = _resolveCity(_city);
              if (c != null) _loadCity(c);
            },
          );
        }
        return HomeScreen(
          city: _city,
          tod: _tod,
          cond: _cond,
          unit: _unit,
          char: _char,
          now: _now,
          weather: weather,
          onOpenLocations: () => _goto('loc'),
          onOpenDay: (day) => showDaySheet(context, day, _unit),
        );
      case 'loc':
        return LocationsScreen(
          currentCity: _city,
          unit: _unit,
          char: _char,
          weather: _weather,
          failedCities: _failedCities,
          onPick: _pickCity,
          onRetry: (city) {
            final c = _resolveCity(city);
            if (c != null) _loadCity(c);
          },
          customCity: _customCity,
        );
      case 'set':
        return SettingsScreen(
          unit: _unit,
          notif: _notif,
          theme: _theme,
          char: _char,
          onSetUnit: _setUnit,
          onToggleNotif: _toggleNotif,
          onPickTheme: _pickTheme,
          onPickChar: _pickChar,
          onOpenGuide: () => _goto('guide'),
        );
      case 'guide':
        return StyleGuideScreen(char: _char, onGoHome: () => _goto('home'));
      default:
        return SplashScreen(char: _char);
    }
  }

  void _openDebugMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Debug — demo controls (không có trong app thật)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 12),
              _debugRow('Thời gian', timePaletteOrder, _tod, (v) {
                setState(() => _tod = v);
                setSheetState(() {});
              }),
              _debugRow('Thời tiết', weatherModOrder, _cond, (v) {
                setState(() => _cond = v);
                setSheetState(() {});
              }),
              _debugRow('Màn hình', const ['splash', 'home', 'loc', 'set', 'guide'], _screen, (v) {
                setState(() => _screen = v);
                setSheetState(() {});
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _debugRow(String label, List<String> options, String current, ValueChanged<String> onPick) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: [
          SizedBox(width: 72, child: Text(label, style: const TextStyle(fontSize: 11))),
          for (final o in options)
            ChoiceChip(label: Text(o), selected: current == o, onSelected: (_) => onPick(o)),
        ],
      ),
    );
  }
}

/// Shown on the Home screen while a city's Open-Meteo data is loading, or if
/// the request failed (no internet, API down, etc).
class _LoadingOrError extends StatelessWidget {
  final String char;
  final bool failed;
  final VoidCallback onRetry;
  const _LoadingOrError({required this.char, required this.failed, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MascotWidget(char: char, state: failed ? 'sad' : 'clear', size: 72),
          const SizedBox(height: 14),
          Text(
            failed ? 'Không lấy được dữ liệu thời tiết' : 'Đang tải dữ liệu thời tiết…',
            style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 13, color: PixelColors.cream),
          ),
          if (failed) ...[
            const SizedBox(height: 12),
            PixelButton(
              onTap: onRetry,
              child: Text('Thử lại', style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }
}

class _DebugMenuButton extends StatelessWidget {
  final VoidCallback onTap;
  const _DebugMenuButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PixelPanel(
        background: Colors.black.withValues(alpha: .35),
        borderWidth: 0,
        shadowDrop: 0,
        padding: const EdgeInsets.all(6),
        child: const Icon(Icons.bug_report, size: 16, color: Colors.white),
      ),
    );
  }
}

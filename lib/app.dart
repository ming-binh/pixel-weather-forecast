import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import 'data/open_meteo_service.dart';
import 'data/weather_data.dart';
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
  String _char = 'cat';
  String _city = 'Đà Lạt';
  late DateTime _now;

  final Map<String, WeatherSnapshot> _weather = {};
  final Set<String> _failedCities = {};

  Timer? _splashTimer;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _tod = _autoTimeOfDay(_now.hour);
    _splashTimer = Timer(const Duration(milliseconds: 2100), () {
      if (mounted) setState(() => _screen = 'home');
    });
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    for (final c in appCities) {
      _loadCity(c);
    }
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
    } catch (_) {
      if (!mounted) return;
      setState(() => _failedCities.add(c.name));
    }
  }

  static String _autoTimeOfDay(int hour) {
    if (hour < 5) return 'night';
    if (hour < 7) return 'dawn';
    if (hour < 17) return 'day';
    if (hour < 19) return 'dusk';
    return 'night';
  }

  void _goto(String screen) => setState(() => _screen = screen);

  void _pickTheme(String label) {
    setState(() {
      _theme = label;
      switch (label) {
        case 'Bình minh':
          _tod = 'dawn';
        case 'Ban ngày':
          _tod = 'day';
        case 'Hoàng hôn':
          _tod = 'dusk';
        case 'Ban đêm':
          _tod = 'night';
        default:
          _tod = _autoTimeOfDay(_now.hour);
      }
    });
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
            onRetry: () => _loadCity(appCities.firstWhere((c) => c.name == _city)),
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
          onPick: (city) => setState(() {
            _city = city;
            _cond = _weather[city]?.cond ?? _cond;
            _screen = 'home';
          }),
          onRetry: (city) => _loadCity(appCities.firstWhere((c) => c.name == city)),
        );
      case 'set':
        return SettingsScreen(
          unit: _unit,
          notif: _notif,
          theme: _theme,
          char: _char,
          onSetUnit: (u) => setState(() => _unit = u),
          onToggleNotif: () => setState(() => _notif = !_notif),
          onPickTheme: _pickTheme,
          onPickChar: (c) => setState(() => _char = c),
          onOpenGuide: () => _goto('guide'),
        );
      case 'guide':
        return const StyleGuideScreen();
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

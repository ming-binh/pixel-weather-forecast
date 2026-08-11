import 'package:flutter/material.dart';

import '../data/open_meteo_service.dart';
import '../data/weather_data.dart';
import '../logic/weather_logic.dart';
import '../pixel/sprites.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/bobbing.dart';
import '../widgets/mascot_widget.dart';
import '../widgets/pixel_panel.dart';
import '../widgets/pixel_sprite.dart';

/// Day picked from the 7-day forecast, opened in the day-detail bottom sheet.
class DayDetail {
  final int index;
  final String day;
  final int hi;
  final int lo;
  final String kind;
  final List<List<String>> stats;
  const DayDetail({
    required this.index,
    required this.day,
    required this.hi,
    required this.lo,
    required this.kind,
    required this.stats,
  });
}

/// Main screen — mirrors the design's `isHome` panel. Fed by a live
/// [WeatherSnapshot] fetched from Open-Meteo (see `open_meteo_service.dart`).
class HomeScreen extends StatelessWidget {
  final String city;
  final String tod;
  final String cond;
  final String unit;
  final String char;
  final DateTime now;
  final WeatherSnapshot weather;
  final VoidCallback onOpenLocations;
  final ValueChanged<DayDetail> onOpenDay;

  const HomeScreen({
    super.key,
    required this.city,
    required this.tod,
    required this.cond,
    required this.unit,
    required this.char,
    required this.now,
    required this.weather,
    required this.onOpenLocations,
    required this.onOpenDay,
  });

  @override
  Widget build(BuildContext context) {
    final icon = effIcon(cond, tod);
    final mascotKind = mascotStateFor(cond, tod);
    final night = tod == 'night';
    final condLabel = '${weatherMods[cond]!.label}${night ? ' · ban đêm' : ''}';
    final advice = night ? mascotAdvice['night']! : mascotAdvice[cond]!;
    final jsDow = now.weekday % 7;
    final dateLine = '${weekdayNames[jsDow]}, ${now.day}/${now.month}';
    final clock = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final today = weather.daily.first;
    final mascotInfo = mascotChars[char]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 56, 18, 104),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimatedPixelSprite(miniIconSheet('pin'), size: 14),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            city,
                            style: PixelText.pixelify(
                              fontSize: 19,
                              color: PixelColors.cream,
                              shadows: const [Shadow(color: Color(0x992B2B44), offset: Offset(0, 2))],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(dateLine, style: PixelText.beVietnam(fontSize: 11.5, color: PixelColors.cream.withValues(alpha: .8))),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              PixelPanel(
                background: PixelColors.cream,
                borderWidth: 0,
                shadowDrop: 6,
                shadowColor: const Color(0x732B2B44),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: GestureDetector(
                  onTap: onOpenLocations,
                  child: Text('Đổi nơi',
                      style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 11, color: PixelColors.ink)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${convertTemp(weather.temp.round(), unit)}',
                            style: PixelText.pixelify(
                              fontSize: 86,
                              color: PixelColors.cream,
                              shadows: const [Shadow(color: Color(0x8C2B2B44), offset: Offset(0, 5))],
                            )),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('°$unit', style: PixelText.pixelify(fontSize: 30, color: PixelColors.cream)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(condLabel,
                        style: PixelText.beVietnam(fontSize: 13, fontWeight: FontWeight.w600, color: PixelColors.cream)),
                    const SizedBox(height: 6),
                    Text(
                      'Cảm giác như ${convertTemp(weather.feelsLike.round(), unit)}°$unit · '
                      'Cao ${convertTemp(today.hi.round(), unit)}° Thấp ${convertTemp(today.lo.round(), unit)}°',
                      style: PixelText.beVietnam(fontSize: 11.5, color: PixelColors.cream.withValues(alpha: .8)),
                    ),
                  ],
                ),
              ),
              Bobbing.bob(
                duration: const Duration(milliseconds: 1100),
                child: AnimatedPixelSprite(weatherIconSheet(icon), size: 112),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Bobbing.bob2(
                duration: const Duration(milliseconds: 1200),
                child: MascotWidget(char: char, state: mascotKind, size: 88),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PixelPanel(
                    borderWidth: 4,
                    shadowDrop: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mascotInfo.tag,
                            style: PixelText.pixelify(
                                fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: PixelColors.errorRed)),
                        const SizedBox(height: 3),
                        Text(advice, style: PixelText.beVietnam(fontSize: 12.5, height: 1.45, color: PixelColors.ink)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: Column(
              children: [
                Bobbing.bob(
                  duration: const Duration(milliseconds: 1400),
                  child: Icon(Icons.keyboard_arrow_up, size: 18, color: PixelColors.cream.withValues(alpha: .7)),
                ),
                Text('vuốt lên xem thêm',
                    style: PixelText.beVietnam(fontSize: 10.5, color: PixelColors.cream.withValues(alpha: .7))),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _HourlyForecast(hourly: weather.hourly, unit: unit),
          const SizedBox(height: 12),
          _DailyForecast(daily: weather.daily, cond: cond, tod: tod, weather: weather, onOpenDay: onOpenDay),
          const SizedBox(height: 12),
          _StatsGrid(unit: unit, weather: weather),
          const SizedBox(height: 6),
          Center(
            child: Text('Open-Meteo · cập nhật $clock',
                style: PixelText.beVietnam(fontSize: 10, color: PixelColors.cream.withValues(alpha: .55))),
          ),
        ],
      ),
    );
  }
}

class _HourlyForecast extends StatelessWidget {
  final List<HourlyForecast> hourly;
  final String unit;

  const _HourlyForecast({required this.hourly, required this.unit});

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      background: PixelColors.cream.withValues(alpha: .93),
      borderWidth: 0,
      shadowDrop: 8,
      shadowColor: const Color(0x4D2B2B44),
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('THEO GIỜ — 12H TỚI',
                    style: PixelText.pixelify(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
                Text('cuộn ngang →', style: PixelText.beVietnam(fontSize: 10.5, color: PixelColors.mutedGray)),
              ],
            ),
          ),
          const SizedBox(height: 9),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 12, right: 12),
              itemCount: hourly.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final h = hourly[i];
                final isNight = h.time.hour >= 19 || h.time.hour < 5;
                final iconKind = effIcon(h.cond, isNight ? 'night' : 'day');
                final temp = convertTemp(h.temp.round(), unit);
                return Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  color: i == 0 ? PixelColors.creamPanelActive : Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${h.time.hour.toString().padLeft(2, '0')}:00',
                          style: PixelText.pixelify(fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      AnimatedPixelSprite(weatherIconSheet(iconKind), size: 32),
                      const SizedBox(height: 4),
                      Text('$temp°', style: PixelText.pixelify(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.water_drop, size: 8, color: const Color(0xFF5B9BD5)),
                          const SizedBox(width: 2),
                          Text('${h.pop}%', style: PixelText.beVietnam(fontSize: 9.5, color: const Color(0xFF4E7EA8))),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyForecast extends StatelessWidget {
  final List<DailyForecast> daily;
  final String cond;
  final String tod;
  final WeatherSnapshot weather;
  final ValueChanged<DayDetail> onOpenDay;

  const _DailyForecast({required this.daily, required this.cond, required this.tod, required this.weather, required this.onOpenDay});

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      background: PixelColors.cream.withValues(alpha: .93),
      borderWidth: 0,
      shadowDrop: 8,
      shadowColor: const Color(0x4D2B2B44),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('7 NGÀY TỚI', style: PixelText.pixelify(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
          const SizedBox(height: 8),
          for (var i = 0; i < daily.length; i++) ...[
            if (i > 0) const SizedBox(height: 5),
            _DailyRow(
              label: i == 0 ? 'Hôm nay' : weekdayNames[daily[i].date.weekday % 7],
              iconKind: i == 0 ? effIcon(cond, tod) : effIcon(daily[i].cond, 'day'),
              hi: daily[i].hi.round(),
              lo: daily[i].lo.round(),
              highlighted: i == 0,
              onTap: () => onOpenDay(DayDetail(
                index: i,
                day: i == 0 ? 'Hôm nay' : weekdayNames[daily[i].date.weekday % 7],
                hi: daily[i].hi.round(),
                lo: daily[i].lo.round(),
                kind: i == 0 ? effIcon(cond, tod) : effIcon(daily[i].cond, 'day'),
                stats: i == 0
                    ? [
                        ['Độ ẩm', '${weather.humidity}%'],
                        ['UV', weather.uvIndex.toStringAsFixed(1)],
                        ['Gió', '${weather.windSpeed.round()} km/h'],
                        ['Mưa', '${daily[0].pop}%'],
                      ]
                    : [
                        ['Độ ẩm', '${daily[i].humidity}%'],
                        ['UV', daily[i].uv.toStringAsFixed(1)],
                        ['Gió', '${daily[i].windSpeed.round()} km/h'],
                        ['Mưa', '${daily[i].pop}%'],
                      ],
              )),
            ),
          ],
        ],
      ),
    );
  }
}

class _DailyRow extends StatelessWidget {
  final String label;
  final String iconKind;
  final int hi;
  final int lo;
  final bool highlighted;
  final VoidCallback onTap;

  const _DailyRow({
    required this.label,
    required this.iconKind,
    required this.hi,
    required this.lo,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final barLeft = ((lo - 20) / 16).clamp(0.0, 1.0);
    final barWidth = ((hi - lo) / 16).clamp(0.0, 1.0 - barLeft);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: highlighted ? PixelColors.creamPanelActive : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Row(
          children: [
            SizedBox(width: 52, child: Text(label, style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 12))),
            SizedBox(width: 30, child: AnimatedPixelSprite(weatherIconSheet(iconKind), size: 26)),
            const SizedBox(width: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 8,
                    color: const Color(0xFFE4D5B7),
                    child: Stack(
                      children: [
                        Positioned(
                          left: constraints.maxWidth * barLeft,
                          width: constraints.maxWidth * barWidth,
                          top: 0,
                          bottom: 0,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Color(0xFF5BC0BE), Color(0xFFF2A03D)]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 74,
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: '$lo° ', style: PixelText.pixelify(fontSize: 14)),
                  TextSpan(text: '/ ', style: PixelText.pixelify(fontSize: 14, color: PixelColors.mutedGray)),
                  TextSpan(text: '$hi°', style: PixelText.pixelify(fontSize: 14)),
                ]),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatEntry {
  final String label;
  final String value;
  final double pct;
  final Color color;
  final String note;
  final String iconKind;
  const _StatEntry(this.label, this.value, this.pct, this.color, this.note, this.iconKind);
}

class _StatsGrid extends StatelessWidget {
  final String unit;
  final WeatherSnapshot weather;
  const _StatsGrid({required this.unit, required this.weather});

  @override
  Widget build(BuildContext context) {
    final feelsDiff = (weather.feelsLike - weather.temp).round();
    final feelsNote = feelsDiff == 0
        ? 'Đúng như nhiệt độ thực tế'
        : feelsDiff > 0
            ? 'Nóng hơn thực tế $feelsDiff°'
            : 'Mát hơn thực tế ${-feelsDiff}°';
    final stats = [
      _StatEntry('Độ ẩm', '${weather.humidity}%', weather.humidity / 100, const Color(0xFF5B9BD5), humidityNote(weather.humidity), 'humid'),
      _StatEntry('Chỉ số UV', weather.uvIndex.toStringAsFixed(0), (weather.uvIndex / 11).clamp(0.0, 1.0), const Color(0xFFF2A03D),
          uvNote(weather.uvIndex), 'uv'),
      _StatEntry('Gió', weather.windSpeed.round().toString(), (weather.windSpeed / 40).clamp(0.0, 1.0), const Color(0xFF5BC0BE),
          'km/h · hướng ${windCompass(weather.windDir)}', 'wind'),
      _StatEntry('Cảm giác như', '${convertTemp(weather.feelsLike.round(), unit)}°', .80, const Color(0xFFC24A34), feelsNote, 'feels'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        for (final s in stats)
          PixelPanel(
            background: PixelColors.cream.withValues(alpha: .93),
            borderWidth: 0,
            shadowDrop: 8,
            shadowColor: const Color(0x4D2B2B44),
            padding: const EdgeInsets.all(11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AnimatedPixelSprite(miniIconSheet(s.iconKind), size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        s.label.toUpperCase(),
                        style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 10.5, color: PixelColors.mutedGray),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(s.value, style: PixelText.pixelify(fontSize: 26)),
                Container(
                  height: 6,
                  color: const Color(0xFFE4D5B7),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: s.pct,
                    child: Container(color: s.color),
                  ),
                ),
                Text(s.note, style: PixelText.beVietnam(fontSize: 10.5, color: PixelColors.mutedGray)),
              ],
            ),
          ),
      ],
    );
  }
}

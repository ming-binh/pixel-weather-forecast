import 'package:flutter/material.dart';

import '../data/open_meteo_service.dart';
import '../data/weather_data.dart';
import '../logic/weather_logic.dart';
import '../pixel/sprites.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/pixel_sprite.dart';

/// Saved-places picker — mirrors the design's `isLoc` panel. Each row's
/// temperature comes from the live [weather] map (keyed by city name),
/// fetched once for all [appCities] on app start.
class LocationsScreen extends StatefulWidget {
  final String currentCity;
  final String unit;
  final Map<String, WeatherSnapshot> weather;
  final Set<String> failedCities;
  final ValueChanged<String> onPick;
  final ValueChanged<String> onRetry;

  const LocationsScreen({
    super.key,
    required this.currentCity,
    required this.unit,
    required this.weather,
    required this.failedCities,
    required this.onPick,
    required this.onRetry,
  });

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final filtered = appCities.where((c) => q.isEmpty || c.name.toLowerCase().contains(q)).toList();

    return Container(
      color: PixelColors.creamPanelBg,
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 100),
      child: ListView(
        children: [
          Text('CHỌN ĐỊA ĐIỂM',
              style: PixelText.pixelify(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: PixelColors.cream, border: Border.all(color: PixelColors.ink, width: 3)),
            child: Row(
              children: [
                PixelSprite(miniIcon('search'), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Tìm thành phố…',
                      hintStyle: PixelText.beVietnam(fontSize: 13, color: PixelColors.mutedGray),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: PixelText.beVietnam(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text('ĐÃ LƯU',
              style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 10.5, letterSpacing: .6, color: PixelColors.mutedGray)),
          const SizedBox(height: 9),
          for (final c in filtered) ...[
            _PlaceRow(
              city: c,
              unit: widget.unit,
              active: c.name == widget.currentCity,
              snapshot: widget.weather[c.name],
              failed: widget.failedCities.contains(c.name),
              onTap: () => widget.onPick(c.name),
              onRetry: () => widget.onRetry(c.name),
            ),
            const SizedBox(height: 9),
          ],
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: Column(
                children: [
                  PixelSprite(mascot('sad'), size: 64),
                  const SizedBox(height: 8),
                  Text('Không tìm thấy nơi nào tên vậy',
                      style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 12.5)),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'Mèo đã lục hết bản đồ rồi. Thử gõ tên khác xem sao.',
                      textAlign: TextAlign.center,
                      style: PixelText.beVietnam(fontSize: 11, color: PixelColors.mutedGray),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PlaceRow extends StatelessWidget {
  final CityInfo city;
  final String unit;
  final bool active;
  final WeatherSnapshot? snapshot;
  final bool failed;
  final VoidCallback onTap;
  final VoidCallback onRetry;

  const _PlaceRow({
    required this.city,
    required this.unit,
    required this.active,
    required this.snapshot,
    required this.failed,
    required this.onTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: snapshot != null ? onTap : (failed ? onRetry : null),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: active ? PixelColors.creamPanelActive : PixelColors.cream,
          border: Border.all(color: PixelColors.ink, width: 3),
          boxShadow: const [BoxShadow(color: Color(0x472B2B44), offset: Offset(0, 6))],
        ),
        child: Row(
          children: [
            PixelSprite(weatherIcon(snapshot != null ? effIcon(snapshot!.cond, 'day') : 'clear'), size: 34),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(city.name, style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(city.sub, style: PixelText.beVietnam(fontSize: 10.5, color: PixelColors.mutedGray)),
                ],
              ),
            ),
            if (snapshot != null)
              Text('${convertTemp(snapshot!.temp.round(), unit)}°', style: PixelText.pixelify(fontSize: 24))
            else if (failed)
              Text('Lỗi · thử lại', style: PixelText.beVietnam(fontSize: 11, color: PixelColors.errorRed))
            else
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
      ),
    );
  }
}

import 'dart:math' as math;
import 'dart:ui' show Color;

import 'pixel_grid.dart';

/// Color ramps and sprite generators ported from the Pixel Weather design's
/// procedural pixel-art engine (support.js `icon`/`mini`/`mascot`/hill code).
/// Every sprite is drawn pixel-by-pixel instead of loaded from an asset.

final List<Color> sunRamp = hexColors(['#C9761B', '#E89A2B', '#F7C244', '#FFDE7A', '#FFF3B8']);
final List<Color> cloudRamp = hexColors(['#8E9DB4', '#AEBCCD', '#CBD7E4', '#E8EFF6', '#FFFFFF']);
final List<Color> darkCloudRamp = hexColors(['#4C5468', '#5F6A80', '#767F95', '#8D95AA', '#A3AABD']);
final List<Color> moonRamp = hexColors(['#B7B3D6', '#CFCBE8', '#E4E1F5', '#F3F1FF', '#FFFFFF']);
final List<Color> furRamp = hexColors(['#B9C6DA', '#D3DEEC', '#E6EEF8', '#F6FAFF', '#FFFFFF']);
final List<Color> snowFurRamp = hexColors(['#A9BBD2', '#C3D2E5', '#DAE6F3', '#EDF4FC', '#FFFFFF']);
final Color ink = hexColor('#2B2B44');

void _bolt(PixelGrid g, num x, num y, Color c1, Color c2) {
  const pts = [
    [3, 0], [2, 1], [2, 2], [1, 3], [3, 3], [2, 4], [2, 5], [1, 6], [4, 2], [3, 4],
  ];
  for (final p in pts) {
    put(g, x + p[0], y + p[1], c1);
  }
  const pts2 = [
    [3, 1], [3, 2], [2, 3], [2, 6],
  ];
  for (final p in pts2) {
    put(g, x + p[0], y + p[1], c2);
  }
}

void _cloudShape(PixelGrid g, List<Color> ramp, num dy, Color rim) {
  disc(g, 5.5, 10 + dy, 3.6, ramp, rim: rim);
  disc(g, 10.5, 9 + dy, 4.6, ramp, rim: rim);
  disc(g, 13, 11 + dy, 3.2, ramp, rim: rim);
  rectFill(g, 3, 10 + dy, 11, 3, ramp[2]);
  for (var x = 3; x < 14; x++) {
    put(g, x, 10 + dy, ramp[1]);
    put(g, x, 11 + dy, ramp[2]);
    put(g, x, 12 + dy, ramp[0]);
  }
}

void _sunShape(PixelGrid g, num cx, num cy, num r, bool rays) {
  disc(g, cx, cy, r, sunRamp, rim: hexColor('#FFF6D0'));
  if (rays) {
    const arms = [
      [0, -1], [0, 1], [-1, 0], [1, 0],
    ];
    for (final d in arms) {
      put(g, cx + d[0] * (r + 1.2) - 0.5, cy + d[1] * (r + 1.2) - 0.5, hexColor('#FFDE7A'));
      put(g, cx + d[0] * (r + 2.2) - 0.5, cy + d[1] * (r + 2.2) - 0.5, hexColor('#E89A2B'));
    }
    const diag = [
      [-0.72, -0.72], [0.72, -0.72], [-0.72, 0.72], [0.72, 0.72],
    ];
    for (final d in diag) {
      put(g, cx + d[0] * (r + 1.5) - 0.5, cy + d[1] * (r + 1.5) - 0.5, hexColor('#FFDE7A'));
    }
  }
}

/// 16x16 weather condition icon. `kind` is one of: clear, night, partly,
/// cloudy, rain, storm, snow, fog.
PixelGrid weatherIcon(String kind) {
  final g = PixelGrid(16, 16);
  switch (kind) {
    case 'clear':
      _sunShape(g, 8, 8, 4.6, true);
    case 'night':
      disc(g, 8.5, 8, 5, moonRamp, rim: hexColor('#FFFFFF'));
      // Overlapping dark disc carves the moon into a crescent.
      disc(g, 11.5, 6, 4.2, const [Color(0xFF000000)]);
      put(g, 6, 9, hexColor('#B7B3D6'));
      put(g, 7, 11, hexColor('#B7B3D6'));
      put(g, 5, 7, hexColor('#CFCBE8'));
    case 'partly':
      _sunShape(g, 11, 5.5, 3.4, true);
      _cloudShape(g, cloudRamp, 1, hexColor('#FFFFFF'));
    case 'cloudy':
      _cloudShape(g, cloudRamp, -1, hexColor('#FFFFFF'));
      disc(g, 9, 12, 3.4, darkCloudRamp);
      rectFill(g, 4, 13, 10, 2, darkCloudRamp[2]);
    case 'rain':
      _cloudShape(g, darkCloudRamp, -2, hexColor('#C6D3E4'));
      for (final p in const [[4, 12], [7, 13], [10, 12], [13, 13]]) {
        put(g, p[0], p[1], hexColor('#7FB6E0'));
        put(g, p[0], p[1] + 1, hexColor('#5B9BD5'));
        put(g, p[0], p[1] + 2, hexColor('#4E7EA8'));
      }
    case 'storm':
      _cloudShape(
        g,
        hexColors(['#3B4257', '#4A5268', '#5A6480', '#6B7590', '#7E88A3']),
        -2,
        hexColor('#9FB4D6'),
      );
      _bolt(g, 5, 10, hexColor('#FFD75E'), hexColor('#FFF3B8'));
      put(g, 12, 12, hexColor('#5B9BD5'));
      put(g, 12, 13, hexColor('#4E7EA8'));
    case 'snow':
      _cloudShape(g, cloudRamp, -2, hexColor('#FFFFFF'));
      for (final p in const [[4, 12], [8, 13], [12, 12]]) {
        put(g, p[0], p[1], hexColor('#FFFFFF'));
        put(g, p[0] - 1, p[1] + 1, hexColor('#DCE8F2'));
        put(g, p[0] + 1, p[1] + 1, hexColor('#DCE8F2'));
        put(g, p[0], p[1] + 2, hexColor('#FFFFFF'));
      }
    case 'fog':
      _cloudShape(
        g,
        hexColors(['#B4BCC6', '#C6CDD6', '#D8DEE5', '#E9EDF2', '#F7F9FB']),
        -2,
        hexColor('#FFFFFF'),
      );
      rectFill(g, 2, 13, 10, 1, hexColor('#D8DEE5'));
      rectFill(g, 4, 15, 10, 1, hexColor('#D8DEE5'));
  }
  outline(g, ink);
  return g;
}

/// 12x12 small stat/nav icon. `kind` is one of: humid, uv, wind, feels, pin,
/// search, home, gear, palette.
PixelGrid miniIcon(String kind) {
  final g = PixelGrid(12, 12);
  switch (kind) {
    case 'humid':
      disc(g, 6, 7.5, 3.4, hexColors(['#2F6EA8', '#3E86C4', '#5B9BD5', '#7FB6E0', '#B7DAF3']),
          rim: hexColor('#DFF1FF'));
      for (final p in const [[6, 2], [5, 3], [6, 3], [7, 3], [5, 4], [6, 4], [7, 4]]) {
        put(g, p[0], p[1], hexColor('#5B9BD5'));
      }
    case 'uv':
      _sunShape(g, 6, 6, 3.2, true);
    case 'wind':
      final cols = hexColors(['#CBD7E4', '#E8EFF6']);
      for (var i = 0; i < cols.length; i++) {
        final c = cols[i];
        rectFill(g, 1, 3 + i * 4, 7, 1, c);
        put(g, 8, 3 + i * 4, c);
        put(g, 8, 2 + i * 4, c);
        put(g, 7, 2 + i * 4, c);
      }
      rectFill(g, 2, 7, 6, 1, hexColor('#AEBCCD'));
    case 'feels':
      rectFill(g, 5, 1, 2, 7, hexColor('#E8EFF6'));
      disc(g, 6, 9, 2.4, hexColors(['#A33A2A', '#C24A34', '#E0604A', '#F07E62', '#FFA88E']));
      rectFill(g, 5, 4, 2, 5, hexColor('#E0604A'));
    case 'pin':
      disc(g, 6, 5, 3.6, hexColors(['#8E3B2C', '#B04A36', '#C2694A', '#E08A63', '#F5B48C']),
          rim: hexColor('#FFD9BE'));
      rectFill(g, 5, 8, 2, 3, hexColor('#B04A36'));
      put(g, 6, 11, hexColor('#8E3B2C'));
      rectFill(g, 5, 4, 2, 2, hexColor('#FDF6E7'));
    case 'search':
      disc(g, 5, 5, 3.6, hexColors(['#6B6A85', '#8A89A3', '#A9A8C0', '#C7C6DA', '#E6E5F2']));
      disc(g, 5, 5, 2.2, [hexColor('#FDF6E7')]);
      rectFill(g, 8, 8, 3, 1, hexColor('#6B6A85'));
      rectFill(g, 9, 9, 2, 1, hexColor('#6B6A85'));
    case 'home':
      rectFill(g, 2, 5, 8, 6, hexColor('#F2A03D'));
      for (var i = 0; i < 6; i++) {
        rectFill(g, 5 - i, 4 - (i ~/ 2), 2 + i * 2, 1, hexColor('#C2694A'));
      }
      rectFill(g, 5, 7, 2, 4, hexColor('#8E3B2C'));
    case 'gear':
      disc(g, 6, 6, 4.2, hexColors(['#6B6A85', '#8A89A3', '#A9A8C0', '#C7C6DA', '#E6E5F2']));
      disc(g, 6, 6, 1.8, [hexColor('#FDF6E7')]);
      for (final p in const [[6, 0], [6, 11], [0, 6], [11, 6]]) {
        put(g, p[0], p[1], hexColor('#8A89A3'));
      }
    case 'palette':
      disc(g, 6, 6, 4.6, hexColors(['#C2694A', '#E08A63', '#F2A03D', '#FFD75E', '#FFF3B8']));
      put(g, 4, 4, hexColor('#5B9BD5'));
      put(g, 8, 5, hexColor('#5BC0BE'));
      put(g, 5, 8, hexColor('#C24A34'));
  }
  outline(g, ink);
  return g;
}

/// 24x24 mascot sprite. `state` is one of: clear, rain, snow, storm, night,
/// sad.
PixelGrid mascot(String state) {
  final g = PixelGrid(24, 24);
  final body = state == 'snow' ? snowFurRamp : furRamp;

  disc(g, 8, 18, 4.4, body);
  disc(g, 15, 18, 4, body);
  disc(g, 11.5, 17, 5, body, rim: hexColor('#FFFFFF'));
  rectFill(g, 4, 18, 16, 4, body[2]);
  for (var x = 4; x < 20; x++) {
    put(g, x, 21, body[0]);
    put(g, x, 20, body[1]);
  }
  for (final cx in const [7.5, 15.5]) {
    for (var j = 0; j < 4; j++) {
      final w = j + 2;
      for (var i = 0; i < w; i++) {
        put(g, (cx - w / 2).round() + i, 3 + j, j < 2 ? body[4] : body[3]);
      }
    }
    put(g, cx.round(), 5, hexColor('#F2A0A0'));
    put(g, cx.round(), 6, hexColor('#EE8FA0'));
  }
  disc(g, 11.5, 10.5, 5.2, body, rim: hexColor('#FFFFFF'));

  if (state == 'night') {
    rectFill(g, 8, 10, 3, 1, ink);
    rectFill(g, 13, 10, 3, 1, ink);
  } else if (state == 'storm') {
    disc(g, 9, 10, 1.4, const [Color(0xFF2B2B44)]);
    disc(g, 14, 10, 1.4, const [Color(0xFF2B2B44)]);
    put(g, 9, 9, hexColor('#FFFFFF'));
    put(g, 14, 9, hexColor('#FFFFFF'));
    rectFill(g, 7, 8, 3, 1, hexColor('#8E9DB4'));
    rectFill(g, 13, 8, 3, 1, hexColor('#8E9DB4'));
  } else {
    disc(g, 9, 10.5, 1.5, const [Color(0xFF2B2B44)]);
    disc(g, 14, 10.5, 1.5, const [Color(0xFF2B2B44)]);
    put(g, 9, 10, hexColor('#FFFFFF'));
    put(g, 14, 10, hexColor('#FFFFFF'));
  }
  rectFill(g, 7, 13, 2, 1, hexColor('#F2A0A0'));
  rectFill(g, 15, 13, 2, 1, hexColor('#F2A0A0'));
  put(g, 11, 12, ink);
  put(g, 12, 12, ink);
  put(g, 11, 13, ink);
  put(g, 12, 13, ink);

  if (state == 'clear') {
    rectFill(g, 7, 9, 10, 1, hexColor('#1B1B2E'));
    rectFill(g, 7, 10, 4, 2, hexColor('#2B2B44'));
    rectFill(g, 13, 10, 4, 2, hexColor('#2B2B44'));
    rectFill(g, 11, 10, 2, 1, hexColor('#1B1B2E'));
    put(g, 8, 10, hexColor('#5B9BD5'));
    put(g, 14, 10, hexColor('#5B9BD5'));
  }
  if (state == 'rain') {
    rectFill(g, 19, 4, 1, 14, hexColor('#8E3B2C'));
    for (var i = 0; i < 5; i++) {
      rectFill(g, 15 + i, 3 - (2 - i).abs(), 1, 1, hexColor('#C24A34'));
    }
    rectFill(g, 14, 4, 11, 1, hexColor('#E0604A'));
    rectFill(g, 15, 3, 9, 1, hexColor('#C24A34'));
    rectFill(g, 16, 2, 7, 1, hexColor('#F07E62'));
    put(g, 20, 18, hexColor('#8E3B2C'));
    for (final p in const [[3, 6], [2, 10], [4, 14]]) {
      put(g, p[0], p[1], hexColor('#7FB6E0'));
      put(g, p[0], p[1] + 1, hexColor('#5B9BD5'));
    }
  }
  if (state == 'snow') {
    rectFill(g, 5, 14, 14, 2, hexColor('#C24A34'));
    rectFill(g, 5, 16, 3, 4, hexColor('#E0604A'));
    rectFill(g, 5, 15, 14, 1, hexColor('#E0604A'));
    put(g, 5, 20, hexColor('#8E3B2C'));
    put(g, 6, 20, hexColor('#8E3B2C'));
    put(g, 7, 20, hexColor('#8E3B2C'));
    for (final p in const [[2, 4], [20, 6], [4, 2]]) {
      put(g, p[0], p[1], hexColor('#FFFFFF'));
    }
  }
  if (state == 'night') {
    rectFill(g, 5, 5, 14, 3, hexColor('#5B7FD5'));
    rectFill(g, 6, 3, 11, 2, hexColor('#7E9BE8'));
    rectFill(g, 8, 2, 7, 1, hexColor('#5B7FD5'));
    disc(g, 18, 3, 1.6, [hexColor('#FFF3B8')]);
    rectFill(g, 16, 15, 2, 1, hexColor('#B7DAF3'));
    rectFill(g, 17, 16, 2, 1, hexColor('#B7DAF3'));
  }
  if (state == 'storm') {
    rectFill(g, 2, 2, 20, 3, hexColor('#4A5268'));
    rectFill(g, 3, 5, 18, 1, hexColor('#3B4257'));
    _bolt(g, 1, 6, hexColor('#FFD75E'), hexColor('#FFF3B8'));
  }
  if (state == 'sad') {
    rectFill(g, 8, 10, 3, 1, ink);
    rectFill(g, 13, 10, 3, 1, ink);
    rectFill(g, 10, 14, 4, 1, ink);
  }

  outline(g, ink);
  return g;
}

/// 64x32 rolling-hill silhouette tinted with the current hill color.
PixelGrid hillGrid(Color hillColor) {
  final g = PixelGrid(64, 32);
  final highlight = mixColor(hillColor, const Color(0xFFFFFFFF), 0.18);
  final shadow = mixColor(hillColor, const Color(0xFF000000), 0.25);
  for (var x = 0; x < 64; x++) {
    final h = 12 +
        (5 * math.sin(x / 7) + 3 * math.sin(x / 2.3)).round();
    for (var y = 32 - h; y < 32; y++) {
      final c = y < 32 - h + 1 ? highlight : (y > 28 ? shadow : hillColor);
      put(g, x, y, c);
    }
  }
  return g;
}

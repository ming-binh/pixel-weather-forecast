import 'dart:math' as math;
import 'dart:ui' show Color;

import 'pixel_grid.dart';

/// Color ramps and sprite generators ported from the Pixel Weather design's
/// procedural pixel-art engine (support.js `icon`/`mini`/`mascot`/`scenery`/
/// `bird`/`plane`/`balloon` code). Every sprite is drawn pixel-by-pixel
/// instead of loaded from an asset.

final List<Color> sunRamp = hexColors(['#C9761B', '#E89A2B', '#F7C244', '#FFDE7A', '#FFF3B8']);
final List<Color> cloudRamp = hexColors(['#8E9DB4', '#AEBCCD', '#CBD7E4', '#E8EFF6', '#FFFFFF']);
final List<Color> darkCloudRamp = hexColors(['#4C5468', '#5F6A80', '#767F95', '#8D95AA', '#A3AABD']);
final List<Color> moonRamp = hexColors(['#B7B3D6', '#CFCBE8', '#E4E1F5', '#F3F1FF', '#FFFFFF']);
final List<Color> furRamp = hexColors(['#B9C6DA', '#D3DEEC', '#E6EEF8', '#F6FAFF', '#FFFFFF']);
final List<Color> snowFurRamp = hexColors(['#A9BBD2', '#C3D2E5', '#DAE6F3', '#EDF4FC', '#FFFFFF']);
final List<Color> stormRamp = hexColors(['#333A4E', '#414A61', '#525C76', '#65708C', '#7B85A2']);
final List<Color> fogRamp = hexColors(['#AEB6C2', '#C2C9D3', '#D6DCE4', '#E9EDF2', '#F9FBFC']);
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

void _rays(PixelGrid g, num cx, num cy, num r, double phase, Color c1, Color c2) {
  for (var i = 0; i < 8; i++) {
    final a = phase + i * math.pi / 4;
    final dx = math.cos(a), dy = math.sin(a);
    final long = i % 2 == 0;
    put(g, cx + dx * (r + 1.6) - 0.5, cy + dy * (r + 1.6) - 0.5, c1);
    if (long) {
      put(g, cx + dx * (r + 2.9) - 0.5, cy + dy * (r + 2.9) - 0.5, c1);
      put(g, cx + dx * (r + 4.1) - 0.5, cy + dy * (r + 4.1) - 0.5, c2);
    }
  }
}

void _star(PixelGrid g, num x, num y, int size, Color c, Color c2) {
  put(g, x, y, c);
  if (size > 0) {
    put(g, x - 1, y, c2);
    put(g, x + 1, y, c2);
    put(g, x, y - 1, c2);
    put(g, x, y + 1, c2);
  }
  if (size > 1) {
    put(g, x - 2, y, c2);
    put(g, x + 2, y, c2);
    put(g, x, y - 2, c2);
    put(g, x, y + 2, c2);
  }
}

void _drop(PixelGrid g, num x, num y, bool long) {
  put(g, x, y, hexColor('#B7DAF3'));
  put(g, x, y + 1, hexColor('#7FB6E0'));
  put(g, x, y + 2, hexColor('#5B9BD5'));
  if (long) put(g, x, y + 3, hexColor('#4E7EA8'));
}

void _flake(PixelGrid g, num x, num y) {
  put(g, x, y, hexColor('#FFFFFF'));
  for (final d in const [[-1, 0], [1, 0], [0, -1], [0, 1]]) {
    put(g, x + d[0], y + d[1], hexColor('#DCE8F2'));
  }
  for (final d in const [[-1, -1], [1, 1], [1, -1], [-1, 1]]) {
    put(g, x + d[0], y + d[1], hexColor('#F2F8FF'));
  }
}

void _cloudBig(PixelGrid g, List<Color> ramp, num ox, num oy, Color rim) {
  disc(g, 10 + ox, 18 + oy, 6.4, ramp, rim: rim);
  disc(g, 18 + ox, 15.5 + oy, 8, ramp, rim: rim);
  disc(g, 25 + ox, 18.5 + oy, 5.6, ramp, rim: rim);
  for (var x = 5 + ox; x < 30 + ox; x++) {
    put(g, x, 19 + oy, ramp[2]);
    put(g, x, 20 + oy, ramp[2]);
    put(g, x, 21 + oy, ramp[1]);
    put(g, x, 22 + oy, ramp[0]);
  }
  final underside = mixColor(ramp[0], ink, .35);
  for (var x = 7 + ox; x < 28 + ox; x++) {
    put(g, x, 23 + oy, underside);
  }
}

/// Builds a looping sprite sheet: `n` frames of `size`×`size`, `draw` fills
/// each frame (frame index passed in), then every frame gets an ink outline.
SpriteSheet _sheetOf(int size, int n, double durationSeconds, void Function(PixelGrid g, int frame) draw) {
  final frames = <PixelGrid>[];
  for (var fr = 0; fr < n; fr++) {
    final g = PixelGrid(size, size);
    draw(g, fr);
    outline(g, ink);
    frames.add(g);
  }
  return SpriteSheet(frames, Duration(milliseconds: (durationSeconds * 1000).round()));
}

/// Animated 32×32 weather condition icon. `kind` is one of: clear, night,
/// partly, cloudy, rain, storm, snow, fog.
SpriteSheet weatherIconSheet(String kind) {
  switch (kind) {
    case 'clear':
      return _sheetOf(32, 4, 1.0, (g, f) {
        final r = 7.6 + (f == 1 || f == 3 ? 0.4 : 0);
        _rays(g, 16, 16, 7.6, f * math.pi / 16, hexColor('#FFDE7A'), hexColor('#E89A2B'));
        disc(g, 16, 16, r, sunRamp, rim: hexColor('#FFF6D0'));
        put(g, 12, 12, hexColor('#FFF9DC'));
        put(g, 13, 12, hexColor('#FFF3B8'));
        put(g, 12, 13, hexColor('#FFF3B8'));
        put(g, 20, 20, hexColor('#D9862A'));
        put(g, 19, 21, hexColor('#D9862A'));
      });
    case 'night':
      return _sheetOf(32, 4, 1.6, (g, f) {
        disc(g, 15, 17, 8.2, moonRamp, rim: hexColor('#FFFFFF'));
        // Punch a real transparent cutout for the crescent (the design's JS
        // passes a falsy color into its no-op `put`, so this never actually
        // fires there — replicated here with a direct clear so the crescent
        // reads correctly against any background, not just a solid patch).
        for (var y = 0; y < 32; y++) {
          for (var x = 0; x < 32; x++) {
            final dx = x + .5 - 20.5, dy = y + .5 - 13.5;
            if (math.sqrt(dx * dx + dy * dy) < 7.6) g.px[y * g.w + x] = null;
          }
        }
        final craters = hexColors(['#A9A5CC', '#BDB9DE', '#CFCBE8']);
        const craterPts = [[11, 19], [13, 22], [9, 14]];
        for (var i = 0; i < craterPts.length; i++) {
          disc(g, craterPts[i][0], craterPts[i][1], 1.6 + (i % 2) * 0.5, craters);
        }
        const seqs = [[0, 1, 2], [1, 2, 0], [2, 0, 1], [1, 1, 2]];
        final seq = seqs[f];
        const starPts = [[26, 6], [28, 14], [22, 3]];
        for (var i = 0; i < starPts.length; i++) {
          final s = seq[i];
          _star(g, starPts[i][0], starPts[i][1], s == 2 ? 1 : (s == 1 ? 0 : -1), hexColor('#FFF6C8'), hexColor('#FFE79A'));
        }
      });
    case 'partly':
      return _sheetOf(32, 4, 1.1, (g, f) {
        final d = const [0, 1, 1, 0][f];
        _rays(g, 23, 10, 4.6, f * math.pi / 16, hexColor('#FFDE7A'), hexColor('#E89A2B'));
        disc(g, 23, 10, 4.6, sunRamp, rim: hexColor('#FFF6D0'));
        _cloudBig(g, cloudRamp, -2, 3 + d, hexColor('#FFFFFF'));
      });
    case 'cloudy':
      return _sheetOf(32, 4, 1.6, (g, f) {
        final back = const [0, 1, 2, 1][f];
        final front = const [1, 0, 0, 1][f];
        disc(g, 22 + back, 11, 5.4, darkCloudRamp, rim: hexColor('#B4C0D2'));
        disc(g, 16 + back, 12, 4.4, darkCloudRamp);
        for (var x = 12 + back; x < 28 + back; x++) {
          put(g, x, 13, darkCloudRamp[1]);
          put(g, x, 14, darkCloudRamp[0]);
        }
        _cloudBig(g, cloudRamp, -2 + front, 3, hexColor('#FFFFFF'));
      });
    case 'rain':
      return _sheetOf(32, 4, 0.55, (g, f) {
        _cloudBig(g, darkCloudRamp, -1, -2, hexColor('#C6D3E4'));
        const drops = [[8, 0], [14, 2], [20, 1], [26, 3]];
        for (var i = 0; i < drops.length; i++) {
          final c = drops[i];
          final y = 22 + ((f * 2 + c[1]) % 8);
          _drop(g, c[0], y, i % 2 == 0);
          if (y > 27) _drop(g, c[0], y - 8, i % 2 == 0);
        }
      });
    case 'storm':
      return _sheetOf(32, 4, 0.42, (g, f) {
        _cloudBig(g, stormRamp, -1, -2, hexColor('#9FB4D6'));
        const drops = [[9, 1], [25, 2]];
        for (final c in drops) {
          final y = 22 + ((f * 2 + c[1]) % 8);
          _drop(g, c[0], y, true);
        }
        if (f == 0 || f == 2) {
          final bright = f == 0;
          const pts = [[17, 21], [16, 22], [16, 23], [15, 24], [18, 24], [17, 25], [17, 26], [16, 27], [19, 23], [18, 25]];
          for (final p in pts) {
            put(g, p[0], p[1], bright ? hexColor('#FFF3B8') : hexColor('#FFD75E'));
          }
          const glowPts = [[17, 22], [17, 23], [16, 25], [17, 27], [18, 23]];
          for (final p in glowPts) {
            put(g, p[0], p[1], bright ? hexColor('#FFFFFF') : hexColor('#FFE79A'));
          }
        }
      });
    case 'snow':
      return _sheetOf(32, 4, 1.5, (g, f) {
        _cloudBig(g, cloudRamp, -1, -2, hexColor('#FFFFFF'));
        const flakes = [[9, 0], [16, 2], [24, 1]];
        for (var i = 0; i < flakes.length; i++) {
          final c = flakes[i];
          final y = 23 + ((f + c[1]) % 5);
          final sway = const [0, 1, 0, -1][(f + i) % 4];
          _flake(g, c[0] + sway, y);
        }
      });
    case 'fog':
      return _sheetOf(32, 4, 1.3, (g, f) {
        _cloudBig(g, fogRamp, -1, -4, hexColor('#FFFFFF'));
        final off = const [0, 1, 2, 1][f];
        const bands = [[3, 22, 24], [6, 25, 22], [2, 28, 26]];
        for (var i = 0; i < bands.length; i++) {
          final b = bands[i];
          final x = b[0] + (i % 2 == 0 ? off : -off);
          final c = i == 1 ? hexColor('#E9EDF2') : hexColor('#D6DCE4');
          for (var k = 0; k < b[2]; k++) {
            if (k % 7 != 6) put(g, x + k, b[1], c);
          }
        }
      });
    default:
      return _sheetOf(32, 1, 1, (g, _) => rectFill(g, 8, 8, 16, 16, hexColor('#C7C6DA')));
  }
}

/// Animated 16×16 small stat/nav icon. `kind` is one of: humid, uv, wind,
/// feels, pin, search, home, gear, palette.
SpriteSheet miniIconSheet(String kind) {
  switch (kind) {
    case 'humid':
      return _sheetOf(16, 2, 1.1, (g, f) {
        final d = hexColors(['#2F6EA8', '#3E86C4', '#5B9BD5', '#7FB6E0', '#B7DAF3']);
        disc(g, 8, 10, 4.6, d, rim: hexColor('#DFF1FF'));
        for (var y = 2; y < 7; y++) {
          final w = math.max(1, ((y - 1) * 0.9).round());
          for (var i = 0; i < w; i++) {
            put(g, 8 - (w ~/ 2) + i, y, y < 4 ? hexColor('#7FB6E0') : hexColor('#5B9BD5'));
          }
        }
        put(g, 8, 2, hexColor('#B7DAF3'));
        if (f == 0) {
          put(g, 6, 10, hexColor('#DFF1FF'));
          put(g, 6, 11, hexColor('#DFF1FF'));
        } else {
          put(g, 6, 11, hexColor('#DFF1FF'));
        }
      });
    case 'uv':
      return _sheetOf(16, 4, 1.0, (g, f) {
        _rays(g, 8, 8, 3.6, f * math.pi / 16, hexColor('#FFDE7A'), hexColor('#E89A2B'));
        disc(g, 8, 8, 3.6, sunRamp, rim: hexColor('#FFF6D0'));
        put(g, 6, 6, hexColor('#FFF9DC'));
      });
    case 'wind':
      return _sheetOf(16, 3, 0.5, (g, f) {
        const rows = [[3, 2, 8], [7, 0, 10], [11, 4, 6]];
        for (var i = 0; i < rows.length; i++) {
          final r = rows[i];
          final light = i == 1;
          final c = light ? hexColor('#E8EFF6') : hexColor('#CBD7E4');
          final x0 = r[1] + ((f + i) % 3);
          for (var k = 0; k < r[2]; k++) {
            put(g, x0 + k, r[0], c);
          }
          final tip = x0 + r[2];
          put(g, tip, r[0] - 1, c);
          put(g, tip + 1, r[0], c);
          put(g, tip, r[0] + 1, hexColor('#AEBCCD'));
        }
      });
    case 'feels':
      return _sheetOf(16, 2, 0.9, (g, f) {
        rectFill(g, 6, 2, 4, 9, hexColor('#E8EFF6'));
        rectFill(g, 7, 2, 2, 9, hexColor('#FFFFFF'));
        disc(g, 8, 12, 3.2, hexColors(['#A33A2A', '#C24A34', '#E0604A', '#F07E62', '#FFA88E']), rim: hexColor('#FFC9B4'));
        final top = f == 0 ? 6 : 4;
        rectFill(g, 7, top, 2, 7, hexColor('#E0604A'));
        rectFill(g, 7, top, 2, 1, hexColor('#F07E62'));
        put(g, 11, 4, hexColor('#F2A03D'));
        put(g, 12, 6, hexColor('#F2A03D'));
      });
    case 'pin':
      return _sheetOf(16, 2, 0.8, (g, f) {
        final dy = f == 0 ? 0 : -1;
        disc(g, 8, 6 + dy, 4.4, hexColors(['#8E3B2C', '#B04A36', '#C2694A', '#E08A63', '#F5B48C']), rim: hexColor('#FFD9BE'));
        for (var j = 0; j < 4; j++) {
          final w = 4 - j;
          for (var i = 0; i < w; i++) {
            put(g, 8 - (w ~/ 2) + i, 10 + dy + j, j < 2 ? hexColor('#B04A36') : hexColor('#8E3B2C'));
          }
        }
        disc(g, 8, 6 + dy, 1.8, [hexColor('#FDF6E7')]);
        put(g, 7, 5 + dy, hexColor('#FFFFFF'));
        rectFill(g, 5, 15, 6, 1, hexColor('#8E3B2C'));
        if (f == 1) {
          put(g, 4, 14, hexColor('#C2694A'));
          put(g, 11, 14, hexColor('#C2694A'));
        }
      });
    case 'search':
      return _sheetOf(16, 2, 1.2, (g, f) {
        disc(g, 7, 7, 5, hexColors(['#5C5B78', '#7A7996', '#9897B4', '#B6B5D0', '#D4D3E8']));
        disc(g, 7, 7, 3.2, [hexColor('#EAF3FA')]);
        put(g, 5, 5, hexColor('#FFFFFF'));
        if (f == 1) {
          put(g, 6, 5, hexColor('#FFFFFF'));
          put(g, 5, 6, hexColor('#FFFFFF'));
        }
        for (final p in const [[11, 11], [12, 12], [13, 13], [12, 11], [13, 12]]) {
          put(g, p[0], p[1], hexColor('#5C5B78'));
        }
      });
    case 'home':
      return _sheetOf(16, 3, 0.9, (g, f) {
        rectFill(g, 11, 3, 2, 4, hexColor('#8E3B2C'));
        rectFill(g, 11, 3, 2, 1, hexColor('#B04A36'));
        final puff = const [[13, 1], [14, 0], [13, 2]][f];
        put(g, puff[0], puff[1], hexColor('#E6EEF8'));
        put(g, puff[0] + 1, puff[1], hexColor('#CBD7E4'));
        for (var j = 0; j < 6; j++) {
          final w = 2 + j * 2;
          rectFill(g, 8 - (w ~/ 2), 4 + j, w, 1, j < 2 ? hexColor('#E0604A') : hexColor('#C24A34'));
        }
        rectFill(g, 3, 10, 11, 5, hexColor('#F2A03D'));
        rectFill(g, 3, 10, 11, 1, hexColor('#FFD75E'));
        rectFill(g, 3, 14, 11, 1, hexColor('#C98B32'));
        rectFill(g, 6, 11, 4, 4, hexColor('#8E3B2C'));
        rectFill(g, 7, 12, 2, 3, hexColor('#5B3527'));
        rectFill(g, 11, 11, 2, 2, hexColor('#B7DAF3'));
        put(g, 11, 11, hexColor('#DFF1FF'));
      });
    case 'gear':
      return _sheetOf(16, 4, 0.9, (g, f) {
        final m = hexColors(['#4F4E6B', '#6B6A85', '#8A89A3', '#A9A8C0', '#C7C6DA']);
        for (var i = 0; i < 8; i++) {
          final a = f * math.pi / 16 + i * math.pi / 4;
          final dx = math.cos(a), dy = math.sin(a);
          for (final d in const [5.2, 6.2]) {
            put(g, 8 + dx * d - 0.5, 8 + dy * d - 0.5, d > 6 ? m[1] : m[3]);
            put(
              g,
              8 + dx * d - 0.5 + (dx.abs() > dy.abs() ? 0 : 1),
              8 + dy * d - 0.5 + (dx.abs() > dy.abs() ? 1 : 0),
              d > 6 ? m[0] : m[2],
            );
          }
        }
        disc(g, 8, 8, 5, m, rim: hexColor('#DEDDEE'));
        disc(g, 8, 8, 2.2, [hexColor('#FDF6E7')]);
      });
    case 'palette':
      return _sheetOf(16, 2, 0.9, (g, f) {
        disc(g, 8, 8, 6, hexColors(['#8E5A3C', '#A87049', '#C08A5C', '#D6A377', '#E8BE96']), rim: hexColor('#F6DCBE'));
        for (var y = 0; y < 16; y++) {
          for (var x = 0; x < 16; x++) {
            final dx = x + .5 - 11.5, dy = y + .5 - 10.5;
            if (math.sqrt(dx * dx + dy * dy) < 2.1) g.px[y * g.w + x] = null;
          }
        }
        const dabs = [[6, 5, '#C24A34'], [9, 5, '#F2A03D'], [5, 8, '#5B9BD5'], [7, 10, '#5BC0BE']];
        for (final p in dabs) {
          final c = hexColor(p[2] as String);
          disc(g, p[0] as int, p[1] as int, 1.5, [c]);
          put(g, (p[0] as int) - 1, (p[1] as int) - 1, mixColor(c, hexColor('#FFFFFF'), .45));
        }
        if (f == 1) {
          put(g, 13, 3, hexColor('#FFF3B8'));
          put(g, 12, 3, hexColor('#FFE79A'));
          put(g, 13, 2, hexColor('#FFE79A'));
          put(g, 13, 4, hexColor('#FFE79A'));
          put(g, 14, 3, hexColor('#FFE79A'));
        }
      });
    default:
      return _sheetOf(16, 1, 1, (g, _) => rectFill(g, 4, 4, 8, 8, hexColor('#C7C6DA')));
  }
}

/// Small flapping bird, used as a sky decoration.
SpriteSheet birdSheet() {
  return _sheetOf(16, 2, 0.28, (g, f) {
    final b = hexColors(['#2B2B44', '#42425F', '#5C5C7C']);
    rectFill(g, 6, 8, 5, 2, b[1]);
    put(g, 11, 8, b[1]);
    put(g, 11, 9, b[2]);
    put(g, 12, 8, hexColor('#F2A03D'));
    put(g, 10, 8, hexColor('#FFFFFF'));
    rectFill(g, 4, 9, 3, 1, b[0]);
    if (f == 0) {
      for (var i = 0; i < 4; i++) {
        put(g, 7 + i, 7 - i, b[0]);
        put(g, 7 + i, 6 - i, b[2]);
      }
      for (var i = 0; i < 3; i++) {
        put(g, 6 - i, 9 + i, b[1]);
      }
    } else {
      for (var i = 0; i < 4; i++) {
        put(g, 7 + i, 10 + i, b[0]);
        put(g, 7 + i, 11 + i, b[2]);
      }
      for (var i = 0; i < 3; i++) {
        put(g, 6 - i, 8 - i, b[1]);
      }
    }
  });
}

/// Small propeller plane, used as a sky decoration.
SpriteSheet planeSheet() {
  return _sheetOf(24, 2, 0.5, (g, f) {
    final m = hexColors(['#8E93A8', '#B6BACB', '#DDE0EA', '#F4F5FA']);
    rectFill(g, 3, 6, 17, 3, m[2]);
    rectFill(g, 3, 6, 17, 1, m[3]);
    rectFill(g, 4, 9, 15, 1, m[0]);
    for (var i = 0; i < 4; i++) {
      put(g, 20 + i, 7, m[1]);
    }
    put(g, 20, 6, m[1]);
    put(g, 21, 6, m[1]);
    put(g, 20, 8, m[1]);
    rectFill(g, 2, 7, 2, 2, m[1]);
    rectFill(g, 8, 9, 7, 3, m[1]);
    rectFill(g, 9, 12, 4, 1, m[0]);
    rectFill(g, 10, 2, 3, 4, m[1]);
    rectFill(g, 10, 2, 3, 1, m[2]);
    for (final x in const [5, 7, 9, 11, 13, 15]) {
      put(g, x, 7, hexColor('#7FB6E0'));
    }
    put(g, 2, 7, f == 0 ? hexColor('#FF6B6B') : hexColor('#8E3B2C'));
    put(g, 19, 9, f == 1 ? hexColor('#FFF3B8') : hexColor('#8E7B3B'));
  });
}

/// Small hot-air balloon, used as a sky decoration at dawn/dusk.
SpriteSheet balloonSheet() {
  return _sheetOf(16, 2, 1.2, (g, f) {
    final a = hexColors(['#B23838', '#C94848', '#E0604A']);
    final b = hexColors(['#C98B2B', '#F2A03D', '#FFD75E']);
    for (var y = 1; y < 9; y++) {
      final w = y < 2 ? 4 : (y < 6 ? 8 : 8 - (y - 5) * 2);
      for (var i = 0; i < w; i++) {
        final x = 8 - (w ~/ 2) + i;
        final band = x % 4 < 2;
        put(g, x, y, band ? a[1] : b[1]);
      }
    }
    put(g, 5, 4, a[2]);
    put(g, 10, 4, b[2]);
    put(g, 7, 9, hexColor('#8E7B3B'));
    put(g, 9, 9, hexColor('#8E7B3B'));
    rectFill(g, 7, 10, 3, 3, hexColor('#A87049'));
    rectFill(g, 7, 10, 3, 1, hexColor('#C08A5C'));
  });
}

/// A small UFO with blinking lights, used as a sky decoration during storms.
SpriteSheet ufoSheet() {
  return _sheetOf(32, 2, 0.6, (g, f) {
    disc(g, 16, 8, 7.4, hexColors(['#1F4A82', '#2C5A9C', '#3E70B4']), rim: hexColor('#8FC1F2'));
    disc(g, 20, 6, 2.6, hexColors(['#6FA9E0', '#8FC1F2', '#BBDCF7']));
    rectFill(g, 7, 13, 18, 3, hexColor('#B7B7B7'));
    rectFill(g, 7, 13, 18, 1, hexColor('#D9D9D9'));
    rectFill(g, 4, 16, 24, 3, hexColor('#3A3A3A'));
    rectFill(g, 4, 16, 24, 1, hexColor('#606060'));
    rectFill(g, 9, 17, 14, 3, hexColor('#6B6B6B'));
    const lights = [[6, 17], [10, 18], [14, 17], [18, 18], [22, 17], [25, 18]];
    for (var i = 0; i < lights.length; i++) {
      final p = lights[i];
      final on = f == 0 ? i % 2 == 0 : i % 2 == 1;
      put(g, p[0], p[1], on ? hexColor('#5FBE87') : hexColor('#2E6B45'));
    }
    rectFill(g, 13, 20, 6, 1, hexColor('#7ED2A0'));
    rectFill(g, 14, 22, 4, 1, hexColor('#7ED2A0'));
    rectFill(g, 15, 24, 2, 1, hexColor('#7ED2A0'));
    put(g, 15, 26, hexColor('#7ED2A0'));
  });
}

/// A single static cloud shape (no animation) — used as pure background
/// decoration behind the home-screen widget's weather icon.
SpriteSheet decorCloudSheet() {
  return _sheetOf(32, 1, 1, (g, f) => _cloudBig(g, cloudRamp, -2, 4, hexColor('#FFFFFF')));
}

/// 24x24 mascot sprite (the procedural "Mèo Mây" fallback for characters
/// with no bespoke art). `state` is one of: clear, rain, snow, storm, night,
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

/// 92×48 three-layer parallax landscape (far/mid/near hills, trees, a house,
/// a fence) tinted with the current hill color, tod/cond-aware — replaces
/// the old single-band `hillGrid`. Contrast between the three hill bands is
/// pushed a bit further than the design's own `.34`/`.28` mix factors so the
/// depth layers stay readable at the small scale phones render this at.
PixelGrid scenery(Color hillColor, String tod, String cond) {
  const w = 92, h = 48;
  final g = PixelGrid(w, h);
  final night = tod == 'night';
  final far = mixColor(hillColor, const Color(0xFFFFFFFF), .42);
  final mid = hillColor;
  final near = mixColor(hillColor, const Color(0xFF000000), .34);

  for (var x = 0; x < w; x++) {
    final h1 = 18 + (4 * math.sin(x / 11) + 2 * math.sin(x / 4)).round();
    for (var y = h - h1; y < h; y++) {
      put(g, x, y, y == h - h1 ? mixColor(far, const Color(0xFFFFFFFF), .25) : far);
    }
  }
  for (var x = 0; x < w; x++) {
    final h2 = 12 + (5 * math.sin(x / 7 + 2) + 2 * math.sin(x / 2.6)).round();
    for (var y = h - h2; y < h; y++) {
      put(g, x, y, y == h - h2 ? mixColor(mid, const Color(0xFFFFFFFF), .2) : mid);
    }
  }

  final trunk = mixColor(near, hexColor('#3A2418'), .55);
  final leafA = mixColor(near, hexColor('#2E5B3A'), .55);
  final leafB = mixColor(leafA, const Color(0xFFFFFFFF), .22);

  void pine(int x, int base, int s) {
    rectFill(g, x, base - 2, 2, 3, trunk);
    for (var j = 0; j < s; j++) {
      final wj = 2 + j * 2;
      for (var i = 0; i < wj; i++) {
        put(g, x + 1 - (wj ~/ 2) + i, base - 2 - j, i == 0 ? leafA : (j % 2 == 1 ? leafA : leafB));
      }
    }
  }

  void bush(int x, int base, num r) {
    disc(g, x, base - r, r, [leafA, leafA, leafB, mixColor(leafB, const Color(0xFFFFFFFF), .25)]);
    rectFill(g, x - 1, base - 2, 2, 2, trunk);
  }

  for (final t in const [[6, 4], [13, 6], [21, 5], [70, 5], [80, 7], [87, 4]]) {
    pine(t[0], h - 9, t[1]);
  }
  for (final t in const [[30, 3], [38, 4], [60, 3]]) {
    bush(t[0], h - 8, t[1]);
  }

  // Little house.
  const hx = 46, hy = h - 16;
  rectFill(g, hx, hy + 5, 11, 7, mixColor(near, hexColor('#C08A5C'), .5));
  for (var j = 0; j < 5; j++) {
    final wj = 3 + j * 2 + 2;
    rectFill(g, hx + 5 - (wj ~/ 2), hy + j, wj, 1, j < 2 ? hexColor('#C24A34') : hexColor('#8E3B2C'));
  }
  rectFill(g, hx + 2, hy + 7, 3, 3, night ? hexColor('#FFD75E') : hexColor('#7FB6E0'));
  rectFill(g, hx + 7, hy + 8, 3, 4, hexColor('#5B3527'));
  rectFill(g, hx + 8, hy + 0, 2, 4, hexColor('#8E3B2C'));

  // Fence.
  final fenceColor = mixColor(near, hexColor('#D6A377'), .5);
  for (var x = hx + 13; x < hx + 26; x += 3) {
    rectFill(g, x, h - 10, 1, 5, fenceColor);
  }
  rectFill(g, hx + 13, h - 9, 13, 1, fenceColor);

  // Near ground.
  for (var x = 0; x < w; x++) {
    final h3 = 6 + (2 * math.sin(x / 9 + 1)).round();
    for (var y = h - h3; y < h; y++) {
      put(g, x, y, y == h - h3 ? mixColor(near, const Color(0xFFFFFFFF), .16) : near);
    }
  }
  final grassBlade = mixColor(near, const Color(0xFFFFFFFF), .1);
  for (var x = 0; x < w; x += 5) {
    put(g, x, h - 6 - ((x ~/ 5) % 2), grassBlade);
  }

  if (cond == 'snow') {
    final snapshot = List<Color?>.from(g.px);
    for (var x = 0; x < w; x++) {
      for (var y = 0; y < h; y++) {
        final here = snapshot[y * w + x];
        final above = y == 0 ? null : snapshot[(y - 1) * w + x];
        if (here != null && above == null) {
          put(g, x, y, mixColor(here, const Color(0xFFFFFFFF), .65));
        }
      }
    }
  }
  return g;
}

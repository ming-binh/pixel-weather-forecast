import 'dart:math' as math;
import 'dart:ui' show Color;

/// A grid of pixels, each either a [Color] or null (transparent).
/// Mirrors the `G(w,h)` / `put` / `rect` / `disc` / `outline` helpers from
/// the Pixel Weather design's procedural sprite generator.
class PixelGrid {
  final int w;
  final int h;
  final List<Color?> px;

  PixelGrid(this.w, this.h) : px = List<Color?>.filled(w * h, null);

  Color? at(int x, int y) {
    if (x < 0 || y < 0 || x >= w || y >= h) return null;
    return px[y * w + x];
  }
}

void put(PixelGrid g, num x, num y, Color? c) {
  final xi = x.round();
  final yi = y.round();
  if (c == null || xi < 0 || yi < 0 || xi >= g.w || yi >= g.h) return;
  g.px[yi * g.w + xi] = c;
}

void rectFill(PixelGrid g, num x, num y, int w, int h, Color c) {
  for (var j = 0; j < h; j++) {
    for (var i = 0; i < w; i++) {
      put(g, x + i, y + j, c);
    }
  }
}

/// Shaded disc with a directional light ramp, matching `disc()`.
void disc(
  PixelGrid g,
  num cx,
  num cy,
  num r,
  List<Color> ramp, {
  double lx = -0.5,
  double ly = -0.85,
  Color? rim,
}) {
  for (var y = 0; y < g.h; y++) {
    for (var x = 0; x < g.w; x++) {
      final dx = x + 0.5 - cx;
      final dy = y + 0.5 - cy;
      final d = math.sqrt(dx * dx + dy * dy);
      if (d > r) continue;
      final n = (dx * lx + dy * ly) / (d == 0 ? 1 : d);
      var idx = (((n + 1) / 2) * ramp.length).floor();
      idx = idx.clamp(0, ramp.length - 1);
      if (d > r - 1) {
        if (rim != null && n < -0.25) {
          put(g, x, y, rim);
          continue;
        }
        idx = (idx - 1).clamp(0, ramp.length - 1);
      }
      put(g, x, y, ramp[idx]);
    }
  }
}

/// Outlines every pixel adjacent to a filled one, matching `outline()`.
void outline(PixelGrid g, Color c) {
  final snapshot = List<Color?>.from(g.px);
  bool filled(int x, int y) {
    if (x < 0 || y < 0 || x >= g.w || y >= g.h) return false;
    return snapshot[y * g.w + x] != null;
  }

  for (var y = 0; y < g.h; y++) {
    for (var x = 0; x < g.w; x++) {
      if (snapshot[y * g.w + x] != null) continue;
      final hasNeighbor =
          filled(x + 1, y) || filled(x - 1, y) || filled(x, y + 1) || filled(x, y - 1);
      if (hasNeighbor) put(g, x, y, c);
    }
  }
}

/// A looping sequence of [PixelGrid] frames, matching the design's
/// `sheetOf(size,n,dur,draw)` — `duration` is the whole loop's length,
/// stepped between frames like CSS `steps(n,end)` (no cross-fade).
class SpriteSheet {
  final List<PixelGrid> frames;
  final Duration duration;
  const SpriteSheet(this.frames, this.duration);
}

/// Parses a `#RRGGBB` or `#RRGGBBAA` string into a [Color].
Color hexColor(String hex) {
  var h = hex.replaceFirst('#', '');
  if (h.length == 6) h = '${h}FF';
  final r = int.parse(h.substring(0, 2), radix: 16);
  final g = int.parse(h.substring(2, 4), radix: 16);
  final b = int.parse(h.substring(4, 6), radix: 16);
  final a = int.parse(h.substring(6, 8), radix: 16);
  return Color.fromARGB(a, r, g, b);
}

List<Color> hexColors(List<String> hexes) => hexes.map(hexColor).toList();

/// Linear-interpolates two colors, matching `MIX(a,b,t)`.
Color mixColor(Color a, Color b, double t) {
  return Color.fromARGB(
    255,
    (a.r * 255 + (b.r * 255 - a.r * 255) * t).round().clamp(0, 255),
    (a.g * 255 + (b.g * 255 - a.g * 255) * t).round().clamp(0, 255),
    (a.b * 255 + (b.b * 255 - a.b * 255) * t).round().clamp(0, 255),
  );
}

/// Desaturates a color towards its luma, matching `DESAT(h,t)`.
Color desatColor(Color c, double t) {
  final r = c.r * 255, g = c.g * 255, b = c.b * 255;
  final l = r * 0.3 + g * 0.59 + b * 0.11;
  return Color.fromARGB(
    255,
    (r + (l - r) * t).round().clamp(0, 255),
    (g + (l - g) * t).round().clamp(0, 255),
    (b + (l - b) * t).round().clamp(0, 255),
  );
}

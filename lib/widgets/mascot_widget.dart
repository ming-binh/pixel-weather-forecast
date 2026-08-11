import 'package:flutter/material.dart';

import '../pixel/sprites.dart';
import 'pixel_sprite.dart';

/// Display name, settings-picker blurb, and advice-bubble tag for a mascot.
class MascotInfo {
  final String name;
  final String sub;
  final String tag;
  const MascotInfo(this.name, this.sub, this.tag);
}

const mascotChars = <String, MascotInfo>{
  'fu': MascotInfo('Fu', 'Mèo rừng tai nhọn, mắt lá non', 'FU MÁCH'),
  'nii': MascotInfo('Nii', 'Linh cừu sương mù, nói ít', 'NII THÌ THẦM'),
  'cat': MascotInfo('Mèo Mây', 'Tinh linh mây, hay ngủ gật', 'MÈO MÂY MÁCH'),
};

/// Renders the selected companion's portrait for a given weather state.
/// Fu and Nii use bespoke pixel-art assets; the original cat is drawn
/// procedurally.
class MascotWidget extends StatelessWidget {
  final String char; // 'fu' | 'nii' | 'cat'
  final String state; // clear | rain | storm | snow | night | sad
  final double size;

  const MascotWidget({super.key, required this.char, required this.state, required this.size});

  @override
  Widget build(BuildContext context) {
    if (char == 'fu' || char == 'nii') {
      return Image.asset(
        'assets/mascots/${char}_$state.png',
        width: size,
        height: size,
        filterQuality: FilterQuality.none,
      );
    }
    return PixelSprite(mascot(state), size: size);
  }
}

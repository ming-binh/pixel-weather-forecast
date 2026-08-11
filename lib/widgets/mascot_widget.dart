import 'package:flutter/material.dart';

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
  'shor': MascotInfo('Shor', 'Bướm đêm canh giữ bờ biển', 'SHOR NHẮC NHỞ'),
};

/// Renders the selected companion's portrait for a given weather state.
/// Every character is bespoke pixel-art loaded from
/// `assets/mascots/{char}_{state}.png`.
class MascotWidget extends StatelessWidget {
  final String char; // 'fu' | 'nii' | 'shor'
  final String state; // clear | rain | storm | snow | night | sad
  final double size;
  final bool useDefault;

  const MascotWidget({
    super.key,
    required this.char,
    required this.state,
    required this.size,
    this.useDefault = false,
  });

  @override
  Widget build(BuildContext context) {
    final path = useDefault
        ? 'assets/mascots/$char.png'
        : 'assets/mascots/${char}_$state.png';
    return Image.asset(path, width: size, height: size, filterQuality: FilterQuality.none);
  }
}


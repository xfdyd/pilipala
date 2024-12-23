import 'package:flutter/material.dart';
import 'package:PiliPalaX/utils/utils.dart';

class StatDanMu extends StatelessWidget {
  final String? theme;
  final dynamic danmu;
  final String? size;

  const StatDanMu({super.key, this.theme, this.danmu, this.size});

  @override
  Widget build(BuildContext context) {
    Map<String, Color> colorObject = {
      'white': Colors.white,
      'gray': Theme.of(context).colorScheme.outline.withOpacity(0.8),
      'black': Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
    };
    Color color = colorObject[theme]!;
    return Row(
      children: [
        Icon(
          Icons.subtitles_outlined,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 2),
        Text(
          Utils.numFormat(danmu!),
          style: TextStyle(
            fontSize: size == 'medium' ? 12 : 11,
            color: color,
          ),
          overflow: TextOverflow.clip,
          semanticsLabel: '${Utils.numFormat(danmu!)}条弹幕',
        )
      ],
    );
  }
}

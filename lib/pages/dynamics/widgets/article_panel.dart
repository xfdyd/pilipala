import 'package:flutter/material.dart';
import 'package:PiliPalaX/utils/utils.dart';

import '../../../common/constants.dart';
import 'pic_panel.dart';

Widget articlePanel(item, context, {floor = 1}) {
  TextStyle authorStyle =
      TextStyle(color: Theme.of(context).colorScheme.primary);
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: StyleString.safeSpace),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (floor == 2) ...[
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Text(
                  '@${item.modules.moduleAuthor.name}',
                  style: authorStyle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                Utils.dateFormat(item.modules.moduleAuthor.pubTs),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: Theme.of(context).textTheme.labelSmall!.fontSize),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Row(children: [
          Text(
            item.modules.moduleDynamic.major.opus.title,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
          )
        ]),
        const SizedBox(height: 2),
        if (item.modules.moduleDynamic.major.opus.summary.text != 'undefined' &&
            item.modules.moduleDynamic.major.opus.summary.richTextNodes
                .isNotEmpty) ...[
          Text(
            item.modules.moduleDynamic.major.opus.summary.richTextNodes.first
                .text,
            maxLines: 6,
            style: const TextStyle(height: 1.55),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
        ],
        picWidget(item, context)
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/constants.dart';
import 'package:PiliPalaX/common/widgets/badge.dart';
import 'package:PiliPalaX/common/widgets/network_img_layer.dart';
import 'package:PiliPalaX/models/dynamics/result.dart';
import 'package:PiliPalaX/pages/dynamics/index.dart';
import 'package:PiliPalaX/utils/utils.dart';

import 'rich_node_panel.dart';

final DynamicsController _dynamicsController = Get.put(DynamicsController());
Widget liveRcmdPanel(item, context, {floor = 1}) {
  TextStyle authorStyle =
      TextStyle(color: Theme.of(context).colorScheme.primary);
  DynamicLiveModel liveRcmd = item.modules.moduleDynamic.major.liveRcmd;
  int liveStatus = liveRcmd.liveStatus!;
  Map watchedShow = liveRcmd.watchedShow!;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (floor == 2) ...[
        Row(
          children: [
            GestureDetector(
              onTap: () => Get.toNamed(
                  '/member?mid=${item.modules.moduleAuthor.mid}',
                  arguments: {'face': item.modules.moduleAuthor.face}),
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
      ],
      const SizedBox(height: 4),
      if (item.modules.moduleDynamic.topic != null) ...[
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: StyleString.safeSpace),
          child: GestureDetector(
            child: Text(
              '#${item.modules.moduleDynamic.topic.name}',
              style: authorStyle,
            ),
          ),
        ),
        const SizedBox(height: 6),
      ],
      if (floor == 2 && item.modules.moduleDynamic.desc != null) ...[
        Text.rich(richNode(item, context)!),
        const SizedBox(height: 6),
      ],
      Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: StyleString.safeSpace),
          child: GestureDetector(
            onTap: () {
              _dynamicsController.pushDetail(item, floor);
            },
            child: LayoutBuilder(builder: (context, box) {
              double width = box.maxWidth;
              return Stack(
                children: [
                  Hero(
                    tag: liveRcmd.roomId.toString(),
                    child: NetworkImgLayer(
                      type: floor == 1 ? 'emote' : null,
                      width: width,
                      height: width / StyleString.aspectRatio,
                      src: item.modules.moduleDynamic.major.liveRcmd.cover,
                    ),
                  ),
                  PBadge(
                    text: watchedShow['text_large'],
                    top: 6,
                    right: 56,
                    bottom: null,
                    left: null,
                    type: 'gray',
                  ),
                  PBadge(
                    text: liveStatus == 1 ? '直播中' : '直播结束',
                    top: 6,
                    right: 6,
                    bottom: null,
                    left: null,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 80,
                      padding: const EdgeInsets.fromLTRB(12, 0, 10, 10),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              Colors.transparent,
                              Colors.black45,
                            ],
                          ),
                          borderRadius: floor == 1
                              ? null
                              : const BorderRadius.all(Radius.circular(6))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          DefaultTextStyle.merge(
                            style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .fontSize,
                                color: Colors.white),
                            child: Row(
                              children: [
                                Text(item.modules.moduleDynamic.major.liveRcmd
                                        .areaName ??
                                    ''),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          )),
      const SizedBox(height: 6),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: StyleString.safeSpace),
        child: Text(
          item.modules.moduleDynamic.major.liveRcmd.title,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      const SizedBox(height: 2),
    ],
  );
}

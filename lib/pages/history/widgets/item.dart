import 'package:PiliPalaX/utils/app_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/constants.dart';
import 'package:PiliPalaX/common/widgets/badge.dart';
import 'package:PiliPalaX/common/widgets/network_img_layer.dart';
import 'package:PiliPalaX/http/search.dart';
import 'package:PiliPalaX/http/user.dart';
import 'package:PiliPalaX/http/video.dart';
import 'package:PiliPalaX/models/bangumi/info.dart';
import 'package:PiliPalaX/models/common/business_type.dart';
import 'package:PiliPalaX/models/common/search_type.dart';
import 'package:PiliPalaX/models/live/item.dart';
import 'package:PiliPalaX/pages/history_search/index.dart';
import 'package:PiliPalaX/utils/feed_back.dart';
import 'package:PiliPalaX/utils/id_utils.dart';
import 'package:PiliPalaX/utils/utils.dart';

class HistoryItem extends StatelessWidget {
  final dynamic videoItem;
  final dynamic ctr;
  final Function? onChoose;
  final Function? onUpdateMultiple;
  const HistoryItem({
    super.key,
    required this.videoItem,
    this.ctr,
    this.onChoose,
    this.onUpdateMultiple,
  });

  @override
  Widget build(BuildContext context) {
    int aid = videoItem.history.oid;
    String bvid = videoItem.history.bvid ?? IdUtils.av2bv(aid);
    String heroTag = Utils.makeHeroTag(aid);
    return InkWell(
      onTap: () async {
        if (ctr!.enableMultiple.value) {
          feedBack();
          onChoose!();
          return;
        }
        if (videoItem.history.business.contains('article')) {
          // int cid = videoItem.history.cid ??
          //     // videoItem.history.oid ??
          //     await SearchHttp.ab2c(aid: aid, bvid: bvid);
          // if (cid == -1) cid = aid;
          // Get.toNamed(
          //   '/webview',
          //   parameters: {
          //     'url': 'https://www.bilibili.com/read/cv$cid',
          //     'type': 'note',
          //     'pageTitle': videoItem.title
          //   },
          // );
          PiliScheme.routePush(Uri.parse(
              "https://www.bilibili.com/read/cv${videoItem.history.oid}"));
        } else if (videoItem.history.business == 'live') {
          if (videoItem.liveStatus == 1) {
            LiveItemModel liveItem = LiveItemModel.fromJson({
              'face': videoItem.authorFace,
              'roomid': videoItem.history.oid,
              'pic': videoItem.cover,
              'title': videoItem.title,
              'uname': videoItem.authorName,
              'cover': videoItem.cover,
            });
            Get.toNamed(
              '/liveRoom?roomid=${videoItem.history.oid}',
              arguments: {'liveItem': liveItem},
            );
          } else {
            SmartDialog.showToast('直播未开播');
          }
        } else if (videoItem.badge == '番剧' ||
            videoItem.tagName.contains('动画')) {
          /// hack
          var bvid = videoItem.history.bvid;
          if (bvid != null && bvid != '') {
            var result = await VideoHttp.videoIntro(bvid: bvid);
            if (result['status']) {
              String bvid = result['data'].bvid!;
              int cid = result['data'].cid!;
              String pic = result['data'].pic!;
              String heroTag = Utils.makeHeroTag(cid);
              var epid = result['data'].epId;
              if (epid != null) {
                Get.toNamed(
                  '/video?bvid=$bvid&cid=$cid&epId=${result['data'].epId}',
                  arguments: {
                    'pic': pic,
                    'heroTag': heroTag,
                    'videoType': SearchType.media_bangumi,
                  },
                );
              } else {
                int cid = videoItem.history.cid ??
                    // videoItem.history.oid ??
                    await SearchHttp.ab2c(aid: aid, bvid: bvid);
                Get.toNamed('/video?bvid=$bvid&cid=$cid',
                    arguments: {'heroTag': heroTag, 'pic': videoItem.cover});
              }
            } else {
              SmartDialog.showToast(result['msg']);
            }
          } else {
            if (videoItem.history.epid != '') {
              SmartDialog.showLoading(msg: '获取中...');
              var res =
                  await SearchHttp.bangumiInfo(epId: videoItem.history.epid);
              SmartDialog.dismiss();
              if (res['status']) {
                EpisodeItem episode = res['data'].episodes.first;
                for (EpisodeItem i in res['data'].episodes) {
                  if (i.epId == videoItem.history.epid) {
                    episode = i;
                    break;
                  }
                }
                String bvid = episode.bvid!;
                int cid = episode.cid!;
                String pic = episode.cover!;
                String heroTag = Utils.makeHeroTag(cid);
                Get.toNamed(
                  '/video?bvid=$bvid&cid=$cid&seasonId=${res['data'].seasonId}&epid=${episode.epId}',
                  arguments: {
                    'pic': pic,
                    'heroTag': heroTag,
                    'videoType': SearchType.media_bangumi,
                    'bangumiItem': res['data'],
                  },
                );
              } else {
                SmartDialog.showToast(res['msg']);
              }
            }
          }
        } else {
          int cid = videoItem.history.cid ??
              // videoItem.history.oid ??
              await SearchHttp.ab2c(aid: aid, bvid: bvid);
          Get.toNamed('/video?bvid=$bvid&cid=$cid',
              arguments: {'heroTag': heroTag, 'pic': videoItem.cover});
        }
      },
      onLongPress: () {
        if (ctr is HistorySearchController) {
          return;
        }
        if (!ctr!.enableMultiple.value) {
          feedBack();
          ctr!.enableMultiple.value = true;
          onChoose!();
          onUpdateMultiple!();
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                StyleString.safeSpace, 0, StyleString.safeSpace, 0),
            child: LayoutBuilder(
              builder: (context, boxConstraints) {
                double width =
                    (boxConstraints.maxWidth - StyleString.cardSpace * 6) / 2;
                return SizedBox(
                  height: width / StyleString.aspectRatio,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: StyleString.aspectRatio,
                            child: LayoutBuilder(
                              builder: (context, boxConstraints) {
                                double maxWidth = boxConstraints.maxWidth;
                                double maxHeight = boxConstraints.maxHeight;
                                return Stack(
                                  children: [
                                    Hero(
                                      tag: heroTag,
                                      child: NetworkImgLayer(
                                        src: (videoItem.cover != ''
                                            ? videoItem.cover
                                            : videoItem.covers.first),
                                        width: maxWidth,
                                        height: maxHeight,
                                      ),
                                    ),
                                    if (!BusinessType
                                        .hiddenDurationType.hiddenDurationType
                                        .contains(videoItem.history.business))
                                      PBadge(
                                        text: videoItem.progress == -1
                                            ? '已看完'
                                            : '${Utils.timeFormat(videoItem.progress!)}/${Utils.timeFormat(videoItem.duration!)}',
                                        right: 6.0,
                                        bottom: 6.0,
                                        type: 'gray',
                                      ),
                                    // 右上角
                                    if (BusinessType.showBadge.showBadge
                                            .contains(
                                                videoItem.history.business) ||
                                        videoItem.history.business ==
                                            BusinessType.live.type)
                                      PBadge(
                                        text: videoItem.badge,
                                        top: 6.0,
                                        right: 6.0,
                                        bottom: null,
                                        left: null,
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Obx(
                            () => Positioned.fill(
                              child: AnimatedOpacity(
                                opacity: ctr!.enableMultiple.value ? 1 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.black.withOpacity(
                                        ctr!.enableMultiple.value &&
                                                videoItem.checked
                                            ? 0.6
                                            : 0),
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: 34,
                                      height: 34,
                                      child: AnimatedScale(
                                        scale: videoItem.checked ? 1 : 0,
                                        duration:
                                            const Duration(milliseconds: 250),
                                        curve: Curves.easeInOut,
                                        child: IconButton(
                                          tooltip: '取消选择',
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all(
                                                EdgeInsets.zero),
                                            backgroundColor:
                                                MaterialStateProperty
                                                    .resolveWith(
                                              (states) {
                                                return Colors.white
                                                    .withOpacity(0.8);
                                              },
                                            ),
                                          ),
                                          onPressed: () {
                                            feedBack();
                                            onChoose!();
                                          },
                                          icon: Icon(Icons.done_all_outlined,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      VideoContent(videoItem: videoItem, ctr: ctr)
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

class VideoContent extends StatelessWidget {
  final dynamic videoItem;
  final dynamic ctr;
  const VideoContent({super.key, required this.videoItem, this.ctr});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 2, 6, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              videoItem.title,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
              maxLines: videoItem.videos > 1 ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (videoItem.isFullScreen != null) ...[
              const SizedBox(height: 2),
              Text(
                videoItem.isFullScreen,
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.outline),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Spacer(),
            if (videoItem.authorName != '')
              Row(
                children: [
                  Text(
                    videoItem.authorName,
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelMedium!.fontSize,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Utils.dateFormat(videoItem.viewAt!),
                  style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelMedium!.fontSize,
                      color: Theme.of(context).colorScheme.outline),
                ),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    tooltip: '功能菜单',
                    icon: Icon(
                      Icons.more_vert_outlined,
                      color: Theme.of(context).colorScheme.outline,
                      size: 14,
                    ),
                    position: PopupMenuPosition.under,
                    // constraints: const BoxConstraints(maxHeight: 35),
                    onSelected: (String type) {},
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      if (videoItem.badge != '番剧' &&
                          !videoItem.tagName.contains('动画') &&
                          videoItem.history.business != 'live' &&
                          !videoItem.history.business.contains('article'))
                        PopupMenuItem<String>(
                          onTap: () async {
                            var res = await UserHttp.toViewLater(
                                bvid: videoItem.history.bvid);
                            SmartDialog.showToast(res['msg']);
                          },
                          value: 'pause',
                          height: 35,
                          child: const Row(
                            children: [
                              Icon(Icons.watch_later_outlined, size: 16),
                              SizedBox(width: 6),
                              Text('稍后再看', style: TextStyle(fontSize: 13))
                            ],
                          ),
                        ),
                      PopupMenuItem<String>(
                        onTap: () => ctr!.delHistory(
                            videoItem.kid, videoItem.history.business),
                        value: 'pause',
                        height: 35,
                        child: const Row(
                          children: [
                            Icon(Icons.close_outlined, size: 16),
                            SizedBox(width: 6),
                            Text('删除记录', style: TextStyle(fontSize: 13))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

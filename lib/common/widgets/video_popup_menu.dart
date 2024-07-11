import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../http/user.dart';
import '../../http/video.dart';
import '../../models/home/rcmd/result.dart';
import '../../pages/mine/controller.dart';
import '../../utils/storage.dart';

class VideoPopupMenu extends StatelessWidget {
  final double? size;
  final double? iconSize;
  final dynamic videoItem;
  final double menuItemHeight = 45;

  const VideoPopupMenu({
    Key? key,
    required this.size,
    required this.iconSize,
    required this.videoItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.more_vert_outlined,
          color: Theme.of(context).colorScheme.outline,
          size: iconSize,
        ),
        position: PopupMenuPosition.under,
        onSelected: (String type) {},
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            onTap: () async {
              var res =
                  await UserHttp.toViewLater(bvid: videoItem.bvid as String);
              SmartDialog.showToast(res['msg']);
            },
            value: 'pause',
            height: menuItemHeight,
            child: Row(
              children: [
                Icon(MdiIcons.clockTimeEightOutline, size: 16),
                const SizedBox(width: 6),
                const Text('稍后再看', style: TextStyle(fontSize: 13))
              ],
            ),
          ),
          PopupMenuItem<String>(
            onTap: () async {
              Get.toNamed('/member?mid=${videoItem.owner.mid}', arguments: {
                // 'face': videoItem.owner.face,
                'heroTag': '${videoItem.owner.mid}',
              });
            },
            value: 'visit',
            height: menuItemHeight,
            child: Row(
              children: [
                Icon(MdiIcons.accountCircleOutline, size: 16),
                const SizedBox(width: 6),
                Text('访问：${videoItem.owner.name}',
                    style: const TextStyle(fontSize: 13))
              ],
            ),
          ),
          // 不感兴趣
          PopupMenuItem<String>(
            onTap: () async {
              String? accessKey = GStorage.localCache
                  .get(LocalCacheKey.accessKey, defaultValue: {})['value'];
              if (accessKey == null || accessKey == "") {
                SmartDialog.showToast("请退出账号后重新登录");
                return;
              }
              if (videoItem is RecVideoItemAppModel) {
                RecVideoItemAppModel v = videoItem as RecVideoItemAppModel;
                ThreePoint? tp = v.threePoint;
                if (tp == null) {
                  SmartDialog.showToast("未能获取threePoint");
                  return;
                }
                if (tp.dislikeReasons == null && tp.feedbacks == null) {
                  SmartDialog.showToast("未能获取dislikeReasons或feedbacks");
                  return;
                }
                Widget actionButton(DislikeReason? r, FeedbackReason? f) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 0.0),
                    ),
                    onPressed: () async {
                      SmartDialog.showLoading(msg: '正在提交');
                      var res = await VideoHttp.feedDislike(
                        reasonId: r?.id,
                        feedbackId: f?.id,
                        id: v.param!,
                        goto: v.goto!,
                      );
                      SmartDialog.dismiss();
                      SmartDialog.showToast(
                          res['status'] ? (r?.toast ?? f?.toast) : res['msg']);
                      Get.back();
                    },
                    child: Text(r?.name ?? f?.name ?? '未知'),
                  );
                }

                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('请选择'),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (tp.dislikeReasons != null)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('我不想看'),
                              ),
                            if (tp.dislikeReasons != null)
                              Wrap(
                                spacing: 5.0,
                                runSpacing: 2.0,
                                children: tp.dislikeReasons!.map((item) {
                                  return actionButton(item, null);
                                }).toList(),
                              ),
                            if (tp.feedbacks != null)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('反馈'),
                              ),
                            if (tp.feedbacks != null)
                              Wrap(
                                spacing: 5.0,
                                runSpacing: 2.0,
                                children: tp.feedbacks!.map((item) {
                                  return actionButton(null, item);
                                }).toList(),
                              ),
                            //分割线
                            const Divider(),
                            ElevatedButton(
                              onPressed: () async {
                                SmartDialog.showLoading(msg: '正在提交');
                                var res = await VideoHttp.feedDislikeCancel(
                                  // reasonId: r?.id,
                                  // feedbackId: f?.id,
                                  id: v.param!,
                                  goto: v.goto!,
                                );
                                SmartDialog.dismiss();
                                SmartDialog.showToast(
                                    res['status'] ? "成功" : res['msg']);
                                Get.back();
                              },
                              child: const Text("撤销"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('点踩该视频？'),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 5),
                            const Text("web端暂不支持精细选择"),
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 5.0,
                              runSpacing: 2.0,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    SmartDialog.showLoading(msg: '正在提交');
                                    var res = await VideoHttp.dislikeVideo(
                                        bvid: videoItem.bvid as String,
                                        type: true);
                                    SmartDialog.dismiss();
                                    SmartDialog.showToast(
                                        res['status'] ? "点踩成功" : res['msg']);
                                    Get.back();
                                  },
                                  child: const Text("点踩"),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    SmartDialog.showLoading(msg: '正在提交');
                                    var res = await VideoHttp.dislikeVideo(
                                        bvid: videoItem.bvid as String,
                                        type: false);
                                    SmartDialog.dismiss();
                                    SmartDialog.showToast(
                                        res['status'] ? "取消踩" : res['msg']);
                                    Get.back();
                                  },
                                  child: const Text("撤销"),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
            value: 'dislike',
            height: menuItemHeight,
            child: Row(
              children: [
                Icon(MdiIcons.thumbDownOutline, size: 16),
                const SizedBox(width: 6),
                const Text('不感兴趣', style: TextStyle(fontSize: 13))
              ],
            ),
          ),
          PopupMenuItem<String>(
            onTap: () async {
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('提示'),
                    content: Text(
                        '确定拉黑:${videoItem.owner.name}(${videoItem.owner.mid})?'
                        '\n\n注：被拉黑的Up可以在隐私设置-黑名单管理中解除'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          '点错了',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          var res = await VideoHttp.relationMod(
                            mid: videoItem.owner.mid,
                            act: 5,
                            reSrc: 11,
                          );
                          List<int> blackMidsList = GStorage.localCache
                              .get(LocalCacheKey.blackMidsList,
                                  defaultValue: [-1])
                              .map<int>((i) => i as int)
                              .toList();
                          blackMidsList.insert(0, videoItem.owner.mid);
                          GStorage.localCache
                              .put(LocalCacheKey.blackMidsList, blackMidsList);
                          Get.back();
                          SmartDialog.showToast(res['msg'] ?? '成功');
                        },
                        child: const Text('确认'),
                      )
                    ],
                  );
                },
              );
            },
            value: 'block',
            height: menuItemHeight,
            child: Row(
              children: [
                Icon(MdiIcons.cancel, size: 16),
                const SizedBox(width: 6),
                Text('拉黑：${videoItem.owner.name}',
                    style: const TextStyle(fontSize: 13))
              ],
            ),
          ),
          // PopupMenuItem<String>(
          //   onTap: () async {
          //     SmartDialog.showToast("还没做");
          //   },
          //   value: 'anonymize',
          //   height: menuItemHeight,
          //   child: const Row(
          //     children: [
          //       Icon(Icons.visibility_off_outlined, size: 16),
          //       SizedBox(width: 6),
          //       Text('无痕播放',
          //           style: TextStyle(fontSize: 13))
          //     ],
          //   ),
          // ),
          PopupMenuItem<String>(
            onTap: () {
              MineController.onChangeAnonymity(context);
            },
            value: 'anonymous',
            height: menuItemHeight,
            child: Row(
              children: [
                Icon(
                  MineController.anonymity
                      ? MdiIcons.incognitoOff
                      : MdiIcons.incognito,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text("${MineController.anonymity ? '退出' : '进入'}无痕模式",
                    style: const TextStyle(fontSize: 13))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

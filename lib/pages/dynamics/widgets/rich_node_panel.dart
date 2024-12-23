import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/widgets/network_img_layer.dart';
import 'package:PiliPalaX/http/search.dart';
import 'package:PiliPalaX/utils/app_scheme.dart';

import '../../../models/dynamics/result.dart';

// 富文本
InlineSpan? richNode(item, context) {
    TextStyle authorStyle =
        TextStyle(color: Theme.of(context).colorScheme.primary);
    List<InlineSpan> spanChildren = [];

    List<RichTextNodeItem>? richTextNodes;
    if (item.modules.moduleDynamic.desc != null) {
      richTextNodes = item.modules.moduleDynamic.desc.richTextNodes;
    } else if (item.modules.moduleDynamic.major != null) {
      // 动态页面 richTextNodes 层级可能与主页动态层级不同
      richTextNodes =
          item.modules.moduleDynamic.major.opus?.summary?.richTextNodes;
      if (item.modules.moduleDynamic.major.opus?.title != null) {
        spanChildren.add(
          TextSpan(
            text: item.modules.moduleDynamic.major.opus.title + '\n',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        );
      }
    }
    if (richTextNodes == null || richTextNodes.isEmpty) {
      return null;
    } else {
      for (var i in richTextNodes) {
        /// fix 渲染专栏时内容会重复
        // if (item.modules.moduleDynamic.major.opus.title == null &&
        //     i.type == 'RICH_TEXT_NODE_TYPE_TEXT') {
        if (i.type == 'RICH_TEXT_NODE_TYPE_TEXT') {
          spanChildren.add(
              TextSpan(text: i.origText, style: const TextStyle(height: 1.65)));
        }
        // @用户
        if (i.type == 'RICH_TEXT_NODE_TYPE_AT') {
          spanChildren.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => Get.toNamed('/member?mid=${i.rid}',
                        arguments: {'face': null}),
                    child: Text(
                      ' ${i.text}',
                      style: authorStyle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        // 话题
        if (i.type == 'RICH_TEXT_NODE_TYPE_TOPIC') {
          spanChildren.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  '${i.origText}',
                  style: authorStyle,
                ),
              ),
            ),
          );
        }
        // 网页链接
        if (i.type == 'RICH_TEXT_NODE_TYPE_WEB') {
          spanChildren.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.link,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
          spanChildren.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {
                  String? url = i.origText;
                  if (url == null) {
                    SmartDialog.showToast('未获取到链接');
                    return;
                  }
                  if (url.startsWith('//')) {
                    url = url.replaceFirst('//', 'https://');
                    PiliScheme.routePush(Uri.parse(url));
                    return;
                  }
                  Get.toNamed(
                    '/webview',
                    parameters: {
                      'url': url.startsWith('//')
                          ? "https://${url.split('//').last}"
                          : url,
                      'type': 'url',
                      'pageTitle': ''
                    },
                  );
                },
                child: Text(
                  i.text ?? "",
                  style: authorStyle,
                ),
              ),
            ),
          );
        }
        // 投票
        if (i.type == 'RICH_TEXT_NODE_TYPE_VOTE') {
          spanChildren.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {
                  try {
                    String dynamicId = item.basic['comment_id_str'];
                    Get.toNamed(
                      '/webview',
                      parameters: {
                        'url':
                            'https://t.bilibili.com/vote/h5/index/#/result?vote_id=${i.rid}&dynamic_id=$dynamicId&isWeb=1',
                        'type': 'vote',
                        'pageTitle': '投票'
                      },
                    );
                  } catch (_) {}
                },
                child: Text(
                  '投票：${i.text}',
                  style: authorStyle,
                ),
              ),
            ),
          );
        }
        // 表情
        if (i.type == 'RICH_TEXT_NODE_TYPE_EMOJI' && i.emoji != null) {
          spanChildren.add(
            WidgetSpan(
              child: NetworkImgLayer(
                src: i.emoji!.iconUrl,
                type: 'emote',
                width: (i.emoji!.size ?? 1) * 20,
                height: (i.emoji!.size ?? 1) * 20,
              ),
            ),
          );
        }
        // 抽奖
        if (i.type == 'RICH_TEXT_NODE_TYPE_LOTTERY') {
          spanChildren.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.redeem_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
          spanChildren.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  '${i.origText} ',
                  style: authorStyle,
                ),
              ),
            ),
          );
        }

        /// TODO 商品
        if (i.type == 'RICH_TEXT_NODE_TYPE_GOODS') {
          spanChildren.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
          spanChildren.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  '${i.text} ',
                  style: authorStyle,
                ),
              ),
            ),
          );
        }
        // 投稿
        if (i.type == 'RICH_TEXT_NODE_TYPE_BV') {
          spanChildren.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.play_circle_outline_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
          spanChildren.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () async {
                  try {
                    int cid = await SearchHttp.ab2c(bvid: i.rid);
                    Get.toNamed('/video?bvid=${i.rid}&cid=$cid',
                        arguments: {'pic': null, 'heroTag': i.rid});
                  } catch (err) {
                    SmartDialog.showToast(err.toString());
                  }
                },
                child: Text(
                  '${i.text} ',
                  style: authorStyle,
                ),
              ),
            ),
          );
        }
      }
      // if (contentType == 'major' &&
      //     item.modules.moduleDynamic.major.opus.pics.isNotEmpty) {
      //   // 图片可能跟其他widget重复渲染
      //   List<OpusPicsModel> pics = item.modules.moduleDynamic.major.opus.pics;
      //   int len = pics.length;
      //   List<String> picList = [];

      //   if (len == 1) {
      //     OpusPicsModel pictureItem = pics.first;
      //     picList.add(pictureItem.url!);
      //     spanChildren.add(const TextSpan(text: '\n'));
      //     spanChildren.add(
      //       WidgetSpan(
      //         child: LayoutBuilder(
      //           builder: (context, BoxConstraints box) {
      //             return GestureDetector(
      //               onTap: () {
      //                 showDialog(
      //                   useSafeArea: false,
      //                   context: context,
      //                   builder: (context) {
      //                     return ImagePreview(initialPage: 0, imgList: picList);
      //                   },
      //                 );
      //               },
      //               child: Padding(
      //                 padding: const EdgeInsets.only(top: 4),
      //                 child: NetworkImgLayer(
      //                   src: pictureItem.url,
      //                   width: box.maxWidth / 2,
      //                   height: box.maxWidth *
      //                       0.5 *
      //                       (pictureItem.height != null &&
      //                               pictureItem.width != null
      //                           ? pictureItem.height! / pictureItem.width!
      //                           : 1),
      //                 ),
      //               ),
      //             );
      //           },
      //         ),
      //       ),
      //     );
      //   }
      // if (len > 1) {
      //   List<Widget> list = [];
      //   for (var i = 0; i < len; i++) {
      //     picList.add(pics[i].url!);
      //     list.add(
      //       LayoutBuilder(
      //         builder: (context, BoxConstraints box) {
      //           return GestureDetector(
      //             onTap: () {
      //               showDialog(
      //                 useSafeArea: false,
      //                 context: context,
      //                 builder: (context) {
      //                   return ImagePreview(initialPage: i, imgList: picList);
      //                 },
      //               );
      //             },
      //             child: NetworkImgLayer(
      //               src: pics[i].url,
      //               width: box.maxWidth,
      //               height: box.maxWidth,
      //             ),
      //           );
      //         },
      //       ),
      //     );
      //   }
      //   spanChildren.add(
      //     WidgetSpan(
      //       child: LayoutBuilder(
      //         builder: (context, BoxConstraints box) {
      //           double maxWidth = box.maxWidth;
      //           double crossCount = len < 3 ? 2 : 3;
      //           double height = maxWidth /
      //                   crossCount *
      //                   (len % crossCount == 0
      //                       ? len ~/ crossCount
      //                       : len ~/ crossCount + 1) +
      //               6;
      //           return Container(
      //             padding: const EdgeInsets.only(top: 6),
      //             height: height,
      //             child: GridView.count(
      //               padding: EdgeInsets.zero,
      //               physics: const NeverScrollableScrollPhysics(),
      //               crossAxisCount: crossCount.toInt(),
      //               mainAxisSpacing: 4.0,
      //               crossAxisSpacing: 4.0,
      //               childAspectRatio: 1,
      //               children: list,
      //             ),
      //           );
      //         },
      //       ),
      //     ),
      //   );
      // }
      // spanChildren.add(
      //   WidgetSpan(
      //     child: NetworkImgLayer(
      //       src: pics.first.url,
      //       type: 'emote',
      //       width: 100,
      //       height: 200,
      //     ),
      //   ),
      // );
      // }
      return TextSpan(
        children: spanChildren,
      );
    }
  // } catch (err) {
  //   print('❌rich_node_panel err: $err');
  //   return spacer;
  // }
}


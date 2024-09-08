import 'package:PiliPalaX/http/video.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/common/widgets/badge.dart';
import 'package:PiliPalaX/common/widgets/network_img_layer.dart';
import 'package:PiliPalaX/models/common/reply_type.dart';
import 'package:PiliPalaX/models/video/reply/item.dart';
import 'package:PiliPalaX/pages/preview/index.dart';
import 'package:PiliPalaX/pages/video/detail/index.dart';
import 'package:PiliPalaX/pages/video/detail/reply_new/index.dart';
import 'package:PiliPalaX/utils/feed_back.dart';
import 'package:PiliPalaX/utils/storage.dart';
import 'package:PiliPalaX/utils/url_utils.dart';
import 'package:PiliPalaX/utils/utils.dart';
import '../../../../../utils/app_scheme.dart';
import 'zan.dart';

Box setting = GStorage.setting;

class ReplyItem extends StatelessWidget {
  const ReplyItem({
    this.replyItem,
    this.addReply,
    this.replyLevel,
    this.showReplyRow = true,
    this.replyReply,
    this.replyType,
    super.key,
  });
  final ReplyItemModel? replyItem;
  final Function? addReply;
  final String? replyLevel;
  final bool? showReplyRow;
  final Function? replyReply;
  final ReplyType? replyType;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        // 点击整个评论区 评论详情/回复
        onTap: () {
          feedBack();
          if (replyReply != null) {
            replyReply!(replyItem);
          }
        },
        onLongPress: () {
          feedBack();
          showModalBottomSheet(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (context) {
              return MorePanel(item: replyItem!);
            },
          );
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 8, 5),
              child: content(context),
            ),
            Divider(
              indent: 55,
              endIndent: 15,
              height: 0.3,
              color: Theme.of(context)
                  .colorScheme
                  .onInverseSurface
                  .withOpacity(0.5),
            )
          ],
        ),
      ),
    );
  }

  Widget lfAvtar(BuildContext context, String heroTag) {
    return Stack(
      children: [
        Hero(
          tag: heroTag,
          child: NetworkImgLayer(
            src: replyItem!.member!.avatar,
            width: 34,
            height: 34,
            type: 'avatar',
          ),
        ),
        if (replyItem!.member!.vip!['vipStatus'] > 0)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                //borderRadius: BorderRadius.circular(7),
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.background,
              ),
              child: Image.asset(
                'assets/images/big-vip.png',
                height: 14,
                semanticLabel: "大会员",
              ),
            ),
          ),
        //https://www.bilibili.com/blackboard/activity-whPrHsYJ2.html
        if (replyItem!.member!.officialVerify != null &&
            replyItem!.member!.officialVerify!['type'] == 0)
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(8),
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surface,
              ),
              child: const Icon(
                Icons.offline_bolt,
                color: Colors.yellow,
                size: 14,
                semanticLabel: "认证个人",
              ),
            ),
          ),
        if (replyItem!.member!.officialVerify != null &&
            replyItem!.member!.officialVerify!['type'] == 1)
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(8),
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surface,
              ),
              child: const Icon(
                Icons.offline_bolt,
                color: Colors.lightBlueAccent,
                size: 14,
                semanticLabel: "认证机构",
              ),
            ),
          ),
      ],
    );
  }

  Widget content(BuildContext context) {
    if (replyItem?.member == null) return const SizedBox();
    final String heroTag = Utils.makeHeroTag(replyItem!.mid);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        /// fix Stack内GestureDetector  onTap无效
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            feedBack();
            Get.toNamed('/member?mid=${replyItem!.mid}', arguments: {
              'face': replyItem!.member!.avatar!,
              'heroTag': heroTag
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              lfAvtar(context, heroTag),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        replyItem!.member!.uname!,
                        style: TextStyle(
                          color: (replyItem!.member!.vip!['vipStatus'] > 0 &&
                                  replyItem!.member!.vip!['vipType'] == 2)
                              ? const Color.fromARGB(255, 251, 100, 163)
                              : Theme.of(context).colorScheme.outline,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Image.asset(
                        'assets/images/lv/lv${replyItem!.member!.level}.png',
                        height: 11,
                        semanticLabel: "等级：${replyItem!.member!.level}",
                      ),
                      const SizedBox(width: 6),
                      if (replyItem!.isUp!)
                        const PBadge(
                          text: 'UP',
                          size: 'small',
                          stack: 'normal',
                          fs: 9,
                        ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        Utils.dateFormat(replyItem!.ctime),
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.labelSmall!.fontSize,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      if (replyItem!.replyControl != null &&
                          replyItem!.replyControl!.location != '')
                        Text(
                          ' • ${replyItem!.replyControl!.location!}',
                          style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .fontSize,
                              color: Theme.of(context).colorScheme.outline),
                        ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
        // title
        Container(
          margin: const EdgeInsets.only(top: 10, left: 45, right: 6, bottom: 4),
          child: Semantics(
              label: replyItem?.content?.message ?? "",
              // excludeSemantics: true,
              child: Text.rich(
                style: TextStyle(
                    height: 1.75,
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize),
                maxLines:
                    replyItem!.content!.isText! && replyLevel == '1' ? 6 : 999,
                overflow: TextOverflow.ellipsis,
                TextSpan(
                  children: [
                    if (replyItem!.isTop!) ...[
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: PBadge(
                          text: 'TOP',
                          size: 'small',
                          stack: 'normal',
                          type: 'line',
                          fs: 9,
                          semanticsLabel: '置顶',
                        ),
                      ),
                      const TextSpan(text: ' '),
                    ],
                    buildContent(context, replyItem!, replyReply, null),
                  ],
                ),
              )),
        ),
        // 操作区域
        buttonAction(context, replyItem!.replyControl),
        // 一楼的评论
        if ((replyItem!.replyControl!.isShow! ||
                replyItem!.replies!.isNotEmpty ||
                replyItem!.replyControl!.entryText != null) &&
            showReplyRow!) ...[
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 12),
            child: ReplyItemRow(
              replies: replyItem!.replies,
              replyControl: replyItem!.replyControl,
              // f_rpid: replyItem!.rpid,
              replyItem: replyItem,
              replyReply: replyReply,
            ),
          ),
        ],
      ],
    );
  }

  // 感谢、回复、复制
  Widget buttonAction(BuildContext context, replyControl) {
    return Row(
      children: <Widget>[
        const SizedBox(width: 32),
        SizedBox(
          height: 32,
          child: TextButton(
            onPressed: () {
              feedBack();
              showModalBottomSheet(
                isDismissible: false,
                context: context,
                isScrollControlled: true,
                builder: (builder) {
                  return VideoReplyNewDialog(
                    oid: replyItem!.oid,
                    root: replyItem!.rpid,
                    parent: replyItem!.rpid,
                    replyType: replyType,
                    replyItem: replyItem,
                  );
                },
              ).then((value) => {
                    // 完成评论，数据添加
                    if (value != null &&
                        value['data'] != null &&
                        addReply != null)
                      {
                        addReply?.call(value['data'])
                        // replyControl.replies.add(value['data']),
                      }
                  });
            },
            child: Row(children: [
              Icon(Icons.reply,
                  size: 18,
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.8)),
              const SizedBox(width: 3),
              Text(
                '回复',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 2),
        if (replyItem!.upAction!.like!) ...[
          Text(
            'up主觉得很赞',
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: Theme.of(context).textTheme.labelMedium!.fontSize),
          ),
          const SizedBox(width: 2),
        ],
        if (replyItem!.cardLabel!.isNotEmpty &&
            replyItem!.cardLabel!.contains('热评'))
          Text(
            '热评',
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: Theme.of(context).textTheme.labelMedium!.fontSize),
          ),
        const Spacer(),
        ZanButton(replyItem: replyItem, replyType: replyType),
        const SizedBox(width: 5)
      ],
    );
  }
}

// ignore: must_be_immutable
class ReplyItemRow extends StatelessWidget {
  ReplyItemRow({
    super.key,
    this.replies,
    this.replyControl,
    // this.f_rpid,
    this.replyItem,
    this.replyReply,
  });
  final List<ReplyItemModel>? replies;
  ReplyControl? replyControl;
  // int? f_rpid;
  ReplyItemModel? replyItem;
  Function? replyReply;

  @override
  Widget build(BuildContext context) {
    final int extraRow = replyControl?.isShow == true ||
            (replyControl?.entryText != null && replies!.isEmpty)
        ? 1
        : 0;
    return Container(
      margin: const EdgeInsets.only(left: 42, right: 4, top: 0),
      child: Material(
        color: Theme.of(context).colorScheme.onInverseSurface,
        borderRadius: BorderRadius.circular(6),
        clipBehavior: Clip.hardEdge,
        animationDuration: Duration.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (replies!.isNotEmpty)
              for (int i = 0; i < replies!.length; i++) ...[
                InkWell(
                  // 一楼点击评论展开评论详情
                  onTap: () => replyReply!(replyItem),
                  onLongPress: () {
                    feedBack();
                    showModalBottomSheet(
                      context: context,
                      useRootNavigator: true,
                      isScrollControlled: true,
                      builder: (context) {
                        return MorePanel(item: replies![i]);
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      8,
                      i == 0 && (extraRow == 1 || replies!.length > 1) ? 8 : 4,
                      8,
                      i == 0 && (extraRow == 1 || replies!.length > 1) ? 4 : 6,
                    ),
                    child: Semantics(
                        label:
                            '${replies![i].member!.uname} ${replies![i].content!.message}',
                        excludeSemantics: true,
                        child: Text.rich(
                          style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .fontSize,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.85),
                              height: 1.6),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${replies![i].member!.uname}',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.85),
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    feedBack();
                                    final String heroTag = Utils.makeHeroTag(
                                        replies![i].member!.mid);
                                    Get.toNamed(
                                        '/member?mid=${replies![i].member!.mid}',
                                        arguments: {
                                          'face': replies![i].member!.avatar,
                                          'heroTag': heroTag
                                        });
                                  },
                              ),
                              if (replies![i].isUp!) ...[
                                const TextSpan(text: ' '),
                                const WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: PBadge(
                                    text: 'UP',
                                    size: 'small',
                                    stack: 'normal',
                                    fs: 9,
                                  ),
                                ),
                                const TextSpan(text: ' '),
                              ],
                              TextSpan(
                                  text: replies![i].root == replies![i].parent
                                      ? ': '
                                      : replies![i].isUp!
                                          ? ''
                                          : ' '),
                              buildContent(
                                context,
                                replies![i],
                                replyReply,
                                replyItem,
                              ),
                            ],
                          ),
                        )),
                  ),
                )
              ],
            if (extraRow == 1)
              InkWell(
                // 一楼点击【共xx条回复】展开评论详情
                onTap: () => replyReply!(replyItem),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(8, 5, 8, 8),
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.labelMedium!.fontSize,
                      ),
                      children: [
                        if (replyControl!.upReply!)
                          TextSpan(
                              text: 'up主等人 ',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.85))),
                        TextSpan(
                          text: replyControl!.entryText!,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.85),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

InlineSpan buildContent(
    BuildContext context, replyItem, replyReply, fReplyItem) {
  final String routePath = Get.currentRoute;
  bool isVideoPage = routePath.startsWith('/video');

  // replyItem 当前回复内容
  // replyReply 查看二楼回复（回复详情）回调
  // fReplyItem 父级回复内容，用作二楼回复（回复详情）展示
  final content = replyItem.content;
  final List<InlineSpan> spanChildren = <InlineSpan>[];

  // 投票
  if (content.vote.isNotEmpty) {
    content.message.splitMapJoin(RegExp(r"\{vote:\d+?\}"),
        onMatch: (Match match) {
      // String matchStr = match[0]!;
      spanChildren.add(
        TextSpan(
          text: '投票: ${content.vote['title']}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => Get.toNamed(
                  '/webview',
                  parameters: {
                    'url': content.vote['url'],
                    'type': 'vote',
                    'pageTitle': content.vote['title'],
                  },
                ),
        ),
      );
      return '';
    }, onNonMatch: (String str) {
      return str;
    });
    content.message = content.message.replaceAll(RegExp(r"\{vote:\d+?\}"), "");
  }
  content.message = content.message
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&nbsp;', ' ');
  // 构建正则表达式
  final List<String> specialTokens = [
    ...content.emote.keys,
    ...content.topicsMeta?.keys?.map((e) => '#$e#') ?? [],
    ...content.atNameToMid.keys.map((e) => '@$e'),
  ];
  List<String> jumpUrlKeysList = content.jumpUrl.keys.map<String>((String e) {
    return e.replaceAllMapped(
        RegExp(r'[?+*]'), (match) => '\\${match.group(0)}');
  }).toList();
  specialTokens.sort((a, b) => b.length.compareTo(a.length));
  String patternStr = specialTokens.map(RegExp.escape).join('|');
  if (patternStr.isNotEmpty) {
    patternStr += "|";
  }
  patternStr += r'(\b(?:\d+[:：])?[0-5]?[0-9][:：][0-5]?[0-9]\b)';
  if (jumpUrlKeysList.isNotEmpty) {
    patternStr += '|${jumpUrlKeysList.map(RegExp.escape).join('|')}';
  }
  final RegExp pattern = RegExp(patternStr);
  List<String> matchedStrs = [];
  void addPlainTextSpan(str) {
    spanChildren.add(TextSpan(
      text: str,
    ));
    // TextSpan(
    //
    //     text: str,
    //     recognizer: TapGestureRecognizer()
    //       ..onTap = () => replyReply
    //           ?.call(replyItem.root == 0 ? replyItem : fReplyItem)))));
  }

  // 分割文本并处理每个部分
  content.message.splitMapJoin(
    pattern,
    onMatch: (Match match) {
      String matchStr = match[0]!;
      if (content.emote.containsKey(matchStr)) {
        // 处理表情
        final int size = content.emote[matchStr]['meta']['size'];
        spanChildren.add(WidgetSpan(
          child: ExcludeSemantics(
              child: NetworkImgLayer(
            src: content.emote[matchStr]['url'],
            type: 'emote',
            width: size * 20,
            height: size * 20,
            semanticsLabel: matchStr,
          )),
        ));
      } else if (matchStr.startsWith("@") &&
          content.atNameToMid.containsKey(matchStr.substring(1))) {
        // 处理@用户
        final String userName = matchStr.substring(1);
        final int userId = content.atNameToMid[userName];
        spanChildren.add(
          TextSpan(
            text: matchStr,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                final String heroTag = Utils.makeHeroTag(userId);
                Get.toNamed(
                  '/member?mid=$userId',
                  arguments: {'face': '', 'heroTag': heroTag},
                );
              },
          ),
        );
      } else if (RegExp(r'^\b(?:\d+[:：])?[0-5]?[0-9][:：][0-5]?[0-9]\b$')
          .hasMatch(matchStr)) {
        matchStr = matchStr.replaceAll('：', ':');
        spanChildren.add(
          TextSpan(
            text: ' $matchStr ',
            style: isVideoPage
                ? TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // 跳转到指定位置
                if (isVideoPage) {
                  try {
                    SmartDialog.showToast('跳转至：$matchStr');
                    Get.find<VideoDetailController>(
                            tag: Get.arguments['heroTag'])
                        .plPlayerController
                        .seekTo(Duration(seconds: Utils.duration(matchStr)),
                            type: 'slider');
                  } catch (e) {
                    SmartDialog.showToast('跳转失败: $e');
                  }
                }
              },
          ),
        );
      } else {
        String appUrlSchema = '';
        final bool enableWordRe = setting.get(SettingBoxKey.enableWordRe,
            defaultValue: false) as bool;
        if (content.jumpUrl[matchStr] != null &&
            !matchedStrs.contains(matchStr)) {
          appUrlSchema = content.jumpUrl[matchStr]['app_url_schema'];
          if (appUrlSchema.startsWith('bilibili://search') && !enableWordRe) {
            addPlainTextSpan(matchStr);
            return "";
          }
          spanChildren.addAll(
            [
              if (content.jumpUrl[matchStr]?['prefix_icon'] != null) ...[
                WidgetSpan(
                  child: Image.network(
                    content.jumpUrl[matchStr]['prefix_icon'],
                    height: 19,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              ],
              TextSpan(
                text: content.jumpUrl[matchStr]['title'],
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final String title = content.jumpUrl[matchStr]['title'];
                    if (appUrlSchema == '') {
                      if (matchStr.startsWith('BV')) {
                        UrlUtils.matchUrlPush(
                          matchStr,
                          title,
                          '',
                        );
                      } else if (RegExp(r'^[Cc][Vv][0-9]+$')
                          .hasMatch(matchStr)) {
                        Get.toNamed('/htmlRender', parameters: {
                          'url': 'https://www.bilibili.com/read/$matchStr',
                          'title': title,
                          'id': matchStr.substring(2),
                          'dynamicType': 'read'
                        });
                      } else {
                        final String redirectUrl =
                            await UrlUtils.parseRedirectUrl(matchStr);
                        // if (redirectUrl == matchStr) {
                        //   Clipboard.setData(ClipboardData(text: matchStr));
                        //   SmartDialog.showToast('地址可能有误');
                        //   return;
                        // }
                        Uri uri = Uri.parse(redirectUrl);
                        PiliScheme.routePush(uri);
                        // final String pathSegment = Uri.parse(redirectUrl).path;
                        // final String lastPathSegment =
                        //     pathSegment.split('/').last;
                        // if (lastPathSegment.startsWith('BV')) {
                        //   UrlUtils.matchUrlPush(
                        //     lastPathSegment,
                        //     title,
                        //     redirectUrl,
                        //   );
                        // } else {
                        //   Get.toNamed(
                        //     '/webview',
                        //     parameters: {
                        //       'url': redirectUrl,
                        //       'type': 'url',
                        //       'pageTitle': title
                        //     },
                        //   );
                        // }
                      }
                    } else {
                      if (appUrlSchema.startsWith('bilibili://search')) {
                        Get.toNamed('/searchResult',
                            parameters: {'keyword': title});
                      } else if (matchStr.startsWith('https://b23.tv')) {
                        final String redirectUrl =
                            await UrlUtils.parseRedirectUrl(matchStr);
                        final String pathSegment = Uri.parse(redirectUrl).path;
                        final String lastPathSegment =
                            pathSegment.split('/').last;
                        if (lastPathSegment.startsWith('BV')) {
                          UrlUtils.matchUrlPush(
                            lastPathSegment,
                            title,
                            redirectUrl,
                          );
                        } else {
                          Get.toNamed(
                            '/webview',
                            parameters: {
                              'url': redirectUrl,
                              'type': 'url',
                              'pageTitle': title
                            },
                          );
                        }
                      } else {
                        Get.toNamed(
                          '/webview',
                          parameters: {
                            'url': matchStr,
                            'type': 'url',
                            'pageTitle': title
                          },
                        );
                      }
                    }
                  },
              )
            ],
          );
          // 只显示一次
          matchedStrs.add(matchStr);
        } else if (matchStr.length > 1 &&
            content.topicsMeta[matchStr.substring(1, matchStr.length - 1)] !=
                null) {
          spanChildren.add(
            TextSpan(
              text: matchStr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  final String topic =
                      matchStr.substring(1, matchStr.length - 1);
                  Get.toNamed('/searchResult', parameters: {'keyword': topic});
                },
            ),
          );
        } else {
          addPlainTextSpan(matchStr);
        }
      }
      return '';
    },
    onNonMatch: (String nonMatchStr) {
      addPlainTextSpan(nonMatchStr);
      return nonMatchStr;
    },
  );

  if (content.jumpUrl.keys.isNotEmpty) {
    List<String> unmatchedItems = content.jumpUrl.keys
        .toList()
        .where((item) => !content.message.contains(item))
        .toList();
    if (unmatchedItems.isNotEmpty) {
      for (int i = 0; i < unmatchedItems.length; i++) {
        String patternStr = unmatchedItems[i];
        spanChildren.addAll(
          [
            if (content.jumpUrl[patternStr]?['prefix_icon'] != null) ...[
              WidgetSpan(
                child: Image.network(
                  content.jumpUrl[patternStr]['prefix_icon'],
                  height: 19,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            ],
            TextSpan(
              text: content.jumpUrl[patternStr]['title'],
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Get.toNamed(
                    '/webview',
                    parameters: {
                      'url': patternStr,
                      'type': 'url',
                      'pageTitle': content.jumpUrl[patternStr]['title']
                    },
                  );
                },
            )
          ],
        );
      }
    }
  }
  // 图片渲染
  if (content.pictures.isNotEmpty) {
    final List<String> picList = <String>[];
    final int len = content.pictures.length;
    spanChildren.add(const TextSpan(text: '\n'));
    if (len == 1) {
      Map pictureItem = content.pictures.first;
      picList.add(pictureItem['img_src']);
      spanChildren.add(
        WidgetSpan(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) {
              double maxHeight = box.maxWidth * 0.6; // 设置最大高度
              // double width = (box.maxWidth / 2).truncateToDouble();
              double height = 100;
              try {
                height = ((box.maxWidth /
                        2 *
                        pictureItem['img_height'] /
                        pictureItem['img_width']))
                    .truncateToDouble();
              } catch (_) {}

              return GestureDetector(
                onTap: () {
                  showDialog(
                    useSafeArea: false,
                    context: context,
                    builder: (BuildContext context) {
                      return ImagePreview(initialPage: 0, imgList: picList);
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 4),
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  width: box.maxWidth / 2,
                  height: height,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: NetworkImgLayer(
                          src: pictureItem['img_src'],
                          width: box.maxWidth / 2,
                          height: height,
                          semanticsLabel: '图片1，共1张',
                        ),
                      ),
                      height > Get.size.height * 0.9
                          ? const PBadge(
                              text: '长图',
                              right: 8,
                              bottom: 8,
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else if (len > 1) {
      List<Widget> list = [];
      for (var i = 0; i < len; i++) {
        picList.add(content.pictures[i]['img_src']);
        list.add(
          LayoutBuilder(
            builder: (context, BoxConstraints box) {
              return GestureDetector(
                onTap: () {
                  showDialog(
                    useSafeArea: false,
                    context: context,
                    builder: (context) {
                      return ImagePreview(initialPage: i, imgList: picList);
                    },
                  );
                },
                child: NetworkImgLayer(
                  src: content.pictures[i]['img_src'],
                  width: box.maxWidth,
                  height: box.maxWidth,
                  origAspectRatio: content.pictures[i]['img_width'] /
                      content.pictures[i]['img_height'],
                  semanticsLabel: '图片${i + 1}，共$len张',
                ),
              );
            },
          ),
        );
      }
      spanChildren.add(
        WidgetSpan(
          child: Semantics(
              explicitChildNodes: true,
              container: true,
              child: LayoutBuilder(
                builder: (context, BoxConstraints box) {
                  double maxWidth = box.maxWidth;
                  double crossCount = len < 3 ? 2 : 3;
                  double height = maxWidth /
                          crossCount *
                          (len % crossCount == 0
                              ? len ~/ crossCount
                              : len ~/ crossCount + 1) +
                      6;
                  return Container(
                    padding: const EdgeInsets.only(top: 6),
                    height: height,
                    child: GridView.count(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossCount.toInt(),
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                      childAspectRatio: 1,
                      children: list,
                    ),
                  );
                },
              )),
        ),
      );
    }
  }

  // 笔记链接
  if (content.richText.isNotEmpty) {
    spanChildren.add(
      TextSpan(
        text: ' 笔记',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => Get.toNamed(
                '/webview',
                parameters: {
                  'url': content.richText['note']['click_url'],
                  'type': 'note',
                  'pageTitle': '笔记预览'
                },
              ),
      ),
    );
  }
  // spanChildren.add(TextSpan(text: matchMember));
  return TextSpan(children: spanChildren);
}

class MorePanel extends StatelessWidget {
  final ReplyItemModel item;
  const MorePanel({super.key, required this.item});

  Future<dynamic> menuActionHandler(String type) async {
    String message = item.content?.message ?? '';
    switch (type) {
      case 'copyAll':
        await Clipboard.setData(ClipboardData(text: message));
        SmartDialog.showToast('已复制');
        Get.back();
        break;
      case 'copyFreedom':
        Get.back();
        showDialog(
          context: Get.context!,
          builder: (context) {
            return AlertDialog(
              title: const Text('自由复制'),
              content: SelectableText(message),
            );
          },
        );
        break;
      // case 'block':
      //   SmartDialog.showToast('加入黑名单');
      //   break;
      // case 'report':
      //   SmartDialog.showToast('举报');
      //   break;
      case 'delete':
        //弹出确认提示：
        bool? isDelete = await showDialog<bool>(
          context: Get.context!,
          builder: (context) {
            return AlertDialog(
              title: const Text('删除评论（测试）'),
              content:
                  Text('确定尝试删除这条评论吗？\n\n$message\n\n注：只能删除自己的评论，或自己管理的评论区下的评论'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Get.back(result: false);
                  },
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    Get.back(result: true);
                  },
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
        if (isDelete == null || !isDelete) {
          return;
        }
        SmartDialog.showLoading(msg: '删除中...');
        var result = await VideoHttp.replyDel(
            type: item.type!, oid: item.oid!, rpid: item.rpid!);
        SmartDialog.dismiss();
        if (result['status']) {
          SmartDialog.showToast('删除成功，请刷新');
          // Get.back();
        } else {
          SmartDialog.showToast('删除失败, ${result["msg"]}');
        }
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    Color errorColor = Theme.of(context).colorScheme.error;
    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQueryData.fromView(
                      WidgetsBinding.instance.platformDispatcher.views.single)
                  .padding
                  .bottom +
              20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => Get.back(),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            child: Container(
              height: 35,
              padding: const EdgeInsets.only(bottom: 2),
              child: Center(
                child: Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: const BorderRadius.all(Radius.circular(3))),
                ),
              ),
            ),
          ),
          // 已登录用户才显示删除
          if (GStorage.userInfo.get('userInfoCache') != null)
            ListTile(
              onTap: () async => await menuActionHandler('delete'),
              minLeadingWidth: 0,
              leading: Icon(Icons.delete_outlined, color: errorColor, size: 19),
              title: Text('删除',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: errorColor)),
            ),
          ListTile(
            onTap: () async => await menuActionHandler('copyAll'),
            minLeadingWidth: 0,
            leading: const Icon(Icons.copy_all_outlined, size: 19),
            title: Text('复制全部', style: Theme.of(context).textTheme.titleSmall),
          ),
          ListTile(
            onTap: () async => await menuActionHandler('copyFreedom'),
            minLeadingWidth: 0,
            leading: const Icon(Icons.copy_outlined, size: 19),
            title: Text('自由复制', style: Theme.of(context).textTheme.titleSmall),
          ),
          // ListTile(
          //   onTap: () async => await menuActionHandler('block'),
          //   minLeadingWidth: 0,
          //   leading: Icon(Icons.block_outlined, color: errorColor),
          //   title: Text('加入黑名单', style: TextStyle(color: errorColor)),
          // ),
          // ListTile(
          //   onTap: () async => await menuActionHandler('report'),
          //   minLeadingWidth: 0,
          //   leading: Icon(Icons.report_outlined, color: errorColor),
          //   title: Text('举报', style: TextStyle(color: errorColor)),
          // ),
        ],
      ),
    );
  }
}

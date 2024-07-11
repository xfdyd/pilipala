import 'dart:math';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/skeleton/video_reply.dart';
import 'package:PiliPalaX/common/widgets/html_render.dart';
import 'package:PiliPalaX/common/widgets/network_img_layer.dart';
import 'package:PiliPalaX/models/common/reply_type.dart';
import 'package:PiliPalaX/pages/video/detail/reply/widgets/reply_item.dart';
import 'package:PiliPalaX/pages/video/detail/reply_new/index.dart';
import 'package:PiliPalaX/pages/video/detail/reply_reply/index.dart';
import 'package:PiliPalaX/utils/feed_back.dart';

import '../../utils/grid.dart';
import 'controller.dart';

class HtmlRenderPage extends StatefulWidget {
  const HtmlRenderPage({super.key});

  @override
  State<HtmlRenderPage> createState() => _HtmlRenderPageState();
}

class _HtmlRenderPageState extends State<HtmlRenderPage>
    with TickerProviderStateMixin {
  final HtmlRenderController _htmlRenderCtr = Get.put(HtmlRenderController());
  late String title;
  late String id;
  late String url;
  late String dynamicType;
  late int type;
  bool _isFabVisible = true;
  late final Future _futureBuilderFuture;
  late ScrollController scrollController;
  late AnimationController fabAnimationCtr;

  @override
  void initState() {
    super.initState();
    title = Get.parameters['title']!;
    id = Get.parameters['id']!;
    url = Get.parameters['url']!;
    dynamicType = Get.parameters['dynamicType']!;
    type = dynamicType == 'picture' ? 11 : 12;
    _futureBuilderFuture = _htmlRenderCtr.reqHtml(id);
    fabAnimationCtr = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    scrollListener();
  }

  void scrollListener() {
    scrollController = _htmlRenderCtr.scrollController;
    scrollController.addListener(
      () {
        // 分页加载
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 300) {
          EasyThrottle.throttle('replylist', const Duration(seconds: 2), () {
            _htmlRenderCtr.queryReplyList(reqType: 'onLoad');
          });
        }

        // 标题
        // if (scrollController.offset > 55 && !_visibleTitle) {
        //   _visibleTitle = true;
        //   titleStreamC.add(true);
        // } else if (scrollController.offset <= 55 && _visibleTitle) {
        //   _visibleTitle = false;
        //   titleStreamC.add(false);
        // }

        // fab按钮
        final ScrollDirection direction =
            scrollController.position.userScrollDirection;
        if (direction == ScrollDirection.forward) {
          _showFab();
        } else if (direction == ScrollDirection.reverse) {
          _hideFab();
        }
      },
    );
  }

  void _showFab() {
    if (!_isFabVisible) {
      _isFabVisible = true;
      fabAnimationCtr.forward();
    }
  }

  void _hideFab() {
    if (_isFabVisible) {
      _isFabVisible = false;
      fabAnimationCtr.reverse();
    }
  }

  void replyReply(replyItem) {
    int oid = replyItem.oid;
    int rpid = replyItem.rpid!;
    Get.to(
      () => Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          centerTitle: false,
          title: Text(
            '评论详情',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        body: VideoReplyReplyPanel(
          oid: oid,
          rpid: rpid,
          source: 'dynamic',
          replyType: ReplyType.values[type],
          firstFloor: replyItem,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          const SizedBox(width: 4),
          IconButton(
            tooltip: '用内置浏览器打开',
            onPressed: () {
              Get.toNamed('/webview', parameters: {
                'url': url.startsWith('http') ? url : 'https:$url',
                'type': 'url',
                'pageTitle': title,
              });
            },
            icon: const Icon(Icons.open_in_browser_outlined, size: 19),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                onTap: () => {
                  _htmlRenderCtr.reqHtml(id),
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 19),
                    SizedBox(width: 10),
                    Text('刷新'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () => {
                  Get.toNamed('/webview', parameters: {
                    'url': url.startsWith('http') ? url : 'https:$url',
                    'type': 'url',
                    'pageTitle': title,
                  }),
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.open_in_new, size: 19),
                    SizedBox(width: 10),
                    Text('内置浏览器打开'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () => {
                  Clipboard.setData(ClipboardData(text: url)),
                  SmartDialog.showToast('已复制'),
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy_rounded, size: 19),
                    SizedBox(width: 10),
                    Text('复制链接'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () => {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.share_outlined, size: 19),
                    SizedBox(width: 10),
                    Text('分享'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 6)
        ],
      ),
      body: Stack(
        children: [
          OrientationBuilder(builder: (context, orientation) {
            double padding = max(context.width / 2 - Grid.maxRowWidth, 0);
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: SingleChildScrollView(
                controller: orientation == Orientation.portrait
                    ? scrollController
                    : ScrollController(),
                child: Padding(
                    padding: orientation == Orientation.portrait
                        ? EdgeInsets.symmetric(horizontal: padding)
                        : EdgeInsets.only(left: padding / 2),
                    child: FutureBuilder(
                      future: _futureBuilderFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          var data = snapshot.data;
                          // fabAnimationCtr.forward();
                          if (data != null && data['status']) {
                            return Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 12, 12, 8),
                                  child: Row(
                                    children: [
                                      NetworkImgLayer(
                                        width: 40,
                                        height: 40,
                                        type: 'avatar',
                                        src: _htmlRenderCtr.response['avatar']!,
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(_htmlRenderCtr.response['uname'],
                                              style: TextStyle(
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall!
                                                    .fontSize,
                                              )),
                                          Text(
                                            _htmlRenderCtr
                                                .response['updateTime'],
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline,
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall!
                                                  .fontSize,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 8, 12, 8),
                                  child: LayoutBuilder(
                                    builder: (context, boxConstraints) {
                                      return HtmlRender(
                                        htmlContent:
                                            _htmlRenderCtr.response['content'],
                                        constrainedWidth:
                                            boxConstraints.maxWidth,
                                      );
                                    },
                                  ),
                                ),
                                if (orientation == Orientation.portrait) ...[
                                  Divider(
                                      thickness: 8,
                                      color: Theme.of(context)
                                          .dividerColor
                                          .withOpacity(0.05)),
                                  replyHeader(),
                                  replyList(),
                                ]
                              ],
                            );
                          } else {
                            return const Text('error');
                          }
                        } else {
                          // 骨架屏
                          return const SizedBox();
                        }
                      },
                    )),
              )),
              if (orientation == Orientation.landscape) ...[
                VerticalDivider(
                    thickness: 8,
                    color: Theme.of(context).dividerColor.withOpacity(0.05)),
                Expanded(
                    child: SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                            padding: EdgeInsets.only(right: padding / 2),
                            child: Column(
                              children: [
                                replyHeader(),
                                replyList(),
                              ],
                            ))))
              ]
            ]);
          }),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 14,
            right: 14,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 2),
                end: const Offset(0, 0),
              ).animate(CurvedAnimation(
                parent: fabAnimationCtr,
                curve: Curves.easeInOut,
              )),
              child: FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  feedBack();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    isDismissible: false,
                    builder: (BuildContext context) {
                      return VideoReplyNewDialog(
                        oid: _htmlRenderCtr.oid.value,
                        root: 0,
                        parent: 0,
                        replyType: ReplyType.values[type],
                      );
                    },
                  ).then(
                    (value) => {
                      // 完成评论，数据添加
                      if (value != null && value['data'] != null)
                        {
                          _htmlRenderCtr.replyList.insert(0, value['data']),
                          _htmlRenderCtr.acount.value++
                        }
                    },
                  );
                },
                tooltip: '评论动态',
                child: const Icon(Icons.reply),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Obx replyList() {
    return Obx(
      () => _htmlRenderCtr.replyList.isEmpty && _htmlRenderCtr.isLoadingMore
          ? ListView.builder(
              itemCount: 5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return const VideoReplySkeleton();
              },
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _htmlRenderCtr.replyList.length + 1,
              itemBuilder: (context, index) {
                if (index == _htmlRenderCtr.replyList.length) {
                  return Container(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom),
                    height: MediaQuery.of(context).padding.bottom + 100,
                    child: Center(
                      child: Obx(
                        () => Text(
                          _htmlRenderCtr.noMore.value,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return ReplyItem(
                    replyItem: _htmlRenderCtr.replyList[index],
                    showReplyRow: true,
                    replyLevel: '1',
                    replyReply: (replyItem) => replyReply(replyItem),
                    replyType: ReplyType.values[type],
                    addReply: (replyItem) {
                      _htmlRenderCtr.replyList[index].replies!.add(replyItem);
                    },
                  );
                }
              },
            ),
    );
  }

  Container replyHeader() {
    return Container(
      height: 45,
      padding: const EdgeInsets.only(left: 12, right: 6),
      child: Row(
        children: [
          const Text('回复'),
          const Spacer(),
          SizedBox(
            height: 35,
            child: TextButton.icon(
              onPressed: () => _htmlRenderCtr.queryBySort(),
              icon: const Icon(Icons.sort, size: 16),
              label: Obx(
                () => Text(
                  _htmlRenderCtr.sortTypeLabel.value,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

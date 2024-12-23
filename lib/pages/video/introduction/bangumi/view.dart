import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/constants.dart';
import 'package:PiliPalaX/common/widgets/badge.dart';
import 'package:PiliPalaX/common/widgets/network_img_layer.dart';
import 'package:PiliPalaX/common/widgets/stat/danmu.dart';
import 'package:PiliPalaX/common/widgets/stat/view.dart';
import 'package:PiliPalaX/models/bangumi/info.dart';
import 'package:PiliPalaX/pages/bangumi/widgets/bangumi_panel.dart';
import 'package:PiliPalaX/pages/video/index.dart';
import 'package:PiliPalaX/pages/video/introduction/widgets/action_item.dart';
import 'package:PiliPalaX/pages/video/introduction/widgets/action_row_item.dart';
import 'package:PiliPalaX/pages/video/introduction/widgets/fav_panel.dart';
import 'package:PiliPalaX/utils/feed_back.dart';

import 'package:PiliPalaX/utils/utils.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'controller.dart';
import '../widgets/bangumi_intro_detail.dart';

class BangumiIntroPanel extends StatefulWidget {
  final int? cid;
  final String heroTag;
  const BangumiIntroPanel({
    super.key,
    this.cid,
    required this.heroTag,
  });

  @override
  State<BangumiIntroPanel> createState() => _BangumiIntroPanelState();
}

class _BangumiIntroPanelState extends State<BangumiIntroPanel>
    with AutomaticKeepAliveClientMixin {
  late BangumiIntroController bangumiIntroController;
  late VideoDetailController videoDetailCtr;
  BangumiInfoModel? bangumiDetail;
  late Future _futureBuilderFuture;
  late int cid;
  late String heroTag;

// 添加页面缓存
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // heroTag = Get.arguments['heroTag'];
    heroTag = widget.heroTag;
    cid = widget.cid!;
    bangumiIntroController = Get.put(BangumiIntroController(), tag: heroTag);
    videoDetailCtr = Get.find<VideoDetailController>(tag: heroTag);
    bangumiIntroController.bangumiDetail.listen((BangumiInfoModel value) {
      bangumiDetail = value;
    });
    _futureBuilderFuture = bangumiIntroController.queryBangumiIntro();
    videoDetailCtr.cid.listen((int p0) {
      cid = p0;
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _futureBuilderFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data['status']) {
            // 请求成功

            return BangumiInfo(
              loadingStatus: false,
              bangumiDetail: bangumiDetail,
              cid: cid,
            );
          } else {
            // 请求错误
            // return HttpError(
            //   errMsg: snapshot.data['msg'],
            //   fn: () => Get.back(),
            // );
            return const SizedBox();
          }
        } else {
          return BangumiInfo(
            loadingStatus: true,
            bangumiDetail: bangumiDetail,
            cid: cid,
          );
        }
      },
    );
  }
}

class BangumiInfo extends StatefulWidget {
  const BangumiInfo({
    super.key,
    this.loadingStatus = false,
    this.bangumiDetail,
    this.cid,
  });

  final bool loadingStatus;
  final BangumiInfoModel? bangumiDetail;
  final int? cid;

  @override
  State<BangumiInfo> createState() => _BangumiInfoState();
}

class _BangumiInfoState extends State<BangumiInfo> {
  String heroTag = Get.arguments['heroTag'];
  late final BangumiIntroController bangumiIntroController;
  late final VideoDetailController videoDetailCtr;
  late final BangumiInfoModel? bangumiItem;
  int? cid;
  bool isProcessing = false;
  void Function()? handleState(Future Function() action) {
    return isProcessing
        ? null
        : () async {
            setState(() => isProcessing = true);
            await action();
            setState(() => isProcessing = false);
          };
  }

  @override
  void initState() {
    super.initState();
    bangumiIntroController = Get.put(BangumiIntroController(), tag: heroTag);
    videoDetailCtr = Get.find<VideoDetailController>(tag: heroTag);
    bangumiItem = bangumiIntroController.bangumiItem;
    cid = widget.cid!;
    print('cid:  $cid');
    videoDetailCtr.cid.listen((p0) {
      cid = p0;
      if (!mounted) return;
      setState(() {});
    });
  }

  // 收藏
  showFavBottomSheet() {
    if (bangumiIntroController.userInfo.mid == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FavPanel(ctr: bangumiIntroController);
      },
    );
  }

  // 视频介绍
  showIntroDetail() {
    feedBack();
    showBottomSheet(
      context: context,
      enableDrag: true,
      builder: (BuildContext context) {
        return BangumiIntroDetail(bangumiDetail: widget.bangumiDetail!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return SliverPadding(
      padding: EdgeInsets.only(
          left: StyleString.safeSpace,
          right: StyleString.safeSpace,
          top: isLandscape ? 10 : 20),
      sliver: SliverToBoxAdapter(
        child: !widget.loadingStatus || bangumiItem != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          NetworkImgLayer(
                            width: isLandscape ? 160 : 105,
                            height: isLandscape ? 105 : 160,
                            src: !widget.loadingStatus
                                ? widget.bangumiDetail!.cover!
                                : bangumiItem!.cover!,
                            semanticsLabel: '封面',
                          ),
                          if (bangumiItem != null &&
                              bangumiItem!.rating != null)
                            PBadge(
                              text:
                                  '评分 ${!widget.loadingStatus ? widget.bangumiDetail!.rating!['score']! : bangumiItem!.rating!['score']!}',
                              top: null,
                              right: 6,
                              bottom: 6,
                              left: null,
                            ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () => showIntroDetail(),
                          child: SizedBox(
                            height: isLandscape ? 103 : 158,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        !widget.loadingStatus
                                            ? widget.bangumiDetail!.title!
                                            : bangumiItem!.title!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: IconButton(
                                        tooltip: '收藏',
                                        style: ButtonStyle(
                                          padding: WidgetStateProperty.all(
                                              EdgeInsets.zero),
                                          backgroundColor:
                                              WidgetStateProperty.resolveWith(
                                                  (Set<WidgetState> states) {
                                            return t
                                                .colorScheme.primaryContainer
                                                .withOpacity(0.7);
                                          }),
                                        ),
                                        onPressed: () =>
                                            bangumiIntroController.bangumiAdd(),
                                        icon: Icon(
                                          Icons.favorite_border_rounded,
                                          color: t.colorScheme.primary,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    StatView(
                                      theme: 'gray',
                                      view: !widget.loadingStatus
                                          ? widget.bangumiDetail!.stat!['views']
                                          : bangumiItem!.stat!['views'],
                                      size: 'medium',
                                    ),
                                    const SizedBox(width: 6),
                                    StatDanMu(
                                      theme: 'gray',
                                      danmu: !widget.loadingStatus
                                          ? widget
                                              .bangumiDetail!.stat!['danmakus']
                                          : bangumiItem!.stat!['danmakus'],
                                      size: 'medium',
                                    ),
                                    if (isLandscape) ...[
                                      const SizedBox(width: 6),
                                      AreasAndPubTime(
                                          widget: widget,
                                          bangumiItem: bangumiItem,
                                          t: t),
                                      const SizedBox(width: 6),
                                      NewEpDesc(
                                          widget: widget,
                                          bangumiItem: bangumiItem,
                                          t: t),
                                    ]
                                  ],
                                ),
                                SizedBox(height: isLandscape ? 2 : 6),
                                if (!isLandscape)
                                  AreasAndPubTime(
                                      widget: widget,
                                      bangumiItem: bangumiItem,
                                      t: t),
                                if (!isLandscape)
                                  NewEpDesc(
                                      widget: widget,
                                      bangumiItem: bangumiItem,
                                      t: t),
                                const Spacer(),
                                Text(
                                  '简介：${!widget.loadingStatus ? widget.bangumiDetail!.evaluate! : bangumiItem!.evaluate!}',
                                  maxLines: isLandscape ? 2 : 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: t.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // 点赞收藏转发 布局样式1
                  // SingleChildScrollView(
                  //   padding: const EdgeInsets.only(top: 7, bottom: 7),
                  //   scrollDirection: Axis.horizontal,
                  //   child: actionRow(
                  //     context,
                  //     bangumiIntroController,
                  //     videoDetailCtr,
                  //   ),
                  // ),
                  // 点赞收藏转发 布局样式2
                  actionGrid(context, bangumiIntroController),
                  // 番剧分p
                  if ((!widget.loadingStatus &&
                          widget.bangumiDetail!.episodes!.isNotEmpty) ||
                      bangumiItem != null &&
                          bangumiItem!.episodes!.isNotEmpty) ...[
                    BangumiPanel(
                      pages: bangumiItem != null
                          ? bangumiItem!.episodes!
                          : widget.bangumiDetail!.episodes!,
                      cid: cid ??
                          (bangumiItem != null
                              ? bangumiItem!.episodes!.first.cid
                              : widget.bangumiDetail!.episodes!.first.cid),
                      changeFuc: bangumiIntroController.changeSeasonOrbangu,
                    )
                  ],
                ],
              )
            : const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
      ),
    );
  }

  Widget actionGrid(BuildContext context, bangumiIntroController) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Material(
        child: Padding(
          padding: const EdgeInsets.only(top: 1),
          child: SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Obx(() => ActionItem(
                  icon: const Icon(Icons.thumb_up_outlined),
                  selectIcon: const Icon(Icons.thumb_up),
                      onTap:
                          handleState(bangumiIntroController.actionLikeVideo),
                      selectStatus: bangumiIntroController.hasLike.value,
                      loadingStatus: false,
                      semanticsLabel: '点赞',
                      text: !widget.loadingStatus
                          ? Utils.numFormat(
                              widget.bangumiDetail!.stat!['likes']!)
                          : Utils.numFormat(bangumiItem!.stat!['likes']!),
                    )),
                Obx(
                  () => ActionItem(
                      icon: const Icon(Icons.offline_bolt_outlined),
                      selectIcon: const Icon(Icons.offline_bolt),
                      onTap:
                          handleState(bangumiIntroController.actionCoinVideo),
                      selectStatus: bangumiIntroController.hasCoin.value,
                      loadingStatus: false,
                      semanticsLabel: '投币',
                      text: !widget.loadingStatus
                          ? Utils.numFormat(
                              widget.bangumiDetail!.stat!['coins']!)
                          : Utils.numFormat(bangumiItem!.stat!['coins']!)),
                ),
                Obx(
                  () => ActionItem(
                      icon: Icon(MdiIcons.starPlusOutline),
                      selectIcon: Icon(MdiIcons.star),
                      onTap: () => showFavBottomSheet(),
                      selectStatus: bangumiIntroController.hasFav.value,
                      loadingStatus: false,
                      semanticsLabel: '收藏',
                      text: !widget.loadingStatus
                          ? Utils.numFormat(
                              widget.bangumiDetail!.stat!['favorite']!)
                          : Utils.numFormat(bangumiItem!.stat!['favorite']!)),
                ),
                ActionItem(
                  icon: Icon(MdiIcons.chatOutline),
                  selectIcon: Icon(MdiIcons.reply),
                  onTap: () => videoDetailCtr.tabCtr.animateTo(1),
                  selectStatus: false,
                  loadingStatus: false,
                  semanticsLabel: '评论',
                  text: !widget.loadingStatus
                      ? Utils.numFormat(widget.bangumiDetail!.stat!['reply']!)
                      : Utils.numFormat(bangumiItem!.stat!['reply']!),
                ),
                ActionItem(
                    icon: const Icon(Icons.share_outlined),
                    onTap: () => bangumiIntroController.actionShareVideo(),
                    selectStatus: false,
                    loadingStatus: false,
                    semanticsLabel: '转发',
                    text: !widget.loadingStatus
                        ? Utils.numFormat(widget.bangumiDetail!.stat!['share']!)
                        : Utils.numFormat(bangumiItem!.stat!['share']!)),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget actionRow(BuildContext context, videoIntroController, videoDetailCtr) {
    return Row(children: [
      Obx(
        () => ActionRowItem(
          icon: const Icon(FontAwesomeIcons.thumbsUp),
          onTap: handleState(videoIntroController.actionLikeVideo),
          selectStatus: videoIntroController.hasLike.value,
          loadingStatus: widget.loadingStatus,
          text: !widget.loadingStatus
              ? widget.bangumiDetail!.stat!['likes']!.toString()
              : '-',
        ),
      ),
      const SizedBox(width: 8),
      Obx(
        () => ActionRowItem(
          icon: const Icon(FontAwesomeIcons.b),
          onTap: handleState(videoIntroController.actionCoinVideo),
          selectStatus: videoIntroController.hasCoin.value,
          loadingStatus: widget.loadingStatus,
          text: !widget.loadingStatus
              ? widget.bangumiDetail!.stat!['coins']!.toString()
              : '-',
        ),
      ),
      const SizedBox(width: 8),
      Obx(
        () => ActionRowItem(
          icon: const Icon(FontAwesomeIcons.heart),
          onTap: () => showFavBottomSheet(),
          selectStatus: videoIntroController.hasFav.value,
          loadingStatus: widget.loadingStatus,
          text: !widget.loadingStatus
              ? widget.bangumiDetail!.stat!['favorite']!.toString()
              : '-',
        ),
      ),
      const SizedBox(width: 8),
      ActionRowItem(
        icon: const Icon(FontAwesomeIcons.comment),
        onTap: () {
          videoDetailCtr.tabCtr.animateTo(1);
        },
        selectStatus: false,
        loadingStatus: widget.loadingStatus,
        text: !widget.loadingStatus
            ? widget.bangumiDetail!.stat!['reply']!.toString()
            : '-',
      ),
      const SizedBox(width: 8),
      ActionRowItem(
          icon: const Icon(FontAwesomeIcons.share),
          onTap: () => videoIntroController.actionShareVideo(),
          selectStatus: false,
          loadingStatus: widget.loadingStatus,
          text: '转发'),
    ]);
  }
}

class AreasAndPubTime extends StatelessWidget {
  const AreasAndPubTime({
    super.key,
    required this.widget,
    required this.bangumiItem,
    required this.t,
  });

  final BangumiInfo widget;
  final BangumiInfoModel? bangumiItem;
  final ThemeData t;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          !widget.loadingStatus
              ? (widget.bangumiDetail!.areas!.isNotEmpty
                  ? widget.bangumiDetail!.areas!.first['name']
                  : '')
              : (bangumiItem!.areas!.isNotEmpty
                  ? bangumiItem!.areas!.first['name']
                  : ''),
          style: TextStyle(
            fontSize: 12,
            color: t.colorScheme.outline,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          !widget.loadingStatus
              ? widget.bangumiDetail!.publish!['pub_time_show']
              : bangumiItem!.publish!['pub_time_show'],
          style: TextStyle(
            fontSize: 12,
            color: t.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class NewEpDesc extends StatelessWidget {
  const NewEpDesc({
    super.key,
    required this.widget,
    required this.bangumiItem,
    required this.t,
  });

  final BangumiInfo widget;
  final BangumiInfoModel? bangumiItem;
  final ThemeData t;

  @override
  Widget build(BuildContext context) {
    return Text(
      !widget.loadingStatus
          ? widget.bangumiDetail!.newEp!['desc']
          : bangumiItem!.newEp!['desc'],
      style: TextStyle(
        fontSize: 12,
        color: t.colorScheme.outline,
      ),
    );
  }
}

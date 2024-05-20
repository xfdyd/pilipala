import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/skeleton/video_card_h.dart';
import 'package:PiliPalaX/common/widgets/animated_dialog.dart';
import 'package:PiliPalaX/common/widgets/http_error.dart';
import 'package:PiliPalaX/common/widgets/overlay_pop.dart';
import 'package:PiliPalaX/common/widgets/video_card_h.dart';
import '../../../../common/constants.dart';
import '../../../../utils/grid.dart';
import './controller.dart';

class RelatedVideoPanel extends StatefulWidget {
  const RelatedVideoPanel({super.key});

  @override
  State<RelatedVideoPanel> createState() => _RelatedVideoPanelState();
}

class _RelatedVideoPanelState extends State<RelatedVideoPanel>
    with AutomaticKeepAliveClientMixin {
  late ReleatedController _releatedController;
  late Future _futureBuilder;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _releatedController =
        Get.put(ReleatedController(), tag: Get.arguments?['heroTag']);
    _futureBuilder = _releatedController.queryRelatedVideo();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SliverPadding(
        padding: const EdgeInsets.all(StyleString.safeSpace),
        sliver: FutureBuilder(
          future: _futureBuilder,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data == null) {
                return const SliverToBoxAdapter(child: SizedBox());
              }
              if (snapshot.data!['status'] && snapshot.hasData) {
                RxList relatedVideoList = _releatedController.relatedVideoList;
                // 请求成功
                return Obx(
                  () => SliverGrid(
                    gridDelegate: SliverGridDelegateWithExtentAndRatio(
                        mainAxisSpacing: StyleString.safeSpace,
                        crossAxisSpacing: StyleString.safeSpace,
                        maxCrossAxisExtent: Grid.maxRowWidth * 2,
                        childAspectRatio: StyleString.aspectRatio * 2.3,
                        mainAxisExtent: 0),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index == relatedVideoList.length) {
                        return SizedBox(
                            height: MediaQuery.of(context).padding.bottom);
                      } else {
                        return Material(
                          child: VideoCardH(
                            videoItem: relatedVideoList[index],
                            showPubdate: true,
                            longPress: () {
                              try {
                                _releatedController.popupDialog =
                                    _createPopupDialog(_releatedController
                                        .relatedVideoList[index]);
                                Overlay.of(context)
                                    .insert(_releatedController.popupDialog!);
                              } catch (err) {
                                return {};
                              }
                            },
                            longPressEnd: () {
                              _releatedController.popupDialog?.remove();
                            },
                          ),
                        );
                      }
                    }, childCount: relatedVideoList.length + 1),
                  ),
                );
              } else {
                // 请求错误
                return HttpError(errMsg: '出错了', fn: () {});
              }
            } else {
              // 骨架屏
              return SliverGrid(
                gridDelegate: SliverGridDelegateWithExtentAndRatio(
                    mainAxisSpacing: StyleString.safeSpace,
                    crossAxisSpacing: StyleString.safeSpace,
                    maxCrossAxisExtent: Grid.maxRowWidth * 2,
                    childAspectRatio: StyleString.aspectRatio * 2.3,
                    mainAxisExtent: 0),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return const VideoCardHSkeleton();
                }, childCount: 5),
              );
            }
          },
        ));
  }

  OverlayEntry _createPopupDialog(videoItem) {
    return OverlayEntry(
      builder: (BuildContext context) => AnimatedDialog(
        closeFn: _releatedController.popupDialog?.remove,
        child: OverlayPop(
            videoItem: videoItem,
            closeFn: _releatedController.popupDialog?.remove),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/skeleton/video_card_h.dart';
import 'package:PiliPalaX/common/widgets/http_error.dart';
import 'package:PiliPalaX/common/widgets/no_data.dart';
import 'package:PiliPalaX/common/widgets/video_card_h.dart';
import 'package:PiliPalaX/pages/later/index.dart';

import '../../common/constants.dart';
import '../../utils/grid.dart';

class LaterPage extends StatefulWidget {
  const LaterPage({super.key});

  @override
  State<LaterPage> createState() => _LaterPageState();
}

class _LaterPageState extends State<LaterPage> {
  final LaterController _laterController = Get.put(LaterController());
  Future? _futureBuilderFuture;

  @override
  void initState() {
    _futureBuilderFuture = _laterController.queryLaterList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: Obx(
          () => _laterController.laterList.isNotEmpty
              ? Text(
                  '稍后再看 (${_laterController.laterList.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                )
              : Text(
                  '稍后再看',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
        ),
        actions: [
          Obx(
            () => _laterController.laterList.isNotEmpty
                ? TextButton(
                    onPressed: () => _laterController.toViewDel(context),
                    child: const Text('移除已看'),
                  )
                : const SizedBox(),
          ),
          Obx(
            () => _laterController.laterList.isNotEmpty
                ? IconButton(
                    tooltip: '一键清空',
                    onPressed: () => _laterController.toViewClear(context),
                    icon: Icon(
                      Icons.clear_all_outlined,
                      size: 21,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : const SizedBox(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _laterController.scrollController,
        slivers: [
          SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: StyleString.safeSpace),
              sliver: FutureBuilder(
                future: _futureBuilderFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    Map data = snapshot.data as Map;
                    if (data['status']) {
                      return Obx(
                        () => _laterController.laterList.isNotEmpty &&
                                !_laterController.isLoading.value
                            ? SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithExtentAndRatio(
                                        mainAxisSpacing: StyleString.safeSpace,
                                        crossAxisSpacing: StyleString.safeSpace,
                                        maxCrossAxisExtent:
                                            Grid.maxRowWidth * 2,
                                        childAspectRatio:
                                            StyleString.aspectRatio * 2.4,
                                        mainAxisExtent: 0),
                                delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                  var videoItem =
                                      _laterController.laterList[index];
                                  return VideoCardH(
                                      videoItem: videoItem,
                                      source: 'later',
                                      longPress: () =>
                                          _laterController.toViewDel(context,
                                              aid: videoItem.aid));
                                },
                                    childCount:
                                        _laterController.laterList.length),
                              )
                            : _laterController.isLoading.value
                                ? const SliverToBoxAdapter(
                                    child: Center(child: Text('加载中')),
                                  )
                                : const NoData(),
                      );
                    } else {
                      return HttpError(
                        errMsg: data['msg'],
                        fn: () => setState(() {
                          _futureBuilderFuture =
                              _laterController.queryLaterList();
                        }),
                      );
                    }
                  } else {
                    // 骨架屏
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithExtentAndRatio(
                          mainAxisSpacing: StyleString.safeSpace,
                          crossAxisSpacing: StyleString.safeSpace,
                          maxCrossAxisExtent: Grid.maxRowWidth * 2,
                          childAspectRatio: StyleString.aspectRatio * 2.4,
                          mainAxisExtent: 0),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return const VideoCardHSkeleton();
                      }, childCount: 10),
                    );
                  }
                },
              )),
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 10,
            ),
          )
        ],
      ),
    );
  }
}

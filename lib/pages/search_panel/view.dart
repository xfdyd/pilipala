import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/skeleton/media_bangumi.dart';
import 'package:PiliPalaX/common/skeleton/video_card_h.dart';
import 'package:PiliPalaX/common/widgets/http_error.dart';
import 'package:PiliPalaX/models/common/search_type.dart';

import '../../common/constants.dart';
import '../../utils/grid.dart';
import 'controller.dart';
import 'widgets/article_panel.dart';
import 'widgets/live_panel.dart';
import 'widgets/media_bangumi_panel.dart';
import 'widgets/user_panel.dart';
import 'widgets/video_panel.dart';

class SearchPanel extends StatefulWidget {
  final String? keyword;
  final SearchType? searchType;
  final String? tag;
  const SearchPanel(
      {required this.keyword, required this.searchType, this.tag, super.key});

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel>
    with AutomaticKeepAliveClientMixin {
  late SearchPanelController _searchPanelController;

  late Future _futureBuilderFuture;
  late ScrollController scrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchPanelController = Get.put(
      SearchPanelController(
        keyword: widget.keyword,
        searchType: widget.searchType,
      ),
      tag: widget.searchType!.type + widget.keyword!,
    );
    scrollController = _searchPanelController.scrollController;
    scrollController.addListener(() async {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        EasyThrottle.throttle('history', const Duration(seconds: 1), () {
          _searchPanelController.onSearch(type: 'onLoad');
        });
      }
    });
    _futureBuilderFuture = _searchPanelController.onSearch();
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      displacement: 10.0,
      edgeOffset: 10.0,
      onRefresh: () async {
        await _searchPanelController.onRefresh();
      },
      child: FutureBuilder(
        future: _futureBuilderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              Map data = snapshot.data;
              var ctr = _searchPanelController;
              RxList list = ctr.resultList;
              if (data['status']) {
                return Obx(() {
                  list.length;
                  switch (widget.searchType) {
                    case SearchType.video:
                      return SearchVideoPanel(
                        ctr: _searchPanelController,
                        // ignore: invalid_use_of_protected_member
                        list: list.value,
                      );
                    case SearchType.media_bangumi:
                      return searchBangumiPanel(context, ctr, list);
                    case SearchType.bili_user:
                      return searchUserPanel(context, ctr, list);
                    case SearchType.live_room:
                      return searchLivePanel(context, ctr, list);
                    case SearchType.article:
                      return searchArticlePanel(context, ctr, list);
                    default:
                      return const SizedBox();
                  }
                });
              } else {
                return CustomScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  slivers: [
                    HttpError(
                      errMsg: data['msg'],
                      fn: () {
                        setState(() {
                          _futureBuilderFuture =
                              _searchPanelController.onSearch();
                        });
                      },
                    ),
                  ],
                );
              }
            } else {
              return CustomScrollView(
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
                  HttpError(
                    errMsg: '没有相关数据',
                    fn: () {
                      setState(() {
                        _searchPanelController.onSearch();
                      });
                    },
                  ),
                ],
              );
            }
          } else {
            // 骨架屏
            return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverGrid(
                      gridDelegate: SliverGridDelegateWithExtentAndRatio(
                          mainAxisSpacing: StyleString.safeSpace,
                          crossAxisSpacing: StyleString.safeSpace,
                          maxCrossAxisExtent: Grid.maxRowWidth * 2,
                          childAspectRatio: StyleString.aspectRatio * 2.4,
                          mainAxisExtent: 0),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          switch (widget.searchType) {
                            case SearchType.video:
                              return const VideoCardHSkeleton();
                            case SearchType.media_bangumi:
                              return const MediaBangumiSkeleton();
                            case SearchType.bili_user:
                              return const VideoCardHSkeleton();
                            case SearchType.live_room:
                              return const VideoCardHSkeleton();
                            default:
                              return const VideoCardHSkeleton();
                          }
                        },
                        childCount: 15,
                      ))
                ]);
          }
        },
      ),
    );
  }
}

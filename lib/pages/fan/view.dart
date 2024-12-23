import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/widgets/http_error.dart';
import 'package:PiliPalaX/common/widgets/no_data.dart';
import 'package:PiliPalaX/models/fans/result.dart';

import '../../common/constants.dart';
import '../../utils/grid.dart';
import 'controller.dart';
import 'widgets/fan_item.dart';

class FansPage extends StatefulWidget {
  const FansPage({super.key});

  @override
  State<FansPage> createState() => _FansPageState();
}

class _FansPageState extends State<FansPage> {
  late String mid;
  late FansController _fansController;
  final ScrollController scrollController = ScrollController();
  Future? _futureBuilderFuture;

  @override
  void initState() {
    super.initState();
    mid = Get.parameters['mid']!;
    _fansController = Get.put(FansController(), tag: mid);
    _futureBuilderFuture = _fansController.queryFans('init');
    scrollController.addListener(
      () async {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          EasyThrottle.throttle('follow', const Duration(seconds: 1), () {
            _fansController.queryFans('onLoad');
          });
        }
      },
    );
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          _fansController.isOwner.value ? '我的粉丝' : '${_fansController.name}的粉丝',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: RefreshIndicator(
        displacement: 10.0,
        edgeOffset: 10.0,
        onRefresh: () async => await _fansController.queryFans('init'),
        child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            slivers: [
              FutureBuilder(
                future: _futureBuilderFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.data != null) {
                    var data = snapshot.data;
                    if (data['status']) {
                      return Obx(() {
                        List<FansItemModel> list = _fansController.fansList;
                        return list.isNotEmpty
                            ? SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                        mainAxisSpacing: StyleString.cardSpace,
                                        crossAxisSpacing: StyleString.safeSpace,
                                        maxCrossAxisExtent:
                                            Grid.maxRowWidth * 2,
                                        mainAxisExtent: 56),
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return fanItem(item: list[index]);
                                  },
                                  childCount: list.length,
                                ))
                            : const NoData();
                      });
                    } else {
                      return HttpError(
                        errMsg: data['msg'],
                        fn: () => _fansController.queryFans('init'),
                      );
                    }
                  } else {
                    // 骨架屏
                    return const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }
                },
              ),
            ]),
      ),
    );
  }
}

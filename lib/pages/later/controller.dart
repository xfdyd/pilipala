import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/http/user.dart';
import 'package:PiliPalaX/models/model_hot_video_item.dart';

class LaterController extends GetxController {
  final ScrollController scrollController = ScrollController();
  RxList<HotVideoItemModel> laterList = <HotVideoItemModel>[].obs;
  int count = 0;
  RxBool isLoading = false.obs;

  Future queryLaterList() async {
    isLoading.value = true;
    var res = await UserHttp.seeYouLater();
    if (res['status']) {
      count = res['data']['count'];
      if (count > 0) {
        laterList.value = res['data']['list'];
      }
    }
    isLoading.value = false;
    return res;
  }

  Future toViewDel(BuildContext context, {int? aid}) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('提示'),
          content: Text(
              aid != null ? '即将移除该视频，确定是否移除' : '即将删除所有已观看视频，此操作不可恢复。确定是否删除？'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                '取消',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                var res = await UserHttp.toViewDel(aid: aid);
                if (res['status']) {
                  if (aid != null) {
                    laterList.removeWhere((e) => e.aid == aid);
                  } else {
                    laterList.clear();
                    queryLaterList();
                  }
                }
                Get.back();
                SmartDialog.showToast(res['msg']);
              },
              child: Text(aid != null ? '确认移除' : '确认删除'),
            )
          ],
        );
      },
    );
  }

  // 一键清空
  Future toViewClear(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('清空确认'),
          content: const Text('确定要清空你的稍后再看列表吗？'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                '取消',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                var res = await UserHttp.toViewClear();
                if (res['status']) {
                  laterList.clear();
                }
                Get.back();
                SmartDialog.showToast(res['msg']);
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }
}

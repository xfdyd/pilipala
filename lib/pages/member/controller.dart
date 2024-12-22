import 'dart:convert';
import 'package:PiliPalaX/http/constants.dart';
import 'package:PiliPalaX/http/init.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/http/member.dart';
import 'package:PiliPalaX/http/user.dart';
import 'package:PiliPalaX/http/video.dart';
import 'package:PiliPalaX/models/member/archive.dart';
import 'package:PiliPalaX/models/member/coin.dart';
import 'package:PiliPalaX/models/member/info.dart';
import 'package:PiliPalaX/utils/storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import 'package:PiliPalaX/pages/video/introduction/widgets/group_panel.dart';

class MemberController extends GetxController with GetTickerProviderStateMixin {
  int? mid;
  MemberController({this.mid});
  Rx<MemberInfoModel> memberInfo = MemberInfoModel().obs;
  late Map userStat;
  RxString face = ''.obs;
  String? heroTag;
  Box userInfoCache = GStorage.userInfo;
  late int ownerMid;
  bool specialFollowed = false;
  // 投稿列表
  RxList<VListItemModel>? archiveList = <VListItemModel>[].obs;
  dynamic userInfo;
  RxInt attribute = (-1).obs;
  RxString attributeText = '关注'.obs;
  RxList<MemberCoinsDataModel> recentCoinsList = <MemberCoinsDataModel>[].obs;
  String? wwebid;
  late TabController tabController;

  @override
  void onInit() async {
    super.onInit();
    mid = mid ?? int.parse(Get.parameters['mid']!);
    userInfo = userInfoCache.get('userInfoCache');
    ownerMid = userInfo?.mid ?? -1;
    face.value = Get.arguments?['face'] ?? '';
    heroTag = Get.arguments?['heroTag'] ?? '';
    tabController = TabController(length: 3, vsync: this);
    relationSearch();
  }

  // 获取用户信息
  Future<Map<String, dynamic>> getInfo() async {
    await getMemberStat();
    await getMemberView();
    await getWwebid();
    var res = await MemberHttp.memberInfo(mid: mid, wwebid: wwebid);
    if (res['status']) {
      memberInfo.value = res['data'];
      face.value = res['data'].face;
    } else {
      SmartDialog.showToast(res['msg']);
    }
    return res;
  }

  Future getWwebid() async {
    try {
      dynamic response =
      await Request().get('${HttpString.spaceBaseUrl}/$mid/dynamic');
      dom.Document document = html_parser.parse(response.data);
      dom.Element? scriptElement =
      document.querySelector('script#__RENDER_DATA__');
      wwebid = jsonDecode(
          Uri.decodeComponent(scriptElement?.text ?? ''))['access_id'];
    } catch (e) {
      print('failed to get wwebid: $e');
    }
  }

  // 获取用户状态
  Future<Map<String, dynamic>> getMemberStat() async {
    var res = await MemberHttp.memberStat(mid: mid);
    if (res['status']) {
      userStat = res['data'];
    }
    return res;
  }

  // 获取用户播放数 获赞数
  Future<Map<String, dynamic>> getMemberView() async {
    var res = await MemberHttp.memberView(mid: mid!);
    if (res['status']) {
      userStat.addAll(res['data']);
    }
    return res;
  }

  Future delayedUpdateRelation() async {
    await Future.delayed(const Duration(milliseconds: 1000), () async {
      SmartDialog.showToast('更新状态');
      await relationSearch();
      memberInfo.update((val) {});
    });
  }

  // 关注/取关up
  Future actionRelationMod(BuildContext context) async {
    if (userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    // if (memberInfo.value == null) {
    //   SmartDialog.showToast('尚未获取到用户信息');
    //   return;
    // }
    if (attribute.value == 128) {
      blockUser(context);
      return;
    }
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('操作'),
          actions: [
            if (memberInfo.value.isFollowed!) ...[
              TextButton(
                onPressed: () async {
                  final res = await MemberHttp.addUsers(
                      mid, specialFollowed ? '0' : '-10');
                  SmartDialog.showToast(res['msg']);
                  if (res['status']) {
                    specialFollowed = !specialFollowed;
                  }
                  Get.back();
                },
                child: Text(specialFollowed ? '移除特别关注' : '加入特别关注'),
              ),
              TextButton(
                onPressed: () async {
                  await Get.bottomSheet(
                    GroupPanel(mid: mid),
                    isScrollControlled: true,
                  );
                  Get.back();
                },
                child: const Text('设置分组'),
              ),
            ],
            TextButton(
              onPressed: () async {
                var res = await VideoHttp.relationMod(
                  mid: mid!,
                  act: memberInfo.value.isFollowed! ? 2 : 1,
                  reSrc: 11,
                );
                SmartDialog.showToast(res['status'] ? "操作成功" : res['msg']);
                if (res['status']) {
                  memberInfo.value.isFollowed = !memberInfo.value.isFollowed!;
                }
                Get.back();
              },
              child: Text(memberInfo.value.isFollowed! ? '取消关注' : '关注'),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                '取消',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
          ],
        );
      },
    );
    await delayedUpdateRelation();
  }

  // 关系查询
  Future relationSearch() async {
    if (userInfo == null) return;
    if (mid == ownerMid) return;
    var res = await UserHttp.hasFollow(mid!);
    if (res['status']) {
      attribute.value = res['data']['attribute'];
      switch (attribute.value) {
        case 1:
          attributeText.value = '悄悄关注';
          memberInfo.value.isFollowed = true;
          break;
        case 2:
          attributeText.value = '已关注';
          memberInfo.value.isFollowed = true;
          break;
        case 6:
          attributeText.value = '已互关';
          memberInfo.value.isFollowed = true;
          break;
        case 128:
          attributeText.value = '已拉黑';
          memberInfo.value.isFollowed = false;
          break;
        default:
          attributeText.value = '关注';
          memberInfo.value.isFollowed = false;
      }
      if (res['data']['special'] == 1) {
        specialFollowed = true;
        attributeText.value += ' 🔔';
      } else {
        specialFollowed = false;
      }
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }

  // 拉黑用户
  Future blockUser(BuildContext context) async {
    if (userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('提示'),
          content: Text(attribute.value != 128 ? '确定拉黑UP主?' : '从黑名单移除UP主'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                '点错了',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                var res = await VideoHttp.relationMod(
                  mid: mid!,
                  act: attribute.value != 128 ? 5 : 6,
                  reSrc: 11,
                );
                if (res['status']) {
                  attribute.value = attribute.value != 128 ? 128 : 0;
                  attributeText.value = attribute.value == 128 ? '已拉黑' : '关注';
                  memberInfo.value.isFollowed = false;
                  relationSearch();
                  memberInfo.update((val) {});
                }
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }

  void shareUser() {
    Share.share('${memberInfo.value.name} - https://space.bilibili.com/$mid');
  }

  // 请求投币视频
  Future getRecentCoinVideo() async {
    if (userInfo == null) return;
    var res = await MemberHttp.getRecentCoinVideo(mid: mid!);
    recentCoinsList.value = res['data'];
    return res;
  }

  // // 跳转查看动态
  // void pushDynamicsPage() => Get.toNamed('/memberDynamics?mid=$mid');
  //
  // // 跳转查看投稿
  // void pushArchivesPage() => Get.toNamed('/memberArchive?mid=$mid');
  //
  // // 跳转查看专栏
  // void pushSeasonsPage() {}
  // // 跳转查看最近投币
  // void pushRecentCoinsPage() async {
  //   if (recentCoinsList.isNotEmpty) {}
  // }
}

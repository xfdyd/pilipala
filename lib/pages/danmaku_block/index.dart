import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/utils/storage.dart';

import '../../http/danmaku_block.dart';
import '../../models/user/danmaku_block.dart';

class DanmakuBlockPage extends StatefulWidget {
  const DanmakuBlockPage({super.key});

  @override
  State<DanmakuBlockPage> createState() => _DanmakuBlockPageState();
}

class _DanmakuBlockPageState extends State<DanmakuBlockPage> {
  final DanmakuBlockController _danmakuBlockController =
      Get.put(DanmakuBlockController());
  final ScrollController scrollController = ScrollController();
  Box setting = GStrorage.setting;

  @override
  void initState() {
    super.initState();
    _danmakuBlockController.queryDanmakuFilter();
  }

  @override
  void dispose() {
    List<Map<String, dynamic>> simpleRuleList =
        _danmakuBlockController.danmakuRules.map<Map<String, dynamic>>((e) {
      return SimpleRule(e.id!, e.type!, e.filter!).toMap();
    }).toList();
    setting.put(SettingBoxKey.danmakuFilterRule, simpleRuleList);
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => TabBar(
            controller: _danmakuBlockController.tabController,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: '文本(${_danmakuBlockController.textRules.length})'),
              Tab(text: '正则(${_danmakuBlockController.regexRules.length})'),
              Tab(text: '用户(${_danmakuBlockController.userRules.length})'),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            await _danmakuBlockController.queryDanmakuFilter(),
        child: TabBarView(
          controller: _danmakuBlockController.tabController,
          children: [
            Obx(() => tabViewBuilder(0, _danmakuBlockController.textRules)),
            Obx(() => tabViewBuilder(1, _danmakuBlockController.regexRules)),
            Obx(() => tabViewBuilder(2, _danmakuBlockController.userRules)),
          ],
        ),
      ),
    );
  }
  Widget tabViewBuilder(int index, List<SimpleRule> list) {
    return ListView.builder(
      controller: scrollController,
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(
            list[index].filter,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await _danmakuBlockController.danmakuFilterDel(
                  1, list[index].id);
            },
          ),
        );
      },
    );
  }
}

class DanmakuBlockController extends GetxController
    with GetTickerProviderStateMixin {
  RxList<Rule> danmakuRules = <Rule>[].obs;
  RxList<SimpleRule> textRules = <SimpleRule>[].obs;
  RxList<SimpleRule> regexRules = <SimpleRule>[].obs;
  RxList<SimpleRule> userRules = <SimpleRule>[].obs;
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future queryDanmakuFilter() async {
    var result = await DanmakuFilterHttp.danmakuFilter();
    if (result['status']) {
      danmakuRules.value = result['data'].rule;
      danmakuRules.map((e) {
        SimpleRule simpleRule = SimpleRule(e.id!, e.type!, e.filter!);
        switch (e.type!) {
          case 0:
            textRules.add(simpleRule);
            break;
          case 1:
            regexRules.add(simpleRule);
            break;
          case 2:
            userRules.add(simpleRule);
            break;
          default:
            SmartDialog.showToast('未知的规则类型：${e.type}，内容为：${e.filter}');
        }
      }).toList();
      SmartDialog.showToast(result['data'].toast);
    }
    return result;
  }

  Future danmakuFilterDel(int type, int id) async {
    var result = await DanmakuFilterHttp.danmakuFilterDel(ids: id);
    if (result['status']) {
      danmakuRules.removeWhere((e) => e.id == id);
      switch (type) {
        case 0:
          textRules.removeWhere((e) => e.id == id);
          break;
        case 1:
          regexRules.removeWhere((e) => e.id == id);
          break;
        case 2:
          userRules.removeWhere((e) => e.id == id);
          break;
      }
      SmartDialog.showToast(result['msg']);
    } else {
      SmartDialog.showToast(result['msg']);
    }
  }

  Future danmakuFilterAdd({required String filter, required int type}) async {
    var result =
        await DanmakuFilterHttp.danmakuFilterAdd(filter: filter, type: type);
    if (result['status']) {
      Rule data = result['data'];
      danmakuRules.add(data);
      SimpleRule simpleRule = SimpleRule(data.id!, data.type!, data.filter!);
      switch (data.type!) {
        case 0:
          textRules.add(simpleRule);
          break;
        case 1:
          regexRules.add(simpleRule);
          break;
        case 2:
          userRules.add(simpleRule);
          break;
      }
      SmartDialog.showToast('添加成功');
    } else {
      SmartDialog.showToast(result['msg']);
    }
  }
}

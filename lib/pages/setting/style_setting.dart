import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/models/common/theme_type.dart';
import 'package:PiliPalaX/pages/setting/pages/color_select.dart';
import 'package:PiliPalaX/pages/setting/widgets/select_dialog.dart';
import 'package:PiliPalaX/pages/setting/widgets/slide_dialog.dart';
import 'package:PiliPalaX/utils/global_data.dart';
import 'package:PiliPalaX/utils/storage.dart';

import '../../models/common/dynamic_badge_mode.dart';
import '../../plugin/pl_player/utils/fullscreen.dart';
import '../../models/common/nav_bar_config.dart';
import 'controller.dart';
import 'widgets/switch_item.dart';

class StyleSetting extends StatefulWidget {
  const StyleSetting({super.key});

  @override
  State<StyleSetting> createState() => _StyleSettingState();
}

class _StyleSettingState extends State<StyleSetting> {
  final SettingController settingController = Get.put(SettingController());
  final ColorSelectController colorSelectController =
      Get.put(ColorSelectController());

  Box setting = GStrorage.setting;
  late int picQuality;
  late ThemeType _tempThemeValue;
  late double maxRowWidth;

  @override
  void initState() {
    super.initState();
    picQuality = setting.get(SettingBoxKey.defaultPicQa, defaultValue: 10);
    _tempThemeValue = settingController.themeType.value;
    maxRowWidth = setting.get(SettingBoxKey.maxRowWidth, defaultValue: 240.0) as double;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!;
    TextStyle subTitleStyle = Theme.of(context)
        .textTheme
        .labelMedium!
        .copyWith(color: Theme.of(context).colorScheme.outline);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          '外观设置',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView(
        children: [
          SetSwitchItem(
              title: '横屏适配',
              subTitle: '开启该项启用横屏布局与逻辑（测试）',
              setKey: SettingBoxKey.horizontalScreen,
              defaultVal: false,
              callFn: (value) {
                if (value) {
                  autoScreen();
                  SmartDialog.showToast('已开启横屏适配');
                } else {
                  AutoOrientation.portraitUpMode();
                  SmartDialog.showToast('已关闭横屏适配');
                }
              }),
          const SetSwitchItem(
            title: 'MD3样式底栏',
            subTitle: '符合Material You设计规范的底栏，关闭可使底栏变窄',
            setKey: SettingBoxKey.enableMYBar,
            defaultVal: true,
          ),
          const SetSwitchItem(
            title: '首页顶栏收起',
            subTitle: '首页列表滑动时，收起顶栏',
            setKey: SettingBoxKey.hideSearchBar,
            defaultVal: false,
            needReboot: true,
          ),
          const SetSwitchItem(
            title: '首页底栏收起',
            subTitle: '首页列表滑动时，收起底栏',
            setKey: SettingBoxKey.hideTabBar,
            defaultVal: false,
            needReboot: true,
          ),
          const SetSwitchItem(
            title: '首页背景渐变',
            setKey: SettingBoxKey.enableGradientBg,
            defaultVal: true,
            needReboot: true,
          ),
          ListTile(
            onTap: () async {
              double? result = await showDialog(
                context: context,
                builder: (context) {
                  return SlideDialog<double>(
                    title: '最大列宽度（默认240dp）',
                    value: maxRowWidth,
                    min: 150.0,
                    max: 500.0,
                    divisions: 35,
                    suffix: 'dp',
                  );
                }
              );
              if (result != null) {
                maxRowWidth = result;
                setting.put(SettingBoxKey.maxRowWidth, result);
                SmartDialog.showToast('重启生效');
                setState(() {});
              }
            },
            dense: false,
            title: Text('最大列宽（dp）基准', style: titleStyle),
            subtitle: Text(
              '当前：${maxRowWidth.toInt()}dp，屏幕宽度：${MediaQuery.of(context).size.width.toPrecision(2)}dp。'
                  '该值决定列表在不同屏宽下的列数，部分列表会根据系数折算宽度',
              style: subTitleStyle,
            ),
          ),
          ListTile(
            dense: false,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, StateSetter setState) {
                      final SettingController settingController =
                          Get.put(SettingController());
                      return AlertDialog(
                        title: const Text('图片质量'),
                        contentPadding: const EdgeInsets.only(
                            top: 20, left: 8, right: 8, bottom: 8),
                        content: SizedBox(
                          height: 40,
                          child: Slider(
                            value: picQuality.toDouble(),
                            min: 10,
                            max: 100,
                            divisions: 9,
                            label: '$picQuality%',
                            onChanged: (double val) {
                              picQuality = val.toInt();
                              setState(() {});
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Get.back(),
                              child: Text('取消',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline))),
                          TextButton(
                            onPressed: () {
                              setting.put(
                                  SettingBoxKey.defaultPicQa, picQuality);
                              Get.back();
                              settingController.picQuality.value = picQuality;
                              GlobalData().imgQuality = picQuality;
                              SmartDialog.showToast('设置成功');
                            },
                            child: const Text('确定'),
                          )
                        ],
                      );
                    },
                  );
                },
              );
            },
            title: Text('图片质量', style: titleStyle),
            subtitle: Text('选择合适的图片清晰度，上限100%', style: subTitleStyle),
            trailing: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Obx(
                () => Text(
                  '${settingController.picQuality.value}%',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
          ),
          ListTile(
            dense: false,
            onTap: () async {
              double? result = await showDialog(
                context: context,
                builder: (context) {
                  return SlideDialog<double>(
                    title: 'Toast不透明度',
                    value: settingController.toastOpacity.value,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                  );
                },
              );
              if (result != null) {
                settingController.toastOpacity.value = result;
                SmartDialog.showToast('设置成功');
                setting.put(SettingBoxKey.defaultToastOp, result);
              }
            },
            title: Text('Toast不透明度', style: titleStyle),
            subtitle: Text('自定义Toast不透明度', style: subTitleStyle),
          ),
          ListTile(
            dense: false,
            onTap: () async {
              ThemeType? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<ThemeType>(
                      title: '主题模式',
                      value: _tempThemeValue,
                      values: ThemeType.values.map((e) {
                        return {'title': e.description, 'value': e};
                      }).toList());
                },
              );
              if (result != null) {
                _tempThemeValue = result;
                settingController.themeType.value = result;
                setting.put(SettingBoxKey.themeMode, result.code);
                Get.forceAppUpdate();
              }
            },
            title: Text('主题模式', style: titleStyle),
            subtitle: Obx(() => Text(
                '当前模式：${settingController.themeType.value.description}',
                style: subTitleStyle)),
          ),
          ListTile(
            dense: false,
            onTap: () => settingController.setDynamicBadgeMode(context),
            title: Text('动态未读标记', style: titleStyle),
            subtitle: Obx(() => Text(
                '当前标记样式：${settingController.dynamicBadgeType.value.description}',
                style: subTitleStyle)),
          ),
          ListTile(
            dense: false,
            onTap: () => Get.toNamed('/colorSetting'),
            title: Text('应用主题', style: titleStyle),
            subtitle: Obx(() => Text(
                '当前主题：${colorSelectController.type.value == 0 ? '动态取色' : '指定颜色'}',
                style: subTitleStyle)),
          ),
          const SetSwitchItem(
            title: '默认展示评论区',
            subTitle: '在视频详情页默认切换至评论区页',
            setKey: SettingBoxKey.defaultShowComment,
            defaultVal: false,
          ),
          ListTile(
            dense: false,
            onTap: () => settingController.seteDefaultHomePage(context),
            title: Text('默认启动页', style: titleStyle),
            subtitle: Obx(() => Text(
                '当前启动页：${defaultNavigationBars.firstWhere((e) => e['id'] == settingController.defaultHomePage.value)['label']}',
                style: subTitleStyle)),
          ),
          ListTile(
            dense: false,
            onTap: () => Get.toNamed('/fontSizeSetting'),
            title: Text('字体大小', style: titleStyle),
          ),
          ListTile(
            dense: false,
            onTap: () => Get.toNamed('/tabbarSetting'),
            title: Text('首页标签页', style: titleStyle),
            subtitle: Text('删除或调换首页标签页', style: subTitleStyle),
          ),
          if (Platform.isAndroid)
            ListTile(
              dense: false,
              onTap: () => Get.toNamed('/displayModeSetting'),
              title: Text('屏幕帧率', style: titleStyle),
            )
        ],
      ),
    );
  }
}

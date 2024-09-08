import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/models/common/color_type.dart';
import 'package:PiliPalaX/utils/storage.dart';

class ColorSelectPage extends StatefulWidget {
  const ColorSelectPage({super.key});

  @override
  State<ColorSelectPage> createState() => _ColorSelectPageState();
}

class _ColorSelectPageState extends State<ColorSelectPage> {
  final ColorSelectController ctr = Get.put(ColorSelectController());

  @override
  Widget build(BuildContext context) {
    // 获取当前主题的 ColorScheme
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('选择应用主题'),
      ),
      body: ListView(
        children: [
          Obx(
            () => RadioListTile(
              value: 0,
              title: const Text('动态取色'),
              groupValue: ctr.type.value,
              onChanged: (dynamic val) async {
                ctr.type.value = 0;
                ctr.setting.put(SettingBoxKey.dynamicColor, true);
                Get.forceAppUpdate();
              },
            ),
          ),
          Obx(
            () => RadioListTile(
              value: 1,
              title: const Text('指定颜色'),
              groupValue: ctr.type.value,
              onChanged: (dynamic val) async {
                ctr.type.value = 1;
                ctr.setting.put(SettingBoxKey.dynamicColor, false);
                Get.forceAppUpdate();
              },
            ),
          ),
          Obx(
            () {
              int type = ctr.type.value;
              return Offstage(
                offstage: type == 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 22,
                    runSpacing: 18,
                    children: [
                      ...ctr.colorThemes.map(
                        (e) {
                          final index = ctr.colorThemes.indexOf(e);
                          return GestureDetector(
                            onTap: () {
                              ctr.currentColor.value = index;
                              ctr.setting.put(SettingBoxKey.customColor, index);
                              Get.forceAppUpdate();
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: e['color'].withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      width: 2,
                                      color: ctr.currentColor.value == index
                                          ? Colors.black
                                          : e['color'].withOpacity(0.8),
                                    ),
                                  ),
                                  child: AnimatedOpacity(
                                    opacity:
                                        ctr.currentColor.value == index ? 1 : 0,
                                    duration: const Duration(milliseconds: 200),
                                    child: const Icon(
                                      Icons.done,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  e['label'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ctr.currentColor.value != index
                                        ? Theme.of(context).colorScheme.outline
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // 展示 ColorScheme 的颜色
          ListTile(
            title: Center(child: Text('${colorScheme.toStringShort()} 可用颜色表')),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GridView.extent(
                shrinkWrap: true, // 自动调整高度
                physics: const NeverScrollableScrollPhysics(), // 禁用滚动
                maxCrossAxisExtent: 120, childAspectRatio: 4.5,
                mainAxisSpacing: 5, crossAxisSpacing: 5,
                children: _buildColorSchemeDisplay(colorScheme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildColorSchemeDisplay(ColorScheme colorScheme) {
    String colorSchemeString = colorScheme.toString();
    final leftBracketIndex = colorSchemeString.indexOf('(');

    if (leftBracketIndex != -1) {
      colorSchemeString = colorSchemeString.substring(leftBracketIndex + 1);
    }

    final colorEntries = colorSchemeString
        .split(',')
        .where((line) => line.contains('Color('))
        .map((line) {
      final parts = line.split(':');
      final key = parts[0].trim();
      final color = parts[1].trim();
      return MapEntry(key, Color(int.parse(color.substring(8, 16), radix: 16)));
    }).toList();

    return colorEntries.map((entry) {
      return Container(
        width: 80, // 固定宽度
        height: 40, // 固定高度
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: entry.value,
                border: Border.all(color: Colors.black, width: 1),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
                child: Text(entry.key,
                    maxLines: 3,
                    style: const TextStyle(
                      fontSize: 10,
                    ))),
          ],
        ),
      );
    }).toList();
  }
}

class ColorSelectController extends GetxController {
  Box setting = GStorage.setting;
  RxBool dynamicColor = true.obs;
  RxInt type = 0.obs;
  late final List<Map<String, dynamic>> colorThemes;
  RxInt currentColor = 0.obs;

  @override
  void onInit() {
    colorThemes = colorThemeTypes;
    // 默认使用动态取色
    dynamicColor.value =
        setting.get(SettingBoxKey.dynamicColor, defaultValue: true);
    type.value = dynamicColor.value ? 0 : 1;
    currentColor.value =
        setting.get(SettingBoxKey.customColor, defaultValue: 0);
    super.onInit();
  }
}

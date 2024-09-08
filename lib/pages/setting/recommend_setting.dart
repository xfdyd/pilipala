import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/http/member.dart';
import 'package:PiliPalaX/models/common/rcmd_type.dart';
import 'package:PiliPalaX/pages/setting/widgets/select_dialog.dart';
import 'package:PiliPalaX/utils/recommend_filter.dart';
import 'package:PiliPalaX/utils/storage.dart';
import 'package:get/get.dart';

import 'widgets/switch_item.dart';

class RecommendSetting extends StatefulWidget {
  const RecommendSetting({super.key});

  @override
  State<RecommendSetting> createState() => _RecommendSettingState();
}

class _RecommendSettingState extends State<RecommendSetting> {
  Box setting = GStorage.setting;
  static Box localCache = GStorage.localCache;
  late dynamic defaultRcmdType;
  Box userInfoCache = GStorage.userInfo;
  late dynamic userInfo;
  bool userLogin = false;
  late dynamic accessKeyInfo;
  // late int filterUnfollowedRatio;
  late int minDurationForRcmd;
  late int minLikeRatioForRecommend;
  late String banWordForRecommend;

  @override
  void initState() {
    super.initState();
    // 首页默认推荐类型
    defaultRcmdType =
        setting.get(SettingBoxKey.defaultRcmdType, defaultValue: 'web');
    userInfo = userInfoCache.get('userInfoCache');
    userLogin = userInfo != null;
    accessKeyInfo = localCache.get(LocalCacheKey.accessKey, defaultValue: null);
    // filterUnfollowedRatio = setting
    //     .get(SettingBoxKey.filterUnfollowedRatio, defaultValue: 0);
    minDurationForRcmd =
        setting.get(SettingBoxKey.minDurationForRcmd, defaultValue: 0);
    minLikeRatioForRecommend =
        setting.get(SettingBoxKey.minLikeRatioForRecommend, defaultValue: 0);
    banWordForRecommend =
        setting.get(SettingBoxKey.banWordForRecommend, defaultValue: '');
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
          '推荐流设置',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            dense: false,
            title: Text('首页推荐类型', style: titleStyle),
            leading: const Icon(Icons.model_training_outlined),
            subtitle: Text(
              '当前使用「$defaultRcmdType端」推荐¹',
              style: subTitleStyle,
            ),
            onTap: () async {
              String? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<String>(
                    title: '推荐类型',
                    value: defaultRcmdType,
                    values: RcmdType.values.map((e) {
                      return {'title': e.labels, 'value': e.values};
                    }).toList(),
                  );
                },
              );
              if (result != null) {
                if (result == 'app') {
                  if (accessKeyInfo == null) {
                    SmartDialog.showToast('尚未登录，无法收到个性化推荐');
                  }
                }
                if (result != null) {
                  defaultRcmdType = result;
                  setting.put(SettingBoxKey.defaultRcmdType, result);
                  SmartDialog.showToast('下次启动时生效');
                  setState(() {});
                }
              }
            },
          ),
          const SetSwitchItem(
            title: '推荐动态',
            subTitle: '是否在推荐内容中展示动态(仅app端)',
            leading: Icon(Icons.motion_photos_on_outlined),
            setKey: SettingBoxKey.enableRcmdDynamic,
            defaultVal: true,
          ),
          const SetSwitchItem(
            title: '首页推荐刷新',
            subTitle: '下拉刷新时保留上次内容',
            leading: Icon(Icons.refresh),
            setKey: SettingBoxKey.enableSaveLastData,
            defaultVal: false,
          ),
          // 分割线
          const Divider(height: 1),
          ListTile(
            dense: false,
            leading: const Icon(Icons.thumb_up_outlined),
            title: Text('点赞率过滤', style: titleStyle),
            subtitle: Text(
              '过滤掉点赞数/播放量「小于$minLikeRatioForRecommend%」的推荐视频(仅web端)',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<int>(
                      title: '选择点赞率（0即不过滤）',
                      value: minLikeRatioForRecommend,
                      values: [0, 1, 2, 3, 4].map((e) {
                        return {'title': '$e %', 'value': e};
                      }).toList());
                },
              );
              if (result != null) {
                minLikeRatioForRecommend = result;
                setting.put(SettingBoxKey.minLikeRatioForRecommend, result);
                RecommendFilter.update();
                setState(() {});
              }
            },
          ),
          ListTile(
            dense: false,
            leading: const Icon(Icons.title_outlined),
            title: Text('标题关键词过滤', style: titleStyle),
            subtitle: Text(
              banWordForRecommend.isEmpty ? "点击添加" : banWordForRecommend,
              style: subTitleStyle,
            ),
            onTap: () async {
              final TextEditingController textController =
                  TextEditingController(text: banWordForRecommend);
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('标题关键词过滤'),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text('使用空格隔开，如：尝试 测试'),
                      TextField(
                        controller: textController,
                        //decoration: InputDecoration(hintText: hintText),
                      )
                    ]),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('清空'),
                        onPressed: () {
                          textController.text = '';
                        },
                      ),
                      TextButton(
                        child: const Text('取消'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          SmartDialog.showToast('关键词未被修改');
                        },
                      ),
                      TextButton(
                        child: const Text('保存'),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          String filter = textController.text.trim();
                          banWordForRecommend = filter;
                          setting.put(SettingBoxKey.banWordForRecommend,
                              banWordForRecommend);
                          setState(() {});
                          RecommendFilter.update();
                          if (filter.isNotEmpty) {
                            SmartDialog.showToast('已保存：$banWordForRecommend');
                          } else {
                            SmartDialog.showToast('已清除全部关键词');
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            dense: false,
            title: Text('视频时长过滤', style: titleStyle),
            leading: const Icon(Icons.timelapse_outlined),
            subtitle: Text(
              '过滤掉时长「小于$minDurationForRcmd秒」的推荐视频',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<int>(
                      title: '选择时长（0即不过滤）',
                      value: minDurationForRcmd,
                      values: [0, 30, 60, 90, 120].map((e) {
                        return {'title': '$e 秒', 'value': e};
                      }).toList());
                },
              );
              if (result != null) {
                minDurationForRcmd = result;
                setting.put(SettingBoxKey.minDurationForRcmd, result);
                RecommendFilter.update();
                setState(() {});
              }
            },
          ),
          SetSwitchItem(
            title: '已关注Up豁免推荐过滤',
            subTitle: '推荐中已关注用户发布的内容不会被过滤',
            leading: const Icon(Icons.favorite_border_outlined),
            setKey: SettingBoxKey.exemptFilterForFollowed,
            defaultVal: true,
            callFn: (_) => {RecommendFilter.update},
          ),
          // ListTile(
          //   dense: false,
          //   title: Text('按比例过滤未关注Up', style: titleStyle),
          //   subtitle: Text(
          //     '滤除推荐中占比「$filterUnfollowedRatio%」的未关注用户发布的内容',
          //     style: subTitleStyle,
          //   ),
          //   onTap: () async {
          //     int? result = await showDialog(
          //       context: context,
          //       builder: (context) {
          //         return SelectDialog<int>(
          //             title: '选择滤除比例（0即不过滤）',
          //             value: filterUnfollowedRatio,
          //             values: [0, 16, 32, 48, 64].map((e) {
          //               return {'title': '$e %', 'value': e};
          //             }).toList());
          //       },
          //     );
          //     if (result != null) {
          //       filterUnfollowedRatio = result;
          //       setting.put(
          //           SettingBoxKey.filterUnfollowedRatio, result);
          //       RecommendFilter.update();
          //       setState(() {});
          //     }
          //   },
          // ),
          SetSwitchItem(
            title: '过滤器也应用于相关视频',
            subTitle: '视频详情页的相关视频也进行过滤²',
            leading: const Icon(Icons.explore_outlined),
            setKey: SettingBoxKey.applyFilterToRelatedVideos,
            defaultVal: true,
            callFn: (_) => {RecommendFilter.update},
          ),
          ListTile(
            dense: true,
            subtitle: Text(
              '¹ 若默认web端推荐不太符合预期，可尝试切换至app端。\n'
              '¹ 选择“游客模式(notLogin)”，将以空的key请求app推荐接口，但播放页仍会携带用户信息，保证账号能正常记录进度、点赞投币等。\n\n'
              '² 由于接口未提供关注信息，无法豁免相关视频中的已关注Up。\n\n'
              '* 其它（如热门视频、手动搜索、链接跳转等）均不受过滤器影响。\n'
              '* 设定较严苛的条件可导致推荐项数锐减或多次请求，请酌情选择。\n'
              '* 后续可能会增加更多过滤条件，敬请期待。',
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.7)),
            ),
          )
        ],
      ),
    );
  }
}

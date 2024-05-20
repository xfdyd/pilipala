// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/constants.dart';
import 'package:PiliPalaX/common/widgets/network_img_layer.dart';
import 'package:PiliPalaX/models/common/theme_type.dart';
import 'package:PiliPalaX/models/user/info.dart';
import 'controller.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  final MineController mineController = Get.put(MineController());
  late Future _futureBuilderFuture;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = mineController.queryUserInfo();

    mineController.userLogin.listen((status) {
      if (mounted) {
        setState(() {
          _futureBuilderFuture = mineController.queryUserInfo();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        elevation: 0,
        toolbarHeight: kTextTabBarHeight + 20,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: ExcludeSemantics(
          child: Row(
            children: [
              Image.asset(
                'assets/images/logo/logo_android_2.png',
                width: 40,
              ),
              const SizedBox(width: 5),
              Text(
                'PiliPalaX',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: "${MineController.anonymity ? '退出' : '进入'}无痕模式",
            onPressed: () {
              MineController.onChangeAnonymity(context);
              setState(() {});
            },
            icon: Icon(
              MineController.anonymity
                  ? CupertinoIcons.checkmark_shield
                  : CupertinoIcons.shield_slash,
              size: 22,
            ),
          ),
          IconButton(
            tooltip:
                '切换至${mineController.themeType.value == ThemeType.dark ? '浅色' : '深色'}主题',
            onPressed: () {
              mineController.onChangeTheme();
              setState(() {});
            },
            icon: Icon(
              mineController.themeType.value == ThemeType.dark
                  ? CupertinoIcons.moon
                  : CupertinoIcons.sun_min,
              size: 22,
            ),
          ),
          IconButton(
            tooltip: '设置',
            onPressed: () => Get.toNamed('/setting', preventDuplicates: false),
            icon: const Icon(
              CupertinoIcons.gear,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              height: constraint.maxHeight,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  FutureBuilder(
                    future: _futureBuilderFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.data == null) {
                          return const SizedBox();
                        }
                        if (snapshot.data['status']) {
                          return Obx(
                              () => userInfoBuild(mineController, context));
                        } else {
                          return userInfoBuild(mineController, context);
                        }
                      } else {
                        return userInfoBuild(mineController, context);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget userInfoBuild(_mineController, context) {
    return Column(
      children: [
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () => _mineController.onLogin(),
          child: ClipOval(
            child: Container(
              width: 85,
              height: 85,
              color: Theme.of(context).colorScheme.onInverseSurface,
              child: Center(
                child: _mineController.userInfo.value.face != null
                    ? NetworkImgLayer(
                        src: _mineController.userInfo.value.face,
                        semanticsLabel: '头像',
                        width: 85,
                        height: 85)
                    : Image.asset(
                        'assets/images/noface.jpeg',
                        semanticLabel: "默认头像",
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 13),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _mineController.userInfo.value.uname ?? '点击头像登录',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 4),
            Image.asset(
              'assets/images/lv/lv${_mineController.userInfo.value.levelInfo != null ? _mineController.userInfo.value.levelInfo!.currentLevel : '0'}.png',
              height: 10,
              semanticLabel:
                  '等级：${_mineController.userInfo.value.levelInfo != null ? _mineController.userInfo.value.levelInfo!.currentLevel : '0'}',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text.rich(TextSpan(children: [
              TextSpan(
                  text: '硬币: ',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.outline)),
              TextSpan(
                  text:
                      (_mineController.userInfo.value.money ?? '-').toString(),
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary)),
            ]))
          ],
        ),
        const SizedBox(height: 22),
        if (_mineController.userInfo.value.levelInfo != null) ...[
          LayoutBuilder(
            builder: (context, BoxConstraints box) {
              LevelInfo levelInfo = _mineController.userInfo.value.levelInfo;
              return SizedBox(
                width: box.maxWidth,
                height: 24,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        color: Theme.of(context).colorScheme.primary,
                        height: 24,
                        constraints:
                            const BoxConstraints(minWidth: 100), // 设置最小宽度为100
                        width: box.maxWidth *
                            (1 - (levelInfo.currentExp! / levelInfo.nextExp!)),
                        child: Center(
                          child: Text(
                            '${levelInfo.currentExp!}/${levelInfo.nextExp!}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 12,
                            ),
                            semanticsLabel:
                                '当前经验${levelInfo.currentExp!}，升级需要${levelInfo.nextExp!}',
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 23,
                      left: 0,
                      bottom: 0,
                      child: Container(
                        width: box.maxWidth *
                            (_mineController
                                    .userInfo.value.levelInfo!.currentExp! /
                                _mineController
                                    .userInfo.value.levelInfo!.nextExp!),
                        height: 1,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        const SizedBox(height: 26),
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              TextStyle style = TextStyle(
                  fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold);
              return SizedBox(
                height: constraints.maxWidth * 0.33 * 0.6,
                child: GridView.count(
                  primary: false,
                  padding: const EdgeInsets.all(0),
                  crossAxisCount: 3,
                  childAspectRatio: 1.66,
                  children: <Widget>[
                    InkWell(
                      onTap: () => _mineController.pushDynamic(),
                      borderRadius: StyleString.mdRadius,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            child: Text(
                                (_mineController.userStat.value.dynamicCount ??
                                        '-')
                                    .toString(),
                                key: ValueKey<String>(_mineController
                                    .userStat.value.dynamicCount
                                    .toString()),
                                style: style),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '动态',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => _mineController.pushFollow(),
                      borderRadius: StyleString.mdRadius,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            child: Text(
                                (_mineController.userStat.value.following ??
                                        '-')
                                    .toString(),
                                key: ValueKey<String>(_mineController
                                    .userStat.value.following
                                    .toString()),
                                style: style),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '关注',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => _mineController.pushFans(),
                      borderRadius: StyleString.mdRadius,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            child: Text(
                                (_mineController.userStat.value.follower ?? '-')
                                    .toString(),
                                key: ValueKey<String>(_mineController
                                    .userStat.value.follower
                                    .toString()),
                                style: style),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '粉丝',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ActionItem extends StatelessWidget {
  final Icon? icon;
  final Function? onTap;
  final String? text;

  const ActionItem({
    Key? key,
    this.icon,
    this.onTap,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: StyleString.mdRadius,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon!.icon!),
          const SizedBox(height: 8),
          Text(
            text!,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/models/common/dynamic_badge_mode.dart';
import 'package:PiliPalaX/pages/dynamics/index.dart';
import 'package:PiliPalaX/pages/home/index.dart';
import 'package:PiliPalaX/pages/media/index.dart';
import 'package:PiliPalaX/utils/event_bus.dart';
import 'package:PiliPalaX/utils/feed_back.dart';
import 'package:PiliPalaX/utils/storage.dart';
import './controller.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  final MainController _mainController = Get.put(MainController());
  final HomeController _homeController = Get.put(HomeController());
  final DynamicsController _dynamicController = Get.put(DynamicsController());
  final MediaController _mediaController = Get.put(MediaController());

  int? _lastSelectTime; //上次点击时间
  Box setting = GStorage.setting;
  late bool enableMYBar;
  late bool useSideBar;
  late bool enableGradientBg;

  @override
  void initState() {
    super.initState();
    _lastSelectTime = DateTime.now().millisecondsSinceEpoch;
    _mainController.pageController =
        PageController(initialPage: _mainController.selectedIndex);
    enableMYBar = setting.get(SettingBoxKey.enableMYBar, defaultValue: true);
    useSideBar = setting.get(SettingBoxKey.useSideBar, defaultValue: false);
    enableGradientBg =
        setting.get(SettingBoxKey.enableGradientBg, defaultValue: true);
  }

  void setIndex(int value) async {
    feedBack();
    _mainController.pageController.jumpToPage(value);
    var currentPage = _mainController.pages[value];
    if (currentPage is HomePage) {
      if (_homeController.flag) {
        // 单击返回顶部 双击并刷新
        if (DateTime.now().millisecondsSinceEpoch - _lastSelectTime! < 500) {
          _homeController.onRefresh();
        } else {
          _homeController.animateToTop();
        }
        _lastSelectTime = DateTime.now().millisecondsSinceEpoch;
      }
      _homeController.flag = true;
    } else {
      _homeController.flag = false;
    }

    // if (currentPage is RankPage) {
    //   if (_rankController.flag) {
    //     // 单击返回顶部 双击并刷新
    //     if (DateTime.now().millisecondsSinceEpoch - _lastSelectTime! < 500) {
    //       _rankController.onRefresh();
    //     } else {
    //       _rankController.animateToTop();
    //     }
    //     _lastSelectTime = DateTime.now().millisecondsSinceEpoch;
    //   }
    //   _rankController.flag = true;
    // } else {
    //   _rankController.flag = false;
    // }

    if (currentPage is DynamicsPage) {
      if (_dynamicController.flag) {
        // 单击返回顶部 双击并刷新
        if (DateTime.now().millisecondsSinceEpoch - _lastSelectTime! < 500) {
          _dynamicController.onRefresh();
        } else {
          _dynamicController.animateToTop();
        }
        _lastSelectTime = DateTime.now().millisecondsSinceEpoch;
      }
      _dynamicController.flag = true;
      _mainController.clearUnread();
    } else {
      _dynamicController.flag = false;
    }

    if (currentPage is MediaPage) {
      _mediaController.queryFavFolder();
    }
  }

  @override
  void dispose() async {
    await GStorage.close();
    EventBus().off(EventName.loginEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        _mainController.onBackPressed(context);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness:
              Theme.of(context).brightness == Brightness.light
                  ? Brightness.dark
                  : Brightness.light, // 设置虚拟按键图标颜色
        ),
        child: Scaffold(
          extendBody: true,
          body: Stack(children: [
            // gradient background
            if (enableGradientBg)
              Align(
                alignment: Alignment.topLeft,
                child: Opacity(
                  opacity: 0.6,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.6),
                          Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.6),
                          Theme.of(context).colorScheme.surface
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.1, 0.4, 0.7],
                      ),
                    ),
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (useSideBar)
                  SizedBox(
                    width: context.width * 0.0387 +
                        36.801 +
                        MediaQuery.of(context).padding.left,
                    child: NavigationRail(
                      groupAlignment: 1,
                      minWidth: context.width * 0.0286 + 28.56,
                      backgroundColor: Colors.transparent,
                      selectedIndex: _mainController.selectedIndex,
                      onDestinationSelected: (value) => setIndex(value),
                      labelType: NavigationRailLabelType.none,
                      leading: UserAndSearchVertical(ctr: _homeController),
                      destinations: _mainController.navigationBars
                          .map((e) => NavigationRailDestination(
                                icon: Badge(
                                  label: _mainController.dynamicBadgeType ==
                                          DynamicBadgeMode.number
                                      ? Text(e['count'].toString())
                                      : null,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  isLabelVisible:
                                      _mainController.dynamicBadgeType !=
                                              DynamicBadgeMode.hidden &&
                                          e['count'] > 0,
                                  child: e['icon'],
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  textColor: Theme.of(context)
                                      .colorScheme
                                      .onInverseSurface,
                                ),
                                selectedIcon: e['selectIcon'],
                                label: Text(e['label']),
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.01 * context.height),
                              ))
                          .toList(),
                      trailing: SizedBox(height: 0.1 * context.height),
                    ),
                  ),
                VerticalDivider(
                  width: 1,
                  indent: MediaQuery.of(context).padding.top,
                  endIndent: MediaQuery.of(context).padding.bottom,
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.06),
                ),
                Expanded(
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _mainController.pageController,
                    onPageChanged: (index) {
                      _mainController.selectedIndex = index;
                      setState(() {});
                    },
                    children: _mainController.pages,
                  ),
                ),
                if (useSideBar) SizedBox(width: context.width * 0.004),
              ],
            )
          ]),
          bottomNavigationBar: useSideBar
              ? null
              : StreamBuilder(
                  stream: _mainController.hideTabBar
                      ? _mainController.bottomBarStream.stream
                      : StreamController<bool>.broadcast().stream,
                  initialData: true,
                  builder: (context, AsyncSnapshot snapshot) {
                    return AnimatedSlide(
                      curve: Curves.easeInOutCubicEmphasized,
                      duration: const Duration(milliseconds: 500),
                      offset: Offset(0, snapshot.data ? 0 : 1),
                      child: enableMYBar
                          ? NavigationBar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                              onDestinationSelected: (value) => setIndex(value),
                              selectedIndex: _mainController.selectedIndex,
                              destinations:
                                  _mainController.navigationBars.map((e) {
                                return NavigationDestination(
                                  icon: Badge(
                                    label: _mainController.dynamicBadgeType ==
                                            DynamicBadgeMode.number
                                        ? Text(e['count'].toString())
                                        : null,
                                    padding:
                                        const EdgeInsets.fromLTRB(6, 0, 6, 0),
                                    isLabelVisible:
                                        _mainController.dynamicBadgeType !=
                                                DynamicBadgeMode.hidden &&
                                            e['count'] > 0,
                                    child: e['icon'],
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    textColor: Theme.of(context)
                                        .colorScheme
                                        .onInverseSurface,
                                  ),
                                  selectedIcon: e['selectIcon'],
                                  label: e['label'],
                                );
                              }).toList(),
                            )
                          : BottomNavigationBar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                              currentIndex: _mainController.selectedIndex,
                              onTap: (value) => setIndex(value),
                              iconSize: 16,
                              selectedFontSize: 12,
                              unselectedFontSize: 12,
                              type: BottomNavigationBarType.fixed,
                              // selectedItemColor:
                              //     Theme.of(context).colorScheme.primary, // 选中项的颜色
                              // unselectedItemColor:
                              //     Theme.of(context).colorScheme.onSurface,
                              items: _mainController.navigationBars.map((e) {
                                return BottomNavigationBarItem(
                                  icon: Badge(
                                    label: _mainController.dynamicBadgeType ==
                                            DynamicBadgeMode.number
                                        ? Text(e['count'].toString())
                                        : null,
                                    padding:
                                        const EdgeInsets.fromLTRB(6, 0, 6, 0),
                                    isLabelVisible:
                                        _mainController.dynamicBadgeType !=
                                                DynamicBadgeMode.hidden &&
                                            e['count'] > 0,
                                    child: e['icon'],
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    textColor: Theme.of(context)
                                        .colorScheme
                                        .onInverseSurface,
                                  ),
                                  activeIcon: e['selectIcon'],
                                  label: e['label'],
                                );
                              }).toList(),
                            ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

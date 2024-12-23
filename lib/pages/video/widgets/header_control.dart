import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

// import 'package:fl_pip/fl_pip.dart';
import 'package:fl_pip/fl_pip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:PiliPalaX/http/user.dart';
import 'package:PiliPalaX/models/video/play/quality.dart';
import 'package:PiliPalaX/models/video/play/url.dart';
import 'package:PiliPalaX/pages/video/index.dart';
import 'package:PiliPalaX/pages/video/introduction/widgets/menu_row.dart';
import 'package:PiliPalaX/plugin/pl_player/index.dart';
import 'package:PiliPalaX/plugin/pl_player/models/play_repeat.dart';
import 'package:PiliPalaX/utils/storage.dart';
import 'package:PiliPalaX/http/danmaku.dart';
import 'package:PiliPalaX/services/shutdown_timer_service.dart';
import '../../../../models/video/play/CDN.dart';
import '../../../../models/video_detail_res.dart';
import '../../setting/widgets/select_dialog.dart';
import 'package:PiliPalaX/pages/video/introduction/detail/index.dart';
import 'package:marquee/marquee.dart';

class HeaderControl extends StatefulWidget implements PreferredSizeWidget {
  const HeaderControl({
    this.controller,
    this.videoDetailCtr,
    required this.heroTag,
    super.key,
  });
  final PlPlayerController? controller;
  final VideoDetailController? videoDetailCtr;
  final String heroTag;

  @override
  State<HeaderControl> createState() => _HeaderControlState();

  @override
  Size get preferredSize => throw UnimplementedError();
}

class _HeaderControlState extends State<HeaderControl> {
  late PlayUrlModel videoInfo;
  List<PlaySpeed> playSpeed = PlaySpeed.values;
  static const TextStyle subTitleStyle = TextStyle(fontSize: 12);
  static const TextStyle titleStyle = TextStyle(fontSize: 14);
  Size get preferredSize => const Size(double.infinity, kToolbarHeight);
  final Box<dynamic> localCache = GStorage.localCache;
  final Box<dynamic> videoStorage = GStorage.video;
  double buttonSpace = 8;
  // bool isFullScreen = false;
  late String heroTag;
  late VideoIntroController videoIntroController;
  late VideoDetailData videoDetail;
  // late StreamSubscription<bool> fullScreenStatusListener;
  late bool horizontalScreen;
  RxString now = ''.obs;
  late Timer clock;
  late String defaultCDNService;

  @override
  void initState() {
    super.initState();
    videoInfo = widget.videoDetailCtr!.data;
    // listenFullScreenStatus();
    heroTag = widget.heroTag;
    // if (Get.arguments != null && Get.arguments['heroTag'] != null) {
    //   heroTag = Get.arguments['heroTag'];
    // }
    videoIntroController = Get.put(VideoIntroController(), tag: heroTag);
    horizontalScreen =
        setting.get(SettingBoxKey.horizontalScreen, defaultValue: false);
    defaultCDNService = setting.get(SettingBoxKey.CDNService,
        defaultValue: CDNService.backupUrl.code);
    startClock();
  }

  // void listenFullScreenStatus() {
  //   // fullScreenStatusListener = widget
  //   //     .videoDetailCtr!.plPlayerController!.isFullScreen
  //   fullScreenStatusListener =
  //       widget.controller!.isFullScreen.listen((bool status) {
  //     isFullScreen = status;
  //
  //     /// TODO setState() called after dispose()
  //     if (mounted) {
  //       setState(() {});
  //     }
  //   });
  // }

  @override
  void dispose() {
    // widget.floating?.dispose();
    // fullScreenStatusListener.cancel();
    clock.cancel();
    super.dispose();
  }

  /// 设置面板
  void showSettingSheet() {
    showModalBottomSheet(
      elevation: 0,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          width: double.infinity,
          height: 500,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          margin: const EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 35,
                child: Center(
                  child: Container(
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer
                            .withOpacity(0.5),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(3))),
                  ),
                ),
              ),
              Expanded(
                  child: Material(
                child: ListView(
                  children: [
                    // ListTile(
                    //   onTap: () {},
                    //   dense: true,
                    //   enabled: false,
                    //   leading:
                    //       const Icon(Icons.network_cell_outlined, size: 20),
                    //   title: Text('省流模式', style: titleStyle),
                    //   subtitle: Text('低画质 ｜ 减少视频缓存', style: subTitleStyle),
                    //   trailing: Transform.scale(
                    //     scale: 0.75,
                    //     child: Switch(
                    //       thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                    //           (Set<MaterialState> states) {
                    //         if (states.isNotEmpty &&
                    //             states.first == MaterialState.selected) {
                    //           return const Icon(Icons.done);
                    //         }
                    //         return null; // All other states will use the default thumbIcon.
                    //       }),
                    //       value: false,
                    //       onChanged: (value) => {},
                    //     ),
                    //   ),
                    // ),
                    ListTile(
                      onTap: () async {
                        final res = await UserHttp.toViewLater(
                            bvid: widget.videoDetailCtr!.bvid);
                        SmartDialog.showToast(res['msg']);
                        Get.back();
                      },
                      dense: true,
                      leading: const Icon(Icons.watch_later_outlined, size: 20),
                      title: const Text('添加至「稍后再看」', style: titleStyle),
                    ),
                    ListTile(
                      onTap: () => {Get.back(), scheduleExit()},
                      dense: true,
                      leading:
                          const Icon(Icons.hourglass_top_outlined, size: 20),
                      title: const Text('定时关闭', style: titleStyle),
                    ),
                    ListTile(
                      onTap: () =>
                          {Get.back(), widget.videoDetailCtr!.queryVideoUrl()},
                      dense: true,
                      leading: const Icon(Icons.refresh_outlined, size: 20),
                      title: const Text('重载视频', style: titleStyle),
                    ),
                    ListTile(
                      title: const Text('CDN 设置', style: titleStyle),
                      leading: Icon(MdiIcons.cloudPlusOutline, size: 20),
                      subtitle: Text(
                        '当前：${CDNServiceCode.fromCode(defaultCDNService)!.description}，无法播放请切换',
                        style: subTitleStyle,
                      ),
                      onTap: () async {
                        Get.back();
                        String? result = await showDialog(
                          context: context,
                          builder: (context) {
                            return SelectDialog<String>(
                                title: 'CDN 设置',
                                value: defaultCDNService,
                                values: CDNService.values.map((e) {
                                  return {
                                    'title': e.description,
                                    'value': e.code
                                  };
                                }).toList());
                          },
                        );
                        if (result != null) {
                          defaultCDNService = result;
                          setting.put(SettingBoxKey.CDNService, result);
                          SmartDialog.showToast(
                              '已设置为 ${CDNServiceCode.fromCode(result)!.description}，正在重载视频');
                          setState(() {});
                          widget.videoDetailCtr!.queryVideoUrl();
                        }
                      },
                    ),
                    ListTile(
                      onTap: () {
                        Get.back();
                      },
                      dense: true,
                      leading:
                          const Icon(Icons.switch_video_outlined, size: 20),
                      title: const Text('功能', style: titleStyle),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Obx(
                            () => ActionRowLineItem(
                              key: const Key('onlyPlayAudio'),
                              onTap: () {
                                widget.controller!.setOnlyPlayAudio(null);
                              },
                              text: " 听视频 ",
                              selectStatus:
                                  widget.controller!.onlyPlayAudio.value,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // const SizedBox(width: 10),
                          Obx(
                            () => ActionRowLineItem(
                              key: const Key('continuePlayInBackground'),
                              onTap: () {
                                widget.controller!
                                    .setContinuePlayInBackground(null);
                              },
                              text: " 后台播放 ",
                              selectStatus: widget
                                  .controller!.continuePlayInBackground.value,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      onTap: () => {Get.back(), showSetVideoQa()},
                      dense: true,
                      leading: const Icon(Icons.play_circle_outline, size: 20),
                      title: const Text('选择画质', style: titleStyle),
                      subtitle: Text(
                          '当前画质 ${widget.videoDetailCtr!.currentVideoQa.description}',
                          style: subTitleStyle),
                    ),
                    if (widget.videoDetailCtr!.currentAudioQa != null)
                      ListTile(
                        onTap: () => {Get.back(), showSetAudioQa()},
                        dense: true,
                        leading: const Icon(Icons.album_outlined, size: 20),
                        title: const Text('选择音质', style: titleStyle),
                        subtitle: Text(
                            '当前音质 ${widget.videoDetailCtr!.currentAudioQa!.description}',
                            style: subTitleStyle),
                      ),
                    ListTile(
                      onTap: () => {Get.back(), showSetDecodeFormats()},
                      dense: true,
                      leading: const Icon(Icons.av_timer_outlined, size: 20),
                      title: const Text('解码格式', style: titleStyle),
                      subtitle: Text(
                          '当前解码格式 ${widget.videoDetailCtr!.currentDecodeFormats.description}',
                          style: subTitleStyle),
                    ),
                    ListTile(
                      onTap: () => {Get.back(), showSetRepeat()},
                      dense: true,
                      leading: const Icon(Icons.repeat, size: 20),
                      title: const Text('播放顺序', style: titleStyle),
                      subtitle: Text(widget.controller!.playRepeat.description,
                          style: subTitleStyle),
                    ),
                    ListTile(
                      onTap: () => {Get.back(), showSetDanmaku()},
                      dense: true,
                      leading: const Icon(Icons.subtitles_outlined, size: 20),
                      title: const Text('弹幕设置', style: titleStyle),
                    ),
                    ListTile(
                        title: const Text('播放信息', style: titleStyle),
                        leading: const Icon(Icons.info_outline, size: 20),
                        onTap: () {
                          Player? player =
                              widget.controller?.videoPlayerController;
                          if (player == null) {
                            SmartDialog.showToast('播放器未初始化');
                            return;
                          }
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('播放信息'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ListView(
                                    children: [
                                      ListTile(
                                        title: const Text("Resolution"),
                                        subtitle: Text(
                                            '${player.state.width}x${player.state.height}'),
                                        onTap: () {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text:
                                                  "Resolution\n${player.state.width}x${player.state.height}",
                                            ),
                                          );
                                        },
                                      ),
                                      ListTile(
                                        title: const Text("VideoParams"),
                                        subtitle: Text(player.state.videoParams
                                            .toString()),
                                        onTap: () {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text:
                                                  "VideoParams\n${player.state.videoParams}",
                                            ),
                                          );
                                        },
                                      ),
                                      ListTile(
                                        title: const Text("AudioParams"),
                                        subtitle: Text(player.state.audioParams
                                            .toString()),
                                        onTap: () {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text:
                                                  "AudioParams\n${player.state.audioParams}",
                                            ),
                                          );
                                        },
                                      ),
                                      ListTile(
                                        title: const Text("Media"),
                                        subtitle: Text(
                                            player.state.playlist.toString()),
                                        onTap: () {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text:
                                                  "Media\n${player.state.playlist}",
                                            ),
                                          );
                                        },
                                      ),
                                      ListTile(
                                        title: const Text("AudioTrack"),
                                        subtitle: Text(player.state.track.audio
                                            .toString()),
                                        onTap: () {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text:
                                                  "AudioTrack\n${player.state.track.audio}",
                                            ),
                                          );
                                        },
                                      ),
                                      ListTile(
                                        title: const Text("VideoTrack"),
                                        subtitle: Text(player.state.track.video
                                            .toString()),
                                        onTap: () {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text:
                                                  "VideoTrack\n${player.state.track.video}",
                                            ),
                                          );
                                        },
                                      ),
                                      ListTile(
                                          title: const Text("pitch"),
                                          subtitle: Text(
                                              player.state.pitch.toString()),
                                          onTap: () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                text:
                                                    "pitch\n${player.state.pitch}",
                                              ),
                                            );
                                          }),
                                      ListTile(
                                          title: const Text("rate"),
                                          subtitle: Text(
                                              player.state.rate.toString()),
                                          onTap: () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                text:
                                                    "rate\n${player.state.rate}",
                                              ),
                                            );
                                          }),
                                      ListTile(
                                        title: const Text("AudioBitrate"),
                                        subtitle: Text(player.state.audioBitrate
                                            .toString()),
                                        onTap: () {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text:
                                                  "AudioBitrate\n${player.state.audioBitrate}",
                                            ),
                                          );
                                        },
                                      ),
                                      ListTile(
                                        title: const Text("Volume"),
                                        subtitle: Text(
                                            player.state.volume.toString()),
                                        onTap: () {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text:
                                                  "Volume\n${player.state.volume}",
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: Text(
                                      '确定',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        })
                  ],
                ),
              ))
            ],
          ),
        );
      },
      clipBehavior: Clip.hardEdge,
      isScrollControlled: true,
    );
  }

  /// 发送弹幕
  void showShootDanmakuSheet() {
    final TextEditingController textController = TextEditingController();
    bool isSending = false; // 追踪是否正在发送
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        // TODO: 支持更多类型和颜色的弹幕
        return AlertDialog(
          title: const Text('发送弹幕'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return TextField(
              controller: textController,
            );
          }),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                '取消',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return TextButton(
                onPressed: isSending
                    ? null
                    : () async {
                        final String msg = textController.text;
                        if (msg.isEmpty) {
                          SmartDialog.showToast('弹幕内容不能为空');
                          return;
                        } else if (msg.length > 100) {
                          SmartDialog.showToast('弹幕内容不能超过100个字符');
                          return;
                        }
                        setState(() {
                          isSending = true; // 开始发送，更新状态
                        });
                        //修改按钮文字
                        // SmartDialog.showToast('弹幕发送中,\n$msg');
                        final dynamic res = await DanmakaHttp.shootDanmaku(
                          oid: widget.videoDetailCtr!.cid.value,
                          msg: textController.text,
                          bvid: widget.videoDetailCtr!.bvid,
                          progress:
                              widget.controller!.position.value.inMilliseconds,
                          type: 1,
                        );
                        setState(() {
                          isSending = false; // 发送结束，更新状态
                        });
                        if (res['status']) {
                          SmartDialog.showToast('发送成功');
                          // 发送成功，自动预览该弹幕，避免重新请求
                          // TODO: 暂停状态下预览弹幕仍会移动与计时，可考虑添加到dmSegList或其他方式实现
                          widget.controller!.danmakuController!.addDanmaku(
                              DanmakuContentItem(msg,
                                  color: Colors.white,
                                  type: DanmakuItemType.scroll,
                                  selfSend: true));
                          Get.back();
                        } else {
                          SmartDialog.showToast('发送失败，错误信息为${res['msg']}');
                        }
                      },
                child: Text(isSending ? '发送中...' : '发送'),
              );
            })
          ],
        );
      },
    );
  }

  /// 定时关闭
  void scheduleExit() async {
    const List<int> scheduleTimeChoices = [
      -1,
      15,
      30,
      45,
      60,
    ];
    showModalBottomSheet(
      context: context,
      elevation: 0,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            width: double.infinity,
            height: 500,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.only(left: 14, right: 14),
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 30),
                      const Center(child: Text('定时关闭', style: titleStyle)),
                      const SizedBox(height: 10),
                      for (final int choice in scheduleTimeChoices) ...<Widget>[
                        ListTile(
                          onTap: () {
                            shutdownTimerService.scheduledExitInMinutes =
                                choice;
                            shutdownTimerService.startShutdownTimer();
                            Get.back();
                          },
                          contentPadding: const EdgeInsets.only(),
                          dense: true,
                          title: Text(choice == -1 ? "禁用" : "$choice分钟后"),
                          trailing: shutdownTimerService
                                      .scheduledExitInMinutes ==
                                  choice
                              ? Icon(
                                  Icons.done,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : const SizedBox(),
                        )
                      ],
                      const SizedBox(height: 6),
                      const Center(
                          child: SizedBox(
                        width: 100,
                        child: Divider(height: 1),
                      )),
                      const SizedBox(height: 10),
                      ListTile(
                        onTap: () {
                          shutdownTimerService.waitForPlayingCompleted =
                              !shutdownTimerService.waitForPlayingCompleted;
                          setState(() {});
                        },
                        dense: true,
                        contentPadding: const EdgeInsets.only(),
                        title: const Text("额外等待视频播放完毕", style: titleStyle),
                        trailing: Switch(
                          // thumb color (round icon)
                          activeColor: Theme.of(context).colorScheme.primary,
                          activeTrackColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          inactiveThumbColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          inactiveTrackColor:
                              Theme.of(context).colorScheme.background,
                          splashRadius: 10.0,
                          // boolean variable value
                          value: shutdownTimerService.waitForPlayingCompleted,
                          // changes the state of the switch
                          onChanged: (value) => setState(() =>
                              shutdownTimerService.waitForPlayingCompleted =
                                  value),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          const Text('倒计时结束:', style: titleStyle),
                          const Spacer(),
                          ActionRowLineItem(
                            onTap: () {
                              shutdownTimerService.exitApp = false;
                              setState(() {});
                              // Get.back();
                            },
                            text: " 暂停视频 ",
                            selectStatus: !shutdownTimerService.exitApp,
                          ),
                          const Spacer(),
                          // const SizedBox(width: 10),
                          ActionRowLineItem(
                            onTap: () {
                              shutdownTimerService.exitApp = true;
                              setState(() {});
                              // Get.back();
                            },
                            text: " 退出APP ",
                            selectStatus: shutdownTimerService.exitApp,
                          )
                        ],
                      ),
                    ]),
              ),
            ),
          );
        });
      },
    );
  }

  /// 选择画质
  void showSetVideoQa() {
    if (videoInfo.dash == null) {
      SmartDialog.showToast('当前视频不支持选择画质');
      return;
    }
    final List<FormatItem> videoFormat = videoInfo.supportFormats!;
    final VideoQuality currentVideoQa = widget.videoDetailCtr!.currentVideoQa;

    /// 总质量分类
    final int totalQaSam = videoFormat.length;

    /// 可用的质量分类
    int userfulQaSam = 0;
    final List<VideoItem> video = videoInfo.dash!.video!;
    final Set<int> idSet = {};
    for (final VideoItem item in video) {
      final int id = item.id!;
      if (!idSet.contains(id)) {
        idSet.add(id);
        userfulQaSam++;
      }
    }

    showModalBottomSheet(
      context: context,
      elevation: 0,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          height: 310,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          margin: const EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 45,
                child: GestureDetector(
                  onTap: () {
                    SmartDialog.showToast(
                        '标灰画质需要bilibili会员（已是会员？请关闭无痕模式）；4k和杜比视界播放效果可能不佳');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('选择画质', style: titleStyle),
                      SizedBox(width: buttonSpace),
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.outline,
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Material(
                  child: Scrollbar(
                    child: ListView(
                      children: [
                        for (int i = 0; i < totalQaSam; i++) ...[
                          ListTile(
                            onTap: () {
                              if (currentVideoQa.code ==
                                  videoFormat[i].quality) {
                                return;
                              }
                              final int quality = videoFormat[i].quality!;
                              widget.videoDetailCtr!.currentVideoQa =
                                  VideoQualityCode.fromCode(quality)!;
                              String oldQualityDesc = VideoQualityCode.fromCode(
                                      setting.get(SettingBoxKey.defaultVideoQa,
                                          defaultValue:
                                              VideoQuality.values.last.code))!
                                  .description;
                              setting.put(
                                  SettingBoxKey.defaultVideoQa, quality);
                              SmartDialog.showToast(
                                  "默认画质由：$oldQualityDesc 变为：${VideoQualityCode.fromCode(quality)!.description}");
                              widget.videoDetailCtr!.updatePlayer();
                              Get.back();
                            },
                            dense: true,
                            // 可能包含会员解锁画质
                            enabled: i >= totalQaSam - userfulQaSam,
                            contentPadding:
                                const EdgeInsets.only(left: 20, right: 20),
                            title: Text(videoFormat[i].newDesc!),
                            trailing: currentVideoQa.code ==
                                    videoFormat[i].quality
                                ? Icon(
                                    Icons.done,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  )
                                : Text(
                                    videoFormat[i].format!,
                                    style: subTitleStyle,
                                  ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 选择音质
  void showSetAudioQa() {
    final AudioQuality currentAudioQa = widget.videoDetailCtr!.currentAudioQa!;
    final List<AudioItem> audio = videoInfo.dash!.audio!;
    showModalBottomSheet(
      context: context,
      elevation: 0,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          height: 250,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          margin: const EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              const SizedBox(
                  height: 45,
                  child: Center(child: Text('选择音质', style: titleStyle))),
              Expanded(
                child: Material(
                  child: ListView(
                    children: <Widget>[
                      for (final AudioItem i in audio) ...<Widget>[
                        ListTile(
                          onTap: () {
                            if (currentAudioQa.code == i.id) {
                              return;
                            }
                            final int quality = i.id!;
                            widget.videoDetailCtr!.currentAudioQa =
                                AudioQualityCode.fromCode(quality)!;
                            String oldQualityDesc = AudioQualityCode.fromCode(
                                    setting.get(SettingBoxKey.defaultAudioQa,
                                        defaultValue:
                                            AudioQuality.values.last.code))!
                                .description;
                            setting.put(SettingBoxKey.defaultAudioQa, quality);
                            SmartDialog.showToast(
                                "默认音质由：$oldQualityDesc 变为：${AudioQualityCode.fromCode(quality)!.description}");
                            widget.videoDetailCtr!.updatePlayer();
                            Get.back();
                          },
                          dense: true,
                          contentPadding:
                              const EdgeInsets.only(left: 20, right: 20),
                          title: Text(i.quality!),
                          subtitle: Text(
                            i.codecs!,
                            style: subTitleStyle,
                          ),
                          trailing: currentAudioQa.code == i.id
                              ? Icon(
                                  Icons.done,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : const SizedBox(),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 选择解码格式
  void showSetDecodeFormats() {
    // 当前选中的解码格式
    final VideoDecodeFormats currentDecodeFormats =
        widget.videoDetailCtr!.currentDecodeFormats;
    final VideoItem firstVideo = widget.videoDetailCtr!.firstVideo;
    // 当前视频可用的解码格式
    final List<FormatItem> videoFormat = videoInfo.supportFormats!;
    final List? list = videoFormat
        .firstWhere((FormatItem e) => e.quality == firstVideo.quality!.code)
        .codecs;
    if (list == null) {
      SmartDialog.showToast('当前视频不支持选择解码格式');
      return;
    }

    showModalBottomSheet(
      context: context,
      elevation: 0,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          height: 250,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          margin: const EdgeInsets.all(12),
          child: Column(
            children: [
              const SizedBox(
                  height: 45,
                  child: Center(child: Text('选择解码格式', style: titleStyle))),
              Expanded(
                child: Material(
                  child: ListView(
                    children: [
                      for (var i in list) ...[
                        ListTile(
                          onTap: () {
                            if (i.startsWith(currentDecodeFormats.code)) return;
                            widget.videoDetailCtr!.currentDecodeFormats =
                                VideoDecodeFormatsCode.fromString(i)!;
                            widget.videoDetailCtr!.updatePlayer();
                            Get.back();
                          },
                          dense: true,
                          contentPadding:
                              const EdgeInsets.only(left: 20, right: 20),
                          title: Text(VideoDecodeFormatsCode.fromString(i)!
                              .description!),
                          subtitle: Text(
                            i!,
                            style: subTitleStyle,
                          ),
                          trailing: i.startsWith(currentDecodeFormats.code)
                              ? Icon(
                                  Icons.done,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : const SizedBox(),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 弹幕功能
  void showSetDanmaku() async {
    // 屏蔽类型
    final List<Map<String, dynamic>> blockTypesList = [
      {'value': 5, 'label': '顶部'},
      {'value': 2, 'label': '滚动'},
      {'value': 4, 'label': '底部'},
      {'value': 6, 'label': '彩色'},
    ];
    final List blockTypes = widget.controller!.blockTypes;
    // 显示区域
    final List<Map<String, dynamic>> showAreas = [
      {'value': 0.25, 'label': '1/4'},
      {'value': 0.5, 'label': '半屏'},
      {'value': 0.75, 'label': '3/4'},
      {'value': 1.0, 'label': '满屏'},
    ];
    // 智能云屏蔽
    int danmakuWeight = widget.controller!.danmakuWeight.value;
    // 显示区域
    double showArea = widget.controller!.showArea;
    // 不透明度
    double opacityVal = widget.controller!.opacityVal;
    // 字体大小
    double fontSizeVal = widget.controller!.fontSizeVal;
    // 弹幕速度
    int danmakuDurationVal = widget.controller!.danmakuDurationVal;
    // 弹幕描边
    double strokeWidth = widget.controller!.strokeWidth;
    // 字体粗细
    int fontWeight = widget.controller!.fontWeight;
    // 海量模式
    bool massiveMode = widget.controller!.massiveMode;

    final DanmakuController danmakuController =
        widget.controller!.danmakuController!;
    await showModalBottomSheet(
      context: context,
      elevation: 0,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            width: double.infinity,
            height: 580,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.only(left: 14, right: 14),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 45,
                    child: Center(child: Text('弹幕设置', style: titleStyle)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('智能云屏蔽 $danmakuWeight 级'),
                      const Spacer(),
                      TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => {
                                Get.back(),
                                Get.toNamed('/danmakuBlock',
                                    arguments: widget.controller)
                              },
                          child: Text(
                              "屏蔽管理(${widget.controller!.danmakuFilterRule.value.length})")),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 0,
                      bottom: 6,
                      left: 10,
                      right: 10,
                    ),
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackShape: MSliderTrackShape(),
                        thumbColor: Theme.of(context).colorScheme.primary,
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        trackHeight: 10,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6.0),
                      ),
                      child: Slider(
                        min: 0,
                        max: 10,
                        value: danmakuWeight.toDouble(),
                        divisions: 10,
                        label: '$danmakuWeight',
                        onChanged: (double val) {
                          danmakuWeight = val.toInt();
                          widget.controller!.danmakuWeight.value =
                              danmakuWeight;
                          widget.controller!.putDanmakuSettings();
                          setState(() {});
                          // try {
                          //   final DanmakuOption currentOption =
                          //       danmakuController.option;
                          //   final DanmakuOption updatedOption =
                          //   currentOption.copyWith(strokeWidth: val);
                          //   danmakuController.updateOption(updatedOption);
                          // } catch (_) {}
                        },
                      ),
                    ),
                  ),
                  const Text('按类型屏蔽'),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 18),
                    child: Row(
                      children: <Widget>[
                        for (final Map<String, dynamic> i
                            in blockTypesList) ...<Widget>[
                          ActionRowLineItem(
                            onTap: () async {
                              final bool isChoose =
                                  blockTypes.contains(i['value']);
                              if (isChoose) {
                                blockTypes.remove(i['value']);
                              } else {
                                blockTypes.add(i['value']);
                              }
                              widget.controller!.blockTypes = blockTypes;
                              widget.controller?.putDanmakuSettings();
                              setState(() {});
                              try {
                                final DanmakuOption currentOption =
                                    danmakuController.option;
                                final DanmakuOption updatedOption =
                                    currentOption.copyWith(
                                  hideTop: blockTypes.contains(5),
                                  hideBottom: blockTypes.contains(4),
                                  hideScroll: blockTypes.contains(2),
                                  // 添加或修改其他需要修改的选项属性
                                );
                                danmakuController.updateOption(updatedOption);
                              } catch (_) {}
                            },
                            text: i['label'],
                            selectStatus: blockTypes.contains(i['value']),
                          ),
                          const SizedBox(width: 10),
                        ]
                      ],
                    ),
                  ),
                  const Text('显示区域'),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 18),
                    child: Row(
                      children: [
                        for (final Map<String, dynamic> i in showAreas) ...[
                          ActionRowLineItem(
                            onTap: () {
                              showArea = i['value'];
                              widget.controller!.showArea = showArea;
                              widget.controller?.putDanmakuSettings();
                              setState(() {});
                              try {
                                final DanmakuOption currentOption =
                                    danmakuController.option;
                                final DanmakuOption updatedOption =
                                    currentOption.copyWith(area: i['value']);
                                danmakuController.updateOption(updatedOption);
                              } catch (_) {}
                            },
                            text: i['label'],
                            selectStatus: showArea == i['value'],
                          ),
                          const SizedBox(width: 10),
                        ],
                        const Spacer(),
                        ActionRowLineItem(
                          key: const Key('massiveMode'),
                          onTap: () {
                            massiveMode = !massiveMode;
                            widget.controller!.massiveMode = massiveMode;
                            widget.controller?.putDanmakuSettings();
                            setState(() {});
                            try {
                              final DanmakuOption currentOption =
                                  danmakuController.option;
                              final DanmakuOption updatedOption = currentOption
                                  .copyWith(massiveMode: massiveMode);
                              danmakuController.updateOption(updatedOption);
                            } catch (_) {}
                          },
                          text: "允许重叠",
                          selectStatus: massiveMode,
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                  Text('不透明度 ${opacityVal * 100}%'),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 0,
                      bottom: 6,
                      left: 10,
                      right: 10,
                    ),
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackShape: MSliderTrackShape(),
                        thumbColor: Theme.of(context).colorScheme.primary,
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        trackHeight: 10,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6.0),
                      ),
                      child: Slider(
                        min: 0,
                        max: 1,
                        value: opacityVal,
                        divisions: 10,
                        label: '${opacityVal * 100}%',
                        onChanged: (double val) {
                          opacityVal = val;
                          widget.controller!.opacityVal = opacityVal;
                          widget.controller?.putDanmakuSettings();
                          setState(() {});
                          try {
                            final DanmakuOption currentOption =
                                danmakuController.option;
                            final DanmakuOption updatedOption =
                                currentOption.copyWith(opacity: val);
                            danmakuController.updateOption(updatedOption);
                          } catch (_) {}
                        },
                      ),
                    ),
                  ),
                  Text('字体粗细 ${fontWeight + 1}（可能无法精确调节）'),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 0,
                      bottom: 6,
                      left: 10,
                      right: 10,
                    ),
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackShape: MSliderTrackShape(),
                        thumbColor: Theme.of(context).colorScheme.primary,
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        trackHeight: 10,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6.0),
                      ),
                      child: Slider(
                        min: 0,
                        max: 8,
                        value: fontWeight.toDouble(),
                        divisions: 8,
                        label: '${fontWeight + 1}',
                        onChanged: (double val) {
                          fontWeight = val.toInt();
                          widget.controller!.fontWeight = fontWeight;
                          widget.controller?.putDanmakuSettings();
                          setState(() {});
                          try {
                            final DanmakuOption currentOption =
                                danmakuController.option;
                            final DanmakuOption updatedOption =
                                currentOption.copyWith(fontWeight: fontWeight);
                            danmakuController.updateOption(updatedOption);
                          } catch (_) {}
                        },
                      ),
                    ),
                  ),
                  Text('描边粗细 $strokeWidth'),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 0,
                      bottom: 6,
                      left: 10,
                      right: 10,
                    ),
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackShape: MSliderTrackShape(),
                        thumbColor: Theme.of(context).colorScheme.primary,
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        trackHeight: 10,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6.0),
                      ),
                      child: Slider(
                        min: 0,
                        max: 3,
                        value: strokeWidth,
                        divisions: 6,
                        label: '$strokeWidth',
                        onChanged: (double val) {
                          strokeWidth = val;
                          widget.controller!.strokeWidth = val;
                          widget.controller?.putDanmakuSettings();
                          setState(() {});
                          try {
                            final DanmakuOption currentOption =
                                danmakuController.option;
                            final DanmakuOption updatedOption =
                                currentOption.copyWith(strokeWidth: val);
                            danmakuController.updateOption(updatedOption);
                          } catch (_) {}
                        },
                      ),
                    ),
                  ),
                  Text('字体大小 ${(fontSizeVal * 100).toStringAsFixed(1)}%'),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 0,
                      bottom: 6,
                      left: 10,
                      right: 10,
                    ),
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackShape: MSliderTrackShape(),
                        thumbColor: Theme.of(context).colorScheme.primary,
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        trackHeight: 10,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6.0),
                      ),
                      child: Slider(
                        min: 0.5,
                        max: 2.5,
                        value: fontSizeVal,
                        divisions: 20,
                        label: '${(fontSizeVal * 100).toStringAsFixed(1)}%',
                        onChanged: (double val) {
                          fontSizeVal = val;
                          widget.controller!.fontSizeVal = fontSizeVal;
                          widget.controller?.putDanmakuSettings();
                          setState(() {});
                          try {
                            final DanmakuOption currentOption =
                                danmakuController.option;
                            final DanmakuOption updatedOption =
                                currentOption.copyWith(
                              fontSize: (15 * fontSizeVal).toDouble(),
                            );
                            danmakuController.updateOption(updatedOption);
                          } catch (_) {}
                        },
                      ),
                    ),
                  ),
                  Text('弹幕时长 $danmakuDurationVal 秒'),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 0,
                      bottom: 6,
                      left: 10,
                      right: 10,
                    ),
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackShape: MSliderTrackShape(),
                        thumbColor: Theme.of(context).colorScheme.primary,
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        trackHeight: 10,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6.0),
                      ),
                      child: Slider(
                        min: 1.2,
                        max: 4,
                        value: pow(danmakuDurationVal, 1 / 4) as double,
                        divisions: 28,
                        label: danmakuDurationVal.toString(),
                        onChanged: (double val) {
                          danmakuDurationVal = (pow(val, 4) as double).round();
                          widget.controller!.danmakuDurationVal =
                              danmakuDurationVal;
                          widget.controller?.putDanmakuSettings();
                          setState(() {});
                          try {
                            final DanmakuOption updatedOption =
                                danmakuController.option.copyWith(
                                    duration: (danmakuDurationVal /
                                            widget.controller!.playbackSpeed)
                                        .round());
                            danmakuController.updateOption(updatedOption);
                          } catch (_) {}
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  /// 播放顺序
  void showSetRepeat() async {
    showModalBottomSheet(
      context: context,
      elevation: 0,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          height: 300,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          margin: const EdgeInsets.all(12),
          child: Column(
            children: [
              const SizedBox(
                  height: 45,
                  child: Center(child: Text('选择播放顺序', style: titleStyle))),
              Expanded(
                child: Material(
                  child: ListView(
                    children: <Widget>[
                      for (final PlayRepeat i in PlayRepeat.values) ...[
                        ListTile(
                          onTap: () {
                            widget.controller!.setPlayRepeat(i);
                            Get.back();
                          },
                          dense: true,
                          contentPadding:
                              const EdgeInsets.only(left: 20, right: 20),
                          title: Text(i.description),
                          trailing: widget.controller!.playRepeat == i
                              ? Icon(
                                  Icons.done,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : const SizedBox(),
                        )
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  startClock() {
    clock = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) {
        return;
      }
      now.value = DateTime.now().toString().split(' ')[1].substring(0, 5);
    });
  }

  Widget shootDanmakuButton() {
    return SizedBox(
      width: 42,
      height: 34,
      child: IconButton(
        tooltip: '发弹幕',
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
        ),
        onPressed: () => showShootDanmakuSheet(),
        icon: Icon(
          MdiIcons.pencilPlusOutline,
          size: 21,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget danmakuSwitcher() {
    return SizedBox(
      width: 42,
      height: 34,
      child: Obx(
        () => IconButton(
          tooltip: "${widget.controller!.isOpenDanmu.value ? '关闭' : '开启'}弹幕",
          style: ButtonStyle(
            padding: WidgetStateProperty.all(EdgeInsets.zero),
          ),
          onPressed: () {
            widget.controller!.isOpenDanmu.value =
                !widget.controller!.isOpenDanmu.value;
            setting.put(SettingBoxKey.enableShowDanmaku,
                widget.controller!.isOpenDanmu.value);
            SmartDialog.showToast(
                "已${widget.controller!.isOpenDanmu.value ? '开启' : '关闭'}弹幕",
                displayTime: const Duration(seconds: 1));
          },
          icon: Icon(
            widget.controller!.isOpenDanmu.value
                ? Icons.subtitles_outlined
                : Icons.subtitles_off_outlined,
            size: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget pipButton() {
    return SizedBox(
      width: 42,
      height: 34,
      child: IconButton(
        tooltip: '画中画',
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
        ),
        onPressed: () async {
          Player? player = widget.controller?.videoPlayerController;
          if (player == null) {
            SmartDialog.showToast('播放器未初始化');
            return;
          }
          print(widget.controller!.dataSource.videoSource);
          print(widget.controller!.dataSource.audioSource);
          widget.controller!.controls = false;
          FlPiP().enable(
            ios: FlPiPiOSConfig(
                videoPath: widget.videoDetailCtr!.videoUrl,
                audioPath: widget.videoDetailCtr!.audioUrl,
                packageName: null),
            android: FlPiPAndroidConfig(
              aspectRatio: Rational(
                widget.videoDetailCtr!.data.dash!.video!.first.width!,
                widget.videoDetailCtr!.data.dash!.video!.first.height!,
              ),
            ),
          );
        },
        icon: Icon(
          MdiIcons.pictureInPictureBottomRight,
          size: 21.5,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget likeVideoButton() {
    return SizedBox(
      width: 42,
      height: 34,
      child: IconButton(
        tooltip: videoIntroController.hasLike.value ? '已点赞' : '点赞',
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
        ),
        onPressed: () async {
          videoIntroController.actionLikeVideo();
        },
        icon: Obx(() => Icon(
              videoIntroController.hasLike.value
                  ? Icons.thumb_up
                  : Icons.thumb_up_outlined,
              size: 22,
              color: Colors.white,
            )),
      ),
    );
  }

  Widget coinVideoButton() {
    return SizedBox(
      width: 42,
      height: 34,
      child: IconButton(
        tooltip: videoIntroController.hasCoin.value ? '已投币' : '投币',
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
        ),
        onPressed: () async {
          videoIntroController.actionCoinVideo();
        },
        icon: Obx(() => Icon(
              videoIntroController.hasCoin.value
                  ? Icons.offline_bolt
                  : Icons.offline_bolt_outlined,
              size: 23,
              color: Colors.white,
            )),
      ),
    );
  }

  Widget shareButton() {
    return SizedBox(
      width: 42,
      height: 34,
      child: IconButton(
        tooltip: '分享',
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
        ),
        onPressed: () async {
          videoIntroController.actionShareVideo();
        },
        icon: const Icon(
          Icons.share,
          size: 22,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool equivalentFullScreen() =>
          !widget.controller!.isFullScreen.value &&
          !horizontalScreen &&
          MediaQuery.of(context).orientation == Orientation.landscape;
      return AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        primary: false,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 10,
        toolbarHeight:
            widget.controller!.isFullScreen.value || equivalentFullScreen()
                ? 100
                : null,
        title: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Row(
            children: [
              SizedBox(
                width: 42,
                height: 34,
                child: IconButton(
                  tooltip: '上一页',
                  icon: const Icon(
                    FontAwesomeIcons.arrowLeft,
                    size: 15,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (widget.controller!.isFullScreen.value) {
                      widget.controller!.triggerFullScreen(status: false);
                    } else if (MediaQuery.of(context).orientation ==
                            Orientation.landscape &&
                        !horizontalScreen) {
                      verticalScreenForTwoSeconds();
                    } else {
                      Get.back();
                    }
                  },
                ),
              ),
              SizedBox(
                width: 42,
                height: 34,
                child: IconButton(
                  tooltip: '返回主页',
                  icon: const Icon(
                    FontAwesomeIcons.house,
                    size: 15,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    // 销毁播放器实例
                    // await widget.controller!.dispose();
                    if (mounted) {
                      // Navigator.popUntil(
                      //     context, (Route<dynamic> route) => route.isFirst);
                      if (Get.previousRoute == '/') {
                        Get.back();
                        return;
                      }
                      Get.offAllNamed('/');
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              if ((videoIntroController.videoDetail.value.title != null) &&
                  (widget.controller!.isFullScreen.value ||
                      equivalentFullScreen()))
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        videoIntroController.videoDetail.value.title!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      if (videoIntroController.isShowOnlineTotal)
                        Text(
                          '${videoIntroController.total.value}人正在看',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        )
                    ],
                  ),
                )
              else
                const Spacer(),
              // ComBtn(
              //   icon: const Icon(
              //     FontAwesomeIcons.cropSimple,
              //     size: 15,
              //     color: Colors.white,
              //   ),
              //   fuc: () => _.screenshot(),
              // ),
              if (!widget.controller!.isFullScreen.value &&
                  !equivalentFullScreen()) ...[
                shootDanmakuButton(),
                danmakuSwitcher(),
                pipButton(),
              ],
              SizedBox(
                width: 42,
                height: 34,
                child: IconButton(
                  tooltip: "更多设置",
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(EdgeInsets.zero),
                  ),
                  onPressed: () => showSettingSheet(),
                  icon: const Icon(
                    Icons.more_vert_outlined,
                    size: 19,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
              height:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? 2
                      : 15),
          // if ((isFullScreen || !horizontalScreen))
          // const Spacer(),
          // show current datetime
          if (widget.controller!.isFullScreen.value || equivalentFullScreen())
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Obx(
                () => Text(
                  "   ${now.value}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                  semanticsLabel: '当前时间：'
                      '${now.value.split(':')[0]}点'
                      '${now.value.split(':')[1]}分',
                ),
              ),
              const SizedBox(width: 1.5),
              if (widget.controller!.isFullScreen.value)
                const SizedBox(width: 42),
              for (var i = 0; i < 11; i++) const SizedBox(width: 0),
              likeVideoButton(),
              coinVideoButton(),
              shootDanmakuButton(),
              danmakuSwitcher(),
              pipButton(),
              shareButton(),
            ]),
        ]),
      );
    });
  }
}

class MSliderTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    SliderThemeData? sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    const double trackHeight = 3;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2 + 4;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

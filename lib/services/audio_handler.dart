import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/plugin/pl_player/index.dart';
import 'package:PiliPalaX/utils/storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

Future<VideoPlayerServiceHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => VideoPlayerServiceHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.orz12.PiliPalaX.audio',
      androidNotificationChannelName: 'Audio Service PiliPalaX',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      fastForwardInterval: Duration(seconds: 10),
      rewindInterval: Duration(seconds: 10),
      androidNotificationChannelDescription: 'Media notification channel',
      androidNotificationIcon: 'drawable/ic_notification_icon',
    ),
  );
}

class VideoPlayerServiceHandler extends BaseAudioHandler with SeekHandler {
  // static final List<MediaItem> _item = [];
  Box setting = GStorage.setting;
  bool enableBackgroundPlay = true;
  // PlPlayerController player = PlPlayerController.getInstance();

  VideoPlayerServiceHandler() {
    revalidateSetting();
  }

  revalidateSetting() {
    enableBackgroundPlay =
        setting.get(SettingBoxKey.enableBackgroundPlay, defaultValue: true);
  }

  @override
  Future<void> play() async {
    await PlPlayerController.playIfExists();
    // player.play();
  }

  @override
  Future<void> pause() async {
    await PlPlayerController.pauseIfExists();
    // player.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    playbackState.add(playbackState.value.copyWith(
      updatePosition: position,
    ));
    await PlPlayerController.seekToIfExists(position, type: 'slider');
    // await player.seekTo(position);
  }

  Future<void> setMediaItem(MediaItem newMediaItem) async {
    if (!enableBackgroundPlay) return;
    // print("此时调用栈为：");
    // print(newMediaItem);
    // print(newMediaItem.title);
    // debugPrint(StackTrace.current.toString());
    // print(Get.currentRoute);
    // if (!Get.currentRoute.startsWith('/video') && !Get.currentRoute.startsWith('/live')) {
    //   return;
    // }
    if (!mediaItem.isClosed) mediaItem.add(newMediaItem);
  }

  Future<void> setPlaybackState(PlayerStatus status, bool isBuffering) async {
    if (!enableBackgroundPlay) return;
    // print("isBuffering2: $isBuffering");
    final AudioProcessingState processingState;
    final playing = status == PlayerStatus.playing;
    if (status == PlayerStatus.disabled) {
      processingState = AudioProcessingState.idle;
    } else if (status == PlayerStatus.completed) {
      processingState = AudioProcessingState.completed;
    } else if (isBuffering) {
      // tmp_fix: 手动播放前媒体通知无限buffer状态
      // processingState = AudioProcessingState.buffering;
      processingState = AudioProcessingState.ready;
    } else {
      processingState = AudioProcessingState.ready;
    }
    print("processingState: $processingState");

    playbackState.add(playbackState.value.copyWith(
      processingState: processingState,
      controls: [
        MediaControl.rewind
            .copyWith(androidIcon: 'drawable/ic_baseline_replay_10_24'),
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.fastForward
            .copyWith(androidIcon: 'drawable/ic_baseline_forward_10_24'),
      ],
      playing: playing,
      systemActions: const {
        MediaAction.seek,
      },
    ));
  }

  onStatusChange(PlayerStatus status, bool isBuffering) {
    if (!enableBackgroundPlay) return;
    // print("此时调用栈为：");
    // debugPrint(StackTrace.current.toString());
    // print("isBuffering: $isBuffering");
    // if (_item.isEmpty) return;
    // isBuffering = false;
    setPlaybackState(status, isBuffering);
  }

  onVideoDetailChange(
      String? title, String? artist, Duration? duration, String? artUri) {
    if (!enableBackgroundPlay) return;
    // print('当前调用栈为：');
    // print(StackTrace.current);
    if (!PlPlayerController.instanceExists()) return;
    print("artUri: $artUri");
    MediaItem mediaItem = MediaItem(
      id: UniqueKey().toString(),
      title: title ?? "",
      artist: artist ?? "",
      duration: duration ?? Duration.zero,
      artUri: Uri.parse(artUri ?? ""),
    );
    setMediaItem(mediaItem);
  }

  // onVideoDetailChange2(dynamic data, int cid) {
  //   if (!enableBackgroundPlay) return;
  //   print('当前调用栈为：');
  //   print(StackTrace.current);
  //   if (!PlPlayerController.instanceExists()) return;
  //   if (data == null) return;
  //
  //   late MediaItem? mediaItem;
  //   if (data is VideoDetailData) {
  //     if ((data.pages?.length ?? 0) > 1) {
  //       final current = data.pages?.firstWhere((element) => element.cid == cid);
  //       mediaItem = MediaItem(
  //         id: UniqueKey().toString(),
  //         title: current?.pagePart ?? "",
  //         artist: data.title ?? "",
  //         album: data.title ?? "",
  //         duration: Duration(seconds: current?.duration ?? 0),
  //         artUri: Uri.parse(data.pic ?? ""),
  //       );
  //     } else {
  //       mediaItem = MediaItem(
  //         id: UniqueKey().toString(),
  //         title: data.title ?? "",
  //         artist: data.owner?.name ?? "",
  //         duration: Duration(seconds: data.duration ?? 0),
  //         artUri: Uri.parse(data.pic ?? ""),
  //       );
  //     }
  //   } else if (data is BangumiInfoModel) {
  //     final current =
  //         data.episodes?.firstWhere((element) => element.cid == cid);
  //     mediaItem = MediaItem(
  //       id: UniqueKey().toString(),
  //       title: current?.longTitle ?? "",
  //       artist: data.title ?? "",
  //       duration: Duration(milliseconds: current?.duration ?? 0),
  //       artUri: Uri.parse(data.cover ?? ""),
  //     );
  //   }
  //   if (mediaItem == null) return;
  //   print("exist: ${PlPlayerController.instanceExists()}");
  //   if (!PlPlayerController.instanceExists()) return;
  //   _item.add(mediaItem);
  //   setMediaItem(mediaItem);
  // }

  // onVideoDetailDispose() {
  //   if (!enableBackgroundPlay) return;
  //
  //   playbackState.add(playbackState.value.copyWith(
  //     processingState: AudioProcessingState.idle,
  //     playing: false,
  //   ));
  //   if (_item.isNotEmpty) {
  //     _item.removeLast();
  //   }
  //   if (_item.isNotEmpty) {
  //     setMediaItem(_item.last);
  //     stop();
  //   } else {
  //     clear();
  //   }
  // }

  void clearImpl() {
    playbackState.add(PlaybackState(
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
    mediaItem.add(null);
    // _item.clear();
    // stop();
  }

  bool checkTop() {
    String top = Get.currentRoute;
    print("top:$top");
    return top.startsWith('/video') || top.startsWith('/live');
  }

  clear() {
    if (!enableBackgroundPlay) return;
    clearImpl();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!checkTop()) {
        clearImpl();
      } else {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!checkTop()) {
            clearImpl();
          }
        });
      }
    });
  }

  onPositionChange(Duration position) {
    if (!enableBackgroundPlay) return;

    playbackState.add(playbackState.value.copyWith(
      updatePosition: position,
    ));
  }
}

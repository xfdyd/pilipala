import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/models/video/play/url.dart';
import 'package:PiliPalaX/pages/live_room/index.dart';
import 'package:PiliPalaX/plugin/pl_player/index.dart';
import 'package:PiliPalaX/utils/storage.dart';

class BottomControl extends StatefulWidget implements PreferredSizeWidget {
  final PlPlayerController? controller;
  final LiveRoomController? liveRoomCtr;
  const BottomControl({
    this.controller,
    this.liveRoomCtr,
    super.key,
  });

  @override
  State<BottomControl> createState() => _BottomControlState();

  @override
  Size get preferredSize => throw UnimplementedError();
}

class _BottomControlState extends State<BottomControl> {
  late PlayUrlModel videoInfo;
  List<PlaySpeed> playSpeed = PlaySpeed.values;
  TextStyle subTitleStyle = const TextStyle(fontSize: 12);
  TextStyle titleStyle = const TextStyle(fontSize: 14);
  Size get preferredSize => const Size(double.infinity, kToolbarHeight);
  Box localCache = GStorage.localCache;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      primary: false,
      centerTitle: false,
      automaticallyImplyLeading: false,
      titleSpacing: 14,
      title: Row(
        children: [
          // ComBtn(
          //   icon: const Icon(
          //     Icons.subtitles_outlined,
          //     size: 18,
          //     color: Colors.white,
          //   ),
          //   fuc: () => Get.back(),
          // ),
          const Spacer(),
          // ComBtn(
          //   icon: const Icon(
          //     Icons.hd_outlined,
          //     size: 18,
          //     color: Colors.white,
          //   ),
          //   fuc: () => {},
          // ),
          // const SizedBox(width: 4),
          // Obx(
          //   () => ComBtn(
          //     icon: Icon(
          //       widget.liveRoomCtr!.volumeOff.value
          //           ? Icons.volume_off_outlined
          //           : Icons.volume_up_outlined,
          //       size: 18,
          //       color: Colors.white,
          //     ),
          //     fuc: () => {},
          //   ),
          // ),
          // const SizedBox(width: 4),
          if (Platform.isAndroid) ...[
            SizedBox(
              width: 34,
              height: 34,
              child: IconButton(
                tooltip: '画中画',
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                ),
                onPressed: () async {
                  // bool canUsePiP = false;
                  // widget.controller!.hiddenControls(false);
                  // try {
                  //   canUsePiP = await widget.floating!.isPipAvailable;
                  // } on PlatformException catch (_) {
                  //   canUsePiP = false;
                  // }
                  // if (canUsePiP) {
                  //   await widget.floating!.enable(const ImmediatePiP());
                  // } else {}
                },
                icon: const Icon(
                  Icons.picture_in_picture_alt,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          ComBtn(
            icon: const Icon(
              Icons.fullscreen,
              semanticLabel: '全屏切换',
              size: 20,
              color: Colors.white,
            ),
            fuc: () => widget.controller!.triggerFullScreen(
                status: !widget.controller!.isFullScreen.value),
          ),
        ],
      ),
    );
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

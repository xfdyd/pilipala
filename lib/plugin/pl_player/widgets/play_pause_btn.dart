import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:PiliPalaX/plugin/pl_player/index.dart';

class PlayOrPauseButton extends StatefulWidget {
  final double? iconSize;
  final Color? iconColor;
  final PlPlayerController? controller;

  const PlayOrPauseButton({
    super.key,
    this.iconSize,
    this.iconColor,
    this.controller,
  });

  @override
  PlayOrPauseButtonState createState() => PlayOrPauseButtonState();
}

class PlayOrPauseButtonState extends State<PlayOrPauseButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController animation;

  StreamSubscription<bool>? subscription;
  late Player player;
  bool isOpacity = false;

  @override
  void initState() {
    super.initState();
    player = widget.controller!.videoPlayerController!;
    animation = AnimationController(
      vsync: this,
      value: player.state.playing ? 1 : 0,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subscription ??= player.stream.playing.listen((event) {
      if (event) {
        animation.forward().then((value) => {
              isOpacity = true,
            });
      } else {
        animation.reverse().then((value) => {isOpacity = false});
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    animation.dispose();
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 34,
      child: InkWell(
        onTap: player.playOrPause,
        // iconSize: widget.iconSize ?? _theme(context).buttonBarButtonSize,
        // color: widget.iconColor ?? _theme(context).buttonBarButtonColor,
        child: Center(
          child: AnimatedIcon(
            semanticLabel:
                widget.controller!.videoPlayerController!.state.playing
                    ? '暂停'
                    : '播放',
            progress: animation,
            icon: AnimatedIcons.play_pause,
            color: Colors.white,
            size: 24,
            // size: widget.iconSize ?? _theme(context).buttonBarButtonSize,
            // color: widget.iconColor ?? _theme(context).buttonBarButtonColor,
          ),
        ),
      ),
    );
  }
}

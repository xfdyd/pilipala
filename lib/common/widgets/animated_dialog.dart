import 'package:flutter/material.dart';

class AnimatedDialog extends StatefulWidget {
  const AnimatedDialog({super.key, required this.child, this.closeFn});

  final Widget child;
  final Function? closeFn;

  @override
  State<StatefulWidget> createState() => AnimatedDialogState();
}

class AnimatedDialogState extends State<AnimatedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController? controller;
  late Animation<double>? opacityAnimation;
  late Animation<double>? scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    opacityAnimation = Tween<double>(begin: 0.0, end: 0.6).animate(
        CurvedAnimation(parent: controller!, curve: Curves.easeOutExpo));
    scaleAnimation =
        CurvedAnimation(parent: controller!, curve: Curves.easeOutExpo);
    controller!.addListener(() => setState(() {}));
    controller!.forward();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(opacityAnimation!.value),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () => widget.closeFn!(),
        child: Center(
          child: FadeTransition(
            opacity: scaleAnimation!,
            child: ScaleTransition(
              scale: scaleAnimation!,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

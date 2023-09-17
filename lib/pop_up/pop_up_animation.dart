import 'package:flutter/material.dart';

class CustomOffsetAnimation extends StatefulWidget {
  final AnimationController controller;
  final Widget child;
  final PopupPosition position;

  const CustomOffsetAnimation({
    Key? key,
    required this.controller,
    required this.child,
    this.position = PopupPosition.bottom,
  }) : super(key: key);

  @override
  CustomOffsetAnimationState createState() => CustomOffsetAnimationState();
}

class CustomOffsetAnimationState extends State<CustomOffsetAnimation> {
  late Tween<Offset> tweenOffset;
  late Animation<double> animation;

  @override
  void initState() {
    tweenOffset = widget.position == PopupPosition.center
        ? Tween<Offset>(begin: const Offset(0.0, 0.8), end: Offset.zero)
        : Tween<Offset>(
            begin: const Offset(0.0, 1),
            end: const Offset(0.0, 0.3),
          );
    animation = CurvedAnimation(
      parent: widget.controller,
      curve: Curves.decelerate,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        return FractionalTranslation(
          translation: tweenOffset.evaluate(animation),
          child: ClipRect(
            child: Opacity(
              opacity: animation.value,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

enum PopupPosition { bottom, center }

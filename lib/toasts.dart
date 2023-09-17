import 'package:app/pop_up/pop_up_animation.dart';
import 'package:app/pop_up/pop_up_body.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

class Toast {
  Toast._();

  static void success({String? text}) {
    BotToast.showCustomText(
      toastBuilder: (cancelFunc) => Container(
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(10),
        child: Text(
          text ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  static void showAlertDialog({Function? onTapConfirm}) {
    BotToast.showAnimationWidget(
      clickClose: false,
      allowClick: false,
      onlyOne: true,
      crossPage: true,
      wrapToastAnimation: (controller, cancel, child) => Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () => cancel(),
            child: AnimatedBuilder(
              builder: (_, child) => Opacity(
                opacity: controller.value,
                child: child,
              ),
              animation: controller,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black.withOpacity(.6)),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          CustomOffsetAnimation(
            controller: controller,
            child: child,
          )
        ],
      ),
      toastBuilder: (cancelFunc) => alertDialog(
        cancelFunc: cancelFunc,
        onTapConfirm: onTapConfirm,
      ),
      animationDuration: const Duration(milliseconds: 250),
    );
  }
}

import 'package:flutter/material.dart';

AlertDialog alertDialog({
  required Function cancelFunc,
  Function? onTapConfirm,
}) {
  return AlertDialog(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    // this is the horizontal margin of your body
    insetPadding: const EdgeInsets.symmetric(horizontal: 16),
    // this is the padding of your content from title and actions
    contentPadding: const EdgeInsets.only(left: 25, right: 25, top: 10),
    title: const Text(
      'Are you sure you want to push this button?',
      style: TextStyle(fontSize: 16),
    ),
    content: const Text(
      'if you tap on this button it will count up the text in screen',
      style: TextStyle(fontSize: 13, color: Colors.grey),
    ),
    actions: [
      TextButton(
        onPressed: () => cancelFunc(),
        child: const Text(
          'Cancel',
          style: TextStyle(color: Colors.redAccent, fontSize: 14),
        ),
      ),
      TextButton(
        onPressed: () {
          // this is to close the pop up itself
          cancelFunc();
          if (onTapConfirm != null) onTapConfirm();
        },
        child: const Text(
          'Confirm',
          style: TextStyle(
            fontSize: 14,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}

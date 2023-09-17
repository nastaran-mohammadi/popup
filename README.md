# Flutter Popups: No Context Needed!
Flutter devs often wrestle with passing contexts around in their code, especially when it comes to showing pop-ups or overlays. But I've just discovered a way to do this without the usual context hassle. If you're using `GetX`, you might already know about `Get.context`, but what about when you're using `Provider` or `Riverpod`? Let's simplify this for you.
First things first, let's add the latest version of the `bot_toast` package. Simply add `bot_toast: ^4.1.1` to your project's `pubspec.yaml` file.
Next, initialise the package in your `main.dart` file as shown in the documentation:

```
return MaterialApp(
  title: 'Flutter Demo',
  theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  useMaterial3: true,
  ),
  builder: BotToastInit(), //1. call BotToastInit
  navigatorObservers: [BotToastNavigatorObserver()], //2. registered route observer
  home: const MyHomePage(title: 'Flutter Demo Home Page'),
);
```
Now, let's dive into the code. Start by creating a new folder called popup and inside it, create a Dart file named `pop_up_animation.dart`. Paste the following code inside it:

```
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
```

Next, create another file named `pop_up_body.dart` and insert the following code into it:

```
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
```
Great! That's all for now, developers. Let's create a class named `Toast` and add a caller function inside it for future use. Now, outside of the `popup` folder, create a file named `toast.dart` and include the following code inside it:

```
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
```

Alright, we've set up the necessary files for our pop-up functionality. Now, let's use it in a simple Flutter counter app. Here's an example of how you can integrate the `Toast` class we created:

```
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    Toast.showAlertDialog(onTapConfirm: () {
      setState(() {
        _counter++;
      });
      Toast.success(text: 'Successfully Done!');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

It sounds like you've successfully implemented the pop-up functionality in your Flutter counter app, and it's working as expected. When you tap the + button, a pop-up appears, and when you press the confirm button inside the pop-up, the counter increments, the pop-up closes, and a success toast message is displayed.
This is a great demonstration of how you can show pop-up toasts without context to enhance user interactions in your Flutter applications. If you have any more questions or need further assistance with your Flutter development, feel free to ask. Happy coding!

here you can find [medium](https://nastaran-mohammadi.medium.com/popflutter-popups-no-context-needed-3346e1b738c0) article for this repo.

# animation_text

Customizable animated text widgets for Flutter. Physics-based animations power
smooth, delightful text effects that drop straight into your UI.

## Features

- Effects: `SpringText`, `ChimeBellText`, `ScaleText`, `RotateText`,
  `BlurText`, `OffsetText`, `SlideText`, `ScrambleText`, `RevealText`,
  `GravityText` (real 2D rigid-body physics via `forge2d`).
- Letter-by-letter or word-by-word animation (`AnimationType.letter` / `.word`).
- Configurable duration, delay, curve and modes: forward, reverse, repeat,
  repeat-with-reverse.
- External control through `AnimatedTextController` (play, pause, repeat…).

## Usage

```dart
import 'package:animation_text/animation_text.dart';
import 'package:flutter/material.dart';

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaleText(
      text: 'Hello world',
      config: const AnimationConfig(
        duration: Duration(milliseconds: 600),
        type: AnimationType.letter,
      ),
      onControllerCreated: (controller) {
        // controller.play(); controller.pause(); controller.repeatAnimation();
      },
    );
  }
}
```

Swap `ScaleText` for any other effect widget — they share the same
`text` / `style` / `textAlign` / `config` / `onControllerCreated` API.

## Credits

Animation approach inspired by jasudev's AnimateText for SwiftUI.

## License

MIT — see [LICENSE](LICENSE).

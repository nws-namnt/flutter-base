# ✨ RL_Animation_Kit

A collection of loading indicators animated with flutter.

## 🎖 Installing

```yaml
dependencies:
  animation:
    path: ../animation
```

## 🎮 How To Use

### Normal using
```dart
const anim = RotatingCircle(
  color: Colors.white,
  size: 50.0,
);
```

### Using with builder
```dart
final anim = FadingCircle(
  itemBuilder: (BuildContext context, int index) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: index.isEven ? Colors.red : Colors.green,
      ),
    );
  },
);
```

### Using with controller
```dart
final spinkit = SquareCircle(
  color: Colors.white,
  size: 50.0,
  controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)),
);
```

For more info, please, refer to the `folder screenshots` for more detail of each animation.

## 🚀 Showcase

## ⭐️ License
MIT License

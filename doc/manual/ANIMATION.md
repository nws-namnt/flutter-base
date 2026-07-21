# flutter_animate — Hướng dẫn & danh sách đầy đủ effect

> Phiên bản áp dụng: **flutter_animate 4.5.2**
> Tài liệu gồm: cách dùng cơ bản, các tham số, sequencing, list, điều khiển bằng controller, danh sách **tất cả effect** kèm sample, và pattern viết wrapper dùng toàn app.

---

## 1. Cài đặt & import

```yaml
# pubspec.yaml
dependencies:
  flutter_animate: ^4.5.2
```

```dart
import 'package:flutter_animate/flutter_animate.dart';
```

---

## 2. Cú pháp cơ bản

Hai cách tương đương:

```dart
// 1) Bọc widget bằng Animate + danh sách effect
Animate(
  effects: [FadeEffect(), ScaleEffect()],
  child: const Text('Hello World!'),
);

// 2) Extension .animate() + chain (khuyên dùng, ngắn gọn)
const Text('Hello World!').animate().fade().scale();
```

Mọi effect đều có bản `Effect` (class) và bản extension (`.fade()`, `.scale()`…).

---

## 3. delay / duration / curve

Effect chạy **song song**; dùng `delay` để chạy nối tiếp.

```dart
Text('Hello').animate()
  .fade(duration: 500.ms)
  .scale(delay: 500.ms); // chạy sau fade
```

Nếu không set, giá trị **kế thừa** từ effect trước, hoặc từ `Animate.defaultDuration` / `Animate.defaultCurve` nếu là effect đầu tiên.

```dart
Text('Hello World!').animate()
  .fadeIn()                                   // dùng Animate.defaultDuration
  .scale()                                    // kế thừa duration của fadeIn
  .move(delay: 300.ms, duration: 600.ms)      // chạy sau, duration mới
  .blurXY();                                  // kế thừa delay & duration của move
```

`Animate(delay: ...)` khác với `delay` của effect: nó chỉ áp **một lần** ở đầu, không lặp lại khi animation repeat.

### begin / end

Đa số effect có `begin`/`end`. Nếu chỉ set một, cái còn lại mặc định về giá trị "trung tính" (không có hiệu ứng):

```dart
Text('Hello').animate().fade();            // begin=0, end=1
Text('Hello').animate().fade(begin: 0.5);  // end=1
Text('Hello').animate().fade(end: 0.5);    // begin=1
```

### Duration extensions

```dart
300.ms      // 300 milliseconds
2.seconds   // 2 giây
0.1.minutes // 6 giây
```

---

## 4. Sequencing với `.then()`

`.then()` đặt lại mốc thời gian = thời điểm kết thúc effect trước + `delay` của chính nó. Các `delay` sau đó tính tương đối theo mốc mới.

```dart
Text('Hello').animate()
  .fadeIn(duration: 600.ms)
  .then(delay: 200.ms) // baseline = 800ms
  .slide();            // chạy tại 800ms
```

---

## 5. Animate cho danh sách (stagger)

```dart
// Class form
Column(children: AnimateList(
  interval: 400.ms,
  effects: [FadeEffect(duration: 300.ms)],
  children: const [Text('Hello'), Text('World'), Text('Goodbye')],
));

// Shorthand
Column(
  children: const [Text('Hello'), Text('World'), Text('Goodbye')]
      .animate(interval: 400.ms)
      .fade(duration: 300.ms),
);
```

---

## 6. Lặp, phản ứng theo state, điều khiển thủ công

```dart
// Loop
Text('Pulsing')
  .animate(onPlay: (c) => c.repeat(reverse: true))
  .fadeOut(curve: Curves.easeInOut);

// Reacting to state (target): khi _over đổi -> tự animate tới 0 hoặc 1
MyButton().animate(target: _over ? 1 : 0)
  .fade(end: 0.8).scaleXY(end: 1.1);

// Điều khiển thủ công: tắt autoPlay, lấy controller qua onInit
Widget().animate(
  autoPlay: false,
  onInit: (controller) => _controllers.add(controller),
).fadeIn();
// sau đó: controller.forward(from: 0);
```

Callbacks: `onInit`, `onPlay`, `onComplete` đều trả về `AnimationController`.

---

## 7. DANH SÁCH TẤT CẢ EFFECT

### 7.1 Chuyển động / biến đổi (transform)

| Effect | Method | Mô tả | Sample |
|---|---|---|---|
| Fade | `fade` / `fadeIn` / `fadeOut` | Mờ dần opacity | `w.animate().fadeIn(duration: 400.ms)` |
| Scale | `scale` / `scaleXY` / `scaleX` / `scaleY` | Phóng to/thu nhỏ | `w.animate().scale(begin: Offset(.5, .5))` |
| Rotate | `rotate` | Xoay (đơn vị: số vòng, 0.25 = 90°) | `w.animate().rotate(end: .25)` |
| Flip | `flip` / `flipH` / `flipV` | Lật 3D ngang/dọc | `w.animate().flipH()` |
| Move | `move` / `moveX` / `moveY` | Dịch theo pixel (Offset) | `w.animate().move(begin: Offset(-40, 0))` |
| Slide | `slide` / `slideX` / `slideY` | Trượt theo % kích thước | `w.animate().slideX(begin: -1)` |
| Align | `align` | Animate `Alignment` | `w.animate().align(begin: Alignment.centerLeft, end: Alignment.center)` |
| Crossfade | `crossfade` | Crossfade sang widget khác | `w.animate().crossfade(builder: (_) => other)` |
| Follow path | `followPath` | Di chuyển theo `Path` | `w.animate().followPath(path: myPath)` |

```dart
// Ví dụ chi tiết
const Icon(Icons.star).animate().scale(duration: 400.ms, begin: const Offset(.5, .5));
const Text('Hi').animate().slideY(begin: 1, curve: Curves.easeOut);
const FlutterLogo().animate().flip(duration: 600.ms);
```

### 7.2 Bộ lọc / hình ảnh (visual filters)

| Effect | Method | Mô tả | Sample |
|---|---|---|---|
| Blur | `blur` / `blurXY` / `blurX` / `blurY` | Làm mờ | `w.animate().blurXY(begin: 12, end: 0)` |
| Tint | `tint` / `untint` | Phủ màu / bỏ phủ | `w.animate().tint(color: Colors.purple)` |
| Color | `color` | Nội suy giữa 2 `Color` qua `ColorFiltered` | `w.animate().color(begin: Colors.red, end: Colors.blue, blendMode: BlendMode.multiply)` |
| Saturate | `saturate` / `desaturate` | Tăng/giảm bão hòa | `w.animate().saturate(begin: 0, end: 1)` |
| Shimmer | `shimmer` | Loang sáng (skeleton) | `w.animate().shimmer(duration: 1200.ms, color: Colors.white70)` |
| Box shadow | `boxShadow` | Animate đổ bóng | `w.animate().boxShadow(end: BoxShadow(color: Colors.black45, blurRadius: 16, offset: Offset(0, 8)))` |
| Shader | `shader` | Áp GLSL fragment shader (cần asset `.frag`) | `w.animate().shader(duration: 2.seconds, shader: myShader)` |

```dart
// Skeleton loading điển hình
Container(width: 200, height: 20, color: Colors.grey.shade300)
  .animate(onPlay: (c) => c.repeat())
  .shimmer(duration: 1200.ms, color: Colors.white);
```

### 7.3 Rung/lắc

| Effect | Method | Mô tả | Sample |
|---|---|---|---|
| Shake | `shake` / `shakeX` / `shakeY` | Rung theo tần số `hz` | `w.animate().shake(hz: 4)` |

### 7.4 Điều khiển widget theo thời gian

| Effect | Method | Mô tả |
|---|---|---|
| Swap | `swap` | Thay hẳn sang widget khác tại 1 thời điểm |
| Toggle | `toggle` | Build lại theo cờ bool (true trước, false sau khi hết duration) |
| Visibility | `show` / `hide` | Hiện / ẩn (Visibility) tại 1 thời điểm |

```dart
// swap
const Text('Before').animate()
  .swap(duration: 900.ms, builder: (_, __) => const Text('After'));

// toggle
Animate().toggle(
  duration: 2.seconds,
  builder: (_, value, __) => Text(value ? 'Before' : 'After'),
);

// show/hide
const Text('Xuất hiện sau 1s').animate().show(delay: 1.seconds);
```

### 7.5 Builder / tùy biến

| Effect | Method | Mô tả |
|---|---|---|
| Custom | `custom` | Tự viết builder theo `value` (mặc định 0→1) |
| Callback | `callback` | Chạy callback tại 1 thời điểm |
| Listen | `listen` | Nhận giá trị animation liên tục |

```dart
// custom: nền lerp đỏ -> xanh
const Text('Hello').animate().custom(
  duration: 300.ms,
  builder: (context, value, child) => Container(
    color: Color.lerp(Colors.red, Colors.blue, value),
    padding: const EdgeInsets.all(8),
    child: child,
  ),
);

// callback giữa chừng
const Text('Hi').animate().fadeIn(duration: 600.ms)
  .callback(duration: 300.ms, callback: (_) => debugPrint('halfway'));

// listen giá trị
const Text('Hi').animate().fadeIn()
  .listen(callback: (value) => debugPrint('opacity: $value'));
```

---

## 8. Adapters (đồng bộ theo nguồn ngoài)

Mặc định animation chạy theo thời gian. Có thể đồng bộ theo nguồn khác (vd cuộn) qua `adapter`, ví dụ `ScrollAdapter` cập nhật animation theo `ScrollController`. Nguồn ngoài phải cung cấp giá trị 0→1.

---

## 9. Testing

```dart
// Tự restart mọi animation mỗi lần hot reload
Animate.restartOnHotReload = true;
```

---

## 10. Pattern wrapper dùng toàn app

Gom **tokens + presets + extension** để nhất quán và sửa 1 chỗ.

```dart
// lib/common/app_animations.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Centralized animation tokens.
class AppAnim {
  const AppAnim._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 600);

  static const Curve curve = Curves.easeOutCubic;
  static const double slideDistance = 24;

  // Call once in main() before runApp.
  static void init() {
    Animate.defaultDuration = normal;
    Animate.defaultCurve = curve;
  }
}

// Reusable presets.
class AppEffects {
  const AppEffects._();

  static List<Effect> fadeIn({Duration? delay}) => [
        FadeEffect(delay: delay, duration: AppAnim.normal),
      ];

  static List<Effect> fadeInUp({Duration? delay}) => [
        FadeEffect(delay: delay, duration: AppAnim.normal),
        MoveEffect(
          delay: delay,
          duration: AppAnim.normal,
          begin: const Offset(0, AppAnim.slideDistance),
          end: Offset.zero,
        ),
      ];
}

// Extension gọi ngắn gọn ở UI.
extension AppAnimateExt on Widget {
  Animate appFadeIn({Duration? delay}) =>
      animate(effects: AppEffects.fadeIn(delay: delay));

  Animate appFadeInUp({Duration? delay}) =>
      animate(effects: AppEffects.fadeInUp(delay: delay));
}
```

Dùng:

```dart
const Text('Hello').appFadeInUp();

// Stagger
Column(
  children: [
    for (var i = 0; i < items.length; i++) items[i].appFadeInUp(delay: (80 * i).ms),
  ],
);
```

---

## 11. Playground điều khiển được (slider duration + replay)

Ý tưởng: mỗi `Animate` để `autoPlay` tự chạy khi mount (luôn nhìn thấy), đồng thời gom `AnimationController` qua `onInit` để **Replay tại chỗ** (không rebuild, giữ scroll). Vì mọi effect map theo controller 0→1, chỉ cần đổi `controller.duration` là cả timeline co giãn.

```dart
final List<AnimationController> _controllers = [];
double _durationMs = 500;
Duration get _dur => _durationMs.round().ms;

Animate _controlled(Widget child) =>
    child.animate(onInit: (c) => _controllers.add(c));

void _replay() {
  for (final c in _controllers) {
    c.duration = _dur;      // áp giá trị slider (scale toàn timeline)
    c.forward(from: 0);
  }
}
```

> Xem màn `_SecondTab` trong `lib/pages/service/service_page.dart` để có ví dụ đầy đủ tất cả effect chạy được.

---

## Tham khảo

- pub.dev: https://pub.dev/packages/flutter_animate
- API reference: https://pub.dev/documentation/flutter_animate/latest/
- Repo: https://github.com/gskinner/flutter_animate

import 'package:animation_text/animation_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/utils/extensions/extensions.dart';

/// Sample text shown by every effect on the showcase canvas.
const _demoText = 'Bring motion to your text. Keep your UI elegant!';

/// Letter/word animation durations indexed by speed (0=slow, 1=medium, 2=fast).
const _letterDurations = [
  Duration(milliseconds: 600),
  Duration(milliseconds: 300),
  Duration(milliseconds: 150),
];
const _wordDurations = [
  Duration(milliseconds: 1200),
  Duration(milliseconds: 600),
  Duration(milliseconds: 300),
];

/// One selectable variation for an effect (e.g. slide direction).
class _Variation {
  const _Variation({this.label, required this.icon, required this.value});

  final String? label;
  final IconData icon;
  final Object value;
}

typedef _DemoBuilder = Widget Function(
  void Function(AnimatedTextController) onCreated,
  int variationIndex,
  TextAlign textAlign,
  AnimationType type,
  Duration duration,
);

/// A single animation entry in the showcase.
class _Demo {
  const _Demo({
    required this.title,
    required this.icon,
    required this.build,
    this.variations = const [],
  });

  final String title;
  final IconData icon;
  final _DemoBuilder build;
  final List<_Variation> variations;

  bool get hasVariations => variations.isNotEmpty;
}

/// A themed, self-contained showcase of every `animation_text` effect,
/// modelled after the package's demo site. All colors come from the active
/// [ColorScheme] / notify color extension so it adapts to light & dark.
class AnimationTextShowcase extends StatefulWidget {
  const AnimationTextShowcase({super.key});

  @override
  State<AnimationTextShowcase> createState() => _AnimationTextShowcaseState();
}

class _AnimationTextShowcaseState extends State<AnimationTextShowcase> {
  final PageController _pageController = PageController();
  final Duration _pageTransition = const Duration(milliseconds: 400);
  final Curve _curve = Curves.fastOutSlowIn;

  AnimatedTextController? _currentController;
  final ValueNotifier<AnimatedTextController?> _controllerNotifier =
      ValueNotifier(null);

  bool _isWordMode = false;
  int _currentPage = 0;
  TextAlign _textAlign = TextAlign.center;
  int _speedIndex = 1;
  bool _interactionEnabled = true;

  late final List<int> _variationIndices;
  late final List<_Demo> _demos;

  Duration get _duration =>
      _isWordMode ? _wordDurations[_speedIndex] : _letterDurations[_speedIndex];

  // Configs are cached by (type, duration) so repeated rebuilds hand the same
  // instance back to AnimatedTextBase — otherwise a fresh config every build
  // looks like a change and restarts the animation.
  final Map<String, AnimationConfig> _configCache = {};
  final Map<String, AnimationConfig> _plainConfigCache = {};

  // Demo animation config: loops a few times so the effect is easy to watch.
  AnimationConfig _config(AnimationType type, Duration duration) =>
      _configCache['$type-${duration.inMilliseconds}'] ??= AnimationConfig(
        type: type,
        duration: duration,
        repeat: true,
        repeatCount: 3,
        reverse: true,
      );

  // Plain config (no repeat/reverse) for GravityText, which is a physics sim.
  AnimationConfig _plainConfig(AnimationType type, Duration duration) =>
      _plainConfigCache['$type-${duration.inMilliseconds}'] ??=
          AnimationConfig(type: type, duration: duration);

  TextStyle _demoStyle(BuildContext context) =>
      (context.textTheme.displaySmall ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w900,
        color: context.colorScheme.onSurface,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static const _slideVariations = [
    _Variation(icon: Icons.arrow_forward, value: SlideAnimationType.leftRight),
    _Variation(icon: Icons.arrow_back, value: SlideAnimationType.rightLeft),
    _Variation(icon: Icons.arrow_downward, value: SlideAnimationType.topBottom),
    _Variation(icon: Icons.arrow_upward, value: SlideAnimationType.bottomTop),
    _Variation(icon: Icons.swap_vert, value: SlideAnimationType.alternateTB),
    _Variation(icon: Icons.swap_horiz, value: SlideAnimationType.alternateLR),
  ];

  static const _rotateVariations = [
    _Variation(
      label: 'CW',
      icon: Icons.rotate_right,
      value: RotateAnimationType.clockwise,
    ),
    _Variation(
      label: 'CCW',
      icon: Icons.rotate_left,
      value: RotateAnimationType.anticlockwise,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _demos = [
      _Demo(
        title: 'Gravity',
        icon: Icons.arrow_downward_rounded,
        build: (onCreated, _, ta, type, dur) => GravityText(
          text: _demoText,
          style: _demoStyle(context),
          textAlign: ta,
          // Physics sim ignores repeat/reverse — build a plain config.
          config: _plainConfig(type, dur),
          onControllerCreated: onCreated,
          enableInteraction: _interactionEnabled,
        ),
      ),
      _Demo(
        title: 'Scramble',
        icon: Icons.shuffle_rounded,
        build: (onCreated, _, ta, type, dur) => ScrambleText(
          text: _demoText,
          style: _demoStyle(context),
          textAlign: ta,
          config: _config(type, dur),
          onControllerCreated: onCreated,
        ),
      ),
      _Demo(
        title: 'Spring',
        icon: Icons.directions_run_rounded,
        build: (onCreated, _, ta, type, dur) => SpringText(
          text: _demoText,
          style: _demoStyle(context),
          textAlign: ta,
          config: _config(type, dur),
          onControllerCreated: onCreated,
        ),
      ),
      _Demo(
        title: 'Reveal',
        icon: Icons.auto_fix_high_rounded,
        build: (onCreated, _, ta, type, dur) => RevealText(
          text: _demoText,
          style: _demoStyle(context),
          textAlign: ta,
          cursorColor: context.colorScheme.primary,
          config: _config(type, dur),
          onControllerCreated: onCreated,
        ),
      ),
      _Demo(
        title: 'Scale',
        icon: Icons.zoom_in_map_rounded,
        build: (onCreated, _, ta, type, dur) => ScaleText(
          text: _demoText,
          style: _demoStyle(context),
          textAlign: ta,
          config: _config(type, dur),
          onControllerCreated: onCreated,
        ),
      ),
      _Demo(
        title: 'Slide',
        icon: Icons.swap_horiz_rounded,
        variations: _slideVariations,
        build: (onCreated, vi, ta, type, dur) => SlideText(
          text: _demoText,
          style: _demoStyle(context),
          textAlign: ta,
          slideType: _slideVariations[vi].value as SlideAnimationType,
          config: _config(type, dur),
          onControllerCreated: onCreated,
        ),
      ),
      _Demo(
        title: 'Rotate',
        icon: Icons.rotate_right_rounded,
        variations: _rotateVariations,
        build: (onCreated, vi, ta, type, dur) => RotateText(
          text: _demoText,
          style: _demoStyle(context),
          textAlign: ta,
          direction: _rotateVariations[vi].value as RotateAnimationType,
          config: _config(type, dur),
          onControllerCreated: onCreated,
        ),
      ),
      _Demo(
        title: 'Chime Bell',
        icon: Icons.notifications_rounded,
        build: (onCreated, _, ta, type, dur) => ChimeBellText(
          text: _demoText,
          style: _demoStyle(context),
          textAlign: ta,
          config: _config(type, dur),
          onControllerCreated: onCreated,
        ),
      ),
      _Demo(
        title: 'Blur',
        icon: Icons.blur_on_rounded,
        build: (onCreated, _, ta, type, dur) => BlurText(
          text: _demoText,
          style: _demoStyle(context),
          textAlign: ta,
          config: _config(type, dur),
          onControllerCreated: onCreated,
        ),
      ),
    ];
    _variationIndices = List.filled(_demos.length, 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controllerNotifier.dispose();
    super.dispose();
  }

  // Control helpers ──────────────────────────────────────────────────────────

  void _play() {
    final c = _currentController;
    if (c == null || c.isAnimating) return;
    (c.isPaused || c.isRepeating) ? c.resume() : c.play();
  }

  void _playPause() {
    final c = _currentController;
    if (c == null) return;
    c.isAnimating ? c.pause() : _play();
  }

  void _repeat() => _currentController?.repeat();

  void _restartAfterFrame() =>
      WidgetsBinding.instance.addPostFrameCallback((_) => _repeat());

  void _goToPage(int index) => _pageController.animateToPage(
        index,
        duration: _pageTransition,
        curve: _curve,
      );

  void _setState(VoidCallback fn) {
    setState(fn);
    _restartAfterFrame();
  }

  // Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final demo = _demos[_currentPage];
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _header(cs, demo),
          _toolbar(cs),
          Expanded(child: _canvas(cs)),
          _footer(cs, demo),
        ],
      ),
    );
  }

  // Header: prev/next nav, title + status chip.
  Widget _header(ColorScheme cs, _Demo demo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: _currentPage > 0 ? () => _goToPage(_currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(demo.icon, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    demo.title,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _statusChip(cs),
              ],
            ),
          ),
          IconButton(
            onPressed: _currentPage < _demos.length - 1
                ? () => _goToPage(_currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  // Toolbar: mode / speed / align controls.
  Widget _toolbar(ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.22),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _pill(cs, [
              _segment(cs, 'Letters', !_isWordMode,
                  () => _setState(() => _isWordMode = false)),
              _segment(cs, 'Words', _isWordMode,
                  () => _setState(() => _isWordMode = true)),
            ]),
            const SizedBox(width: 8),
            _pill(cs, [
              for (final (i, label) in const ['🐢', '🐕', '🐇'].indexed)
                _segment(cs, label, _speedIndex == i,
                    () => _setState(() => _speedIndex = i)),
            ]),
            const SizedBox(width: 8),
            _pill(cs, [
              _iconSegment(cs, Icons.format_align_left,
                  _textAlign == TextAlign.start,
                  () => _setState(() => _textAlign = TextAlign.start)),
              _iconSegment(cs, Icons.format_align_center,
                  _textAlign == TextAlign.center,
                  () => _setState(() => _textAlign = TextAlign.center)),
              _iconSegment(cs, Icons.format_align_right,
                  _textAlign == TextAlign.end,
                  () => _setState(() => _textAlign = TextAlign.end)),
            ]),
          ],
        ),
      ),
    );
  }

  // Canvas: gradient background hosting the animation PageView.
  Widget _canvas(ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cs.surfaceContainerHighest,
            cs.surface,
            cs.surfaceContainerHighest,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      // Swipe is owned by the outer tab PageView; navigate via header/dots.
      child: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _demos.length,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
          _restartAfterFrame();
        },
        itemBuilder: (context, index) {
          final demo = _demos[index];
          final isCurrent = index == _currentPage;
          final vi = _variationIndices[index];

          void onCreated(AnimatedTextController c) {
            if (isCurrent && _currentController != c) {
              _currentController = c;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _controllerNotifier.value = c;
              });
            }
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Center(
              key: ValueKey(
                '${demo.title}_${_isWordMode}_${vi}_${_textAlign}_$_speedIndex',
              ),
              child: demo.build(
                onCreated,
                vi,
                _textAlign,
                _isWordMode ? AnimationType.word : AnimationType.letter,
                _duration,
              ),
            ),
          );
        },
      ),
    );
  }

  // Footer: variations or page dots (left) + interaction toggle + play (right).
  Widget _footer(ColorScheme cs, _Demo demo) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.22)),
        ),
      ),
      child: Row(
        children: [
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: demo.hasVariations
                  ? _variationSelector(cs, demo)
                  : _dots(cs),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (demo.title == 'Gravity') ...[
                Text('Tap', style: context.textTheme.labelMedium),
                Switch(
                  value: _interactionEnabled,
                  activeColor: cs.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (v) => _setState(() => _interactionEnabled = v),
                ),
                const SizedBox(width: 4),
              ],
              _playControls(cs),
            ],
          ),
        ],
      ),
    );
  }

  // Reusable widgets ──────────────────────────────────────────────────────────

  Widget _pill(ColorScheme cs, List<Widget> children) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      );

  Widget _segment(ColorScheme cs, String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: context.textTheme.labelLarge?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? cs.primary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _iconSegment(ColorScheme cs, IconData icon, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? cs.surface : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(icon,
            size: 18, color: selected ? cs.primary : cs.onSurfaceVariant),
      ),
    );
  }

  Widget _variationSelector(ColorScheme cs, _Demo demo) {
    final selected = _variationIndices[_currentPage];
    return _pill(cs, [
      for (final (i, v) in demo.variations.indexed)
        InkWell(
          onTap: () {
            if (_variationIndices[_currentPage] == i) return;
            _setState(() => _variationIndices[_currentPage] = i);
          },
          borderRadius: BorderRadius.circular(100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
                horizontal: v.label != null ? 12 : 10, vertical: 8),
            decoration: BoxDecoration(
              color: selected == i ? cs.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(v.icon,
                    size: 18,
                    color: selected == i ? cs.primary : cs.onSurfaceVariant),
                if (v.label != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    v.label!,
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight:
                          selected == i ? FontWeight.w700 : FontWeight.w500,
                      color: selected == i ? cs.primary : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
    ]);
  }

  Widget _dots(ColorScheme cs) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _demos.length; i++)
            GestureDetector(
              onTap: () => _goToPage(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _currentPage ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: i == _currentPage ? cs.primary : cs.outlineVariant,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
        ],
      );

  Widget _statusChip(ColorScheme cs) {
    final notify = context.notifyColorScheme;
    return ValueListenableBuilder<AnimatedTextController?>(
      valueListenable: _controllerNotifier,
      builder: (context, controller, _) {
        return ListenableBuilder(
          listenable: controller ?? ChangeNotifier(),
          builder: (context, _) {
            String text;
            Color bg;
            Color fg;
            IconData icon;
            if (controller != null && controller.isAnimating) {
              text = controller.repeatCount > 0
                  ? 'Repeat ${controller.repeatCount}'
                  : 'Playing';
              bg = notify.success;
              fg = notify.onSuccess;
              icon = Icons.play_circle_outline_rounded;
            } else if (controller != null && controller.isPaused) {
              text = 'Paused';
              bg = notify.warning;
              fg = notify.onWarning;
              icon = Icons.pause_circle_outline_rounded;
            } else if (controller != null && controller.isCompleted) {
              text = 'Done';
              bg = notify.info;
              fg = notify.onInfo;
              icon = Icons.check_circle_outline_rounded;
            } else {
              text = 'Stopped';
              bg = cs.surfaceContainerHighest;
              fg = cs.onSurfaceVariant;
              icon = Icons.stop_circle_outlined;
            }
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Container(
                key: ValueKey(text),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 12, color: fg),
                    const SizedBox(width: 4),
                    Text(
                      text,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _playControls(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Repeat',
            onPressed: _repeat,
            icon: Icon(Icons.refresh_rounded, color: cs.onSurface),
          ),
          ValueListenableBuilder<AnimatedTextController?>(
            valueListenable: _controllerNotifier,
            builder: (context, controller, _) {
              return ListenableBuilder(
                listenable: controller ?? ChangeNotifier(),
                builder: (context, _) {
                  final playing = controller?.isAnimating ?? false;
                  return IconButton.filled(
                    visualDensity: VisualDensity.compact,
                    tooltip: playing ? 'Pause' : 'Play',
                    onPressed: _playPause,
                    style: IconButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                    ),
                    icon: Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

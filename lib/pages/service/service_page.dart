import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_base/common/app_extension.dart';
import 'package:flutter_base/pages/widgets/action_widget.dart';
import 'package:flutter_base/pages/widgets/flow_fab_menu_widget.dart';
import 'package:flutter_base/utils/app_utils.dart';
import 'package:flutter_base/utils/data_generator_util.dart' hide R;
import 'package:flutter_base/utils/extensions/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../generated/app_assets.dart';
import '../../models/flow_fab_menu.dart';
import '../widgets/cached_image_widget.dart';
import '../widgets/collapsible_text_widget.dart';
import '../widgets/hero_image_widget.dart';
import 'animation_text_showcase.dart';
import 'service_cubit.dart';
import 'service_state.dart';

enum TabBarType {
  headPhone('Headphone', Icons.headphones_rounded),
  speaker('Speaker', Icons.speaker_rounded),
  bluetooth('Bluetooth', Icons.bluetooth_audio_rounded);

  final String title;
  final IconData icon;

  const TabBarType(this.title, this.icon);
}

/// The Service tab screen, hosted inside the navigation shell at [Routers.service].
///
/// Instantiates and owns its [ServiceCubit]; the cubit is closed in [dispose].
class ServicePage extends StatefulWidget {
  /// Creates a [ServicePage].
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage>
    with SingleTickerProviderStateMixin {
  late final ServiceCubit _cubit;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    _cubit = ServiceCubit()..initialize();

    // Runs once the first successful load finishes; surfaces load failures.
    _cubit.whenReady
        .then((_) {
          if (!mounted) return;
          // Hook post-load actions here (e.g. deep-link handling, analytics).
        })
        .catchError((Object e) {
          if (!mounted) return;
          showToast('Load failed: $e');
        });
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ServiceCubit, ServiceState>(
        builder: (context, state) {
          return Scaffold(
            floatingActionButton: BlocBuilder<ServiceCubit, ServiceState>(
              builder: (context, state) {
                if (state == const ServiceLoading() ||
                    state == const ServiceInitial()) {
                  return const SizedBox.shrink();
                } else {
                  return FlowFabMenuWidget(
                    items: [
                      FlowFabMenu(
                        icon: Icons.message,
                        tooltip: 'Message',
                        onPressed: () =>
                            context.showSnackBar(message: 'Message sent'),
                      ),
                      FlowFabMenu(
                        icon: Icons.charging_station,
                        tooltip: 'Notify',
                        onPressed: () => context.showNotify(),
                      ),
                      FlowFabMenu(
                        icon: Icons.chair,
                        tooltip: 'Banner',
                        onPressed: () => context.showM3Banner(
                          message: 'Message sent',
                          actions: [
                            ActionWidget(
                              style: ActionStyle.material,
                              materialType: ActionMaterial.text,
                              onAction: () => context.hideM3Banner(),
                              label: 'Dismiss',
                            ),
                          ],
                        ),
                      ),
                      FlowFabMenu(
                        icon: Icons.info_outline,
                        tooltip: 'Info',
                        onPressed: () => showToast('Info tapped'),
                      ),
                    ],
                  );
                }
              },
            ),
            appBar: AppBar(
              title: const Text('Service'),
              bottom: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 3,
                indicatorAnimation: TabIndicatorAnimation.elastic,
                tabs: TabBarType.values
                    .map((e) => Tab(text: e.title, icon: Icon(e.icon)))
                    .toList(),
              ),
            ),
            body: switch (state) {
              ServiceInitial() ||
              ServiceLoading() => const CircularProgressIndicator().center,
              ServiceError(:final errMess) => Text(
                errMess ?? 'Something went wrong',
              ).center,
              ServiceSuccess() => TabBarView(
                controller: _tabController,
                children: [
                  const _FirstTab(),
                  const _SecondTab(),
                  const _ThirdTab(),
                ],
              ),
            },
          );
        },
      ),
    );
  }
}

class _FirstTab extends StatefulWidget {
  const _FirstTab();

  @override
  State<_FirstTab> createState() => _FirstTabState();
}

class _FirstTabState extends State<_FirstTab> {
  // Drives the red color-filter opacity applied to the third hero image via
  final _colorFilter = ValueNotifier<double>(0.5);

  @override
  void dispose() {
    _colorFilter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        HeroImageWidget(
          heroTag: '1',
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: FadeInImage.assetNetwork(
              placeholder: R.imagesIcArticleNotFound,
              image:
                  'https://iawildlife.org/wp-content/uploads/2021/02/1-Winter-Fox.jpg',
            ),
          ),
        ).equalExpand,
        const Divider(),
        const HeroImageWidget(
          heroTag: '2',
          preview: AspectRatio(
            aspectRatio: 1 / 1,
            child: CachedImageWidget(
              fit: BoxFit.contain,
              imageUrl:
                  'https://iawildlife.org/wp-content/uploads/2021/02/1-Winter-Fox.jpg',
            ),
          ),
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: CachedImageWidget(
              fit: BoxFit.cover,
              width: 200,
              imageUrl:
                  'https://iawildlife.org/wp-content/uploads/2021/02/1-Winter-Fox.jpg',
            ),
          ),
        ).equalExpand,
        const Divider(),
        Stack(
          children: [
            Row(
              children: [
                Row(
                  children: [
                    HeroImageWidget(
                      heroTag: '3',
                      child: AspectRatio(
                        aspectRatio: 1 / 1,
                        child: ValueListenableBuilder(
                          valueListenable: _colorFilter,
                          builder: (context, opacity, child) {
                            return ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                cs.primary.withValues(alpha: opacity),
                                BlendMode.srcIn,
                              ),
                              child: Image.asset(R.imagesIcArticleNotFound),
                            );
                          },
                        ),
                      ),
                    ).expanded,
                    ValueListenableBuilder(
                      valueListenable: _colorFilter,
                      builder: (context, opacity, child) {
                        return AnimatedPhysicalModel(
                          onEnd: () {},
                          color: cs.primary.withValues(alpha: opacity),
                          shadowColor: cs.shadow.withValues(
                            alpha: 1 - opacity,
                          ),
                          clipBehavior: .none,
                          elevation: 8,
                          borderRadius: .circular(50),
                          animateColor: true,
                          animateShadowColor: true,
                          shape: .circle,
                          curve: Curves.linear,
                          duration: 300.milliseconds,
                          child: const SizedBox(
                            width: 100,
                            height: 100,
                            child: Icon(Icons.android_rounded),
                          ),
                        );
                      },
                    ),
                  ],
                ).expanded,
                const VerticalDivider(),
                ValueListenableBuilder(
                  valueListenable: _colorFilter,
                  builder: (context, opacity, child) {
                    return RotatedBox(
                      quarterTurns: 3,
                      child: Slider(
                        value: opacity,
                        onChanged: (value) {
                          _colorFilter.value = value;
                        },
                        min: 0.0,
                        max: 1.0,
                      ),
                    );
                  },
                ),
              ],
            ),
            // Vertical strip built by rotating a horizontal ListView.
            // The SizedBox width is required: it bounds the rotated
            // scrollable so layout resolves before the semantics pass
            // (otherwise the new semantics engine asserts on dirty
            // parent data).
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              child: SizedBox(
                width: 30,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    scrollDirection: .horizontal,
                    shrinkWrap: true,
                    itemBuilder: (context, index) => Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2.0,
                        horizontal: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: cs.outline, width: .5),
                      ),
                      alignment: .center,
                      child: Text(
                        'Item ${index + 1}',
                        style: TextStyle(color: cs.onPrimaryContainer),
                      ),
                    ),
                    itemCount: 20,
                    separatorBuilder: (context, index) => const Gap(4.0),
                  ),
                ),
              ),
            ),
          ],
        ).equalExpand,
      ],
    ).symPad(horizontal: 0, vertical: 15.0);
  }
}

class _SecondTab extends StatefulWidget {
  const _SecondTab();

  @override
  State<_SecondTab> createState() => __SecondTabState();
}

class __SecondTabState extends State<_SecondTab> {
  final List<AnimationController> _controllers = [];
  double _durationMs = 500;
  bool _toggled = false;

  Duration get _dur => _durationMs.round().ms;

  // Auto-plays on mount (visible immediately); keeps controller for replay.
  Animate _controlled(Widget child) =>
      child.animate(onInit: (c) => _controllers.add(c));

  void _replay() {
    for (final c in _controllers) {
      c.duration = _dur;
      c.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'flutter_animate playground',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _section('Transform'),
              _grid([
                _Demo('fadeIn', _controlled(_box(cs.primary)).fadeIn()),
                _Demo(
                  'fade .3',
                  _controlled(_box(cs.primaryContainer)).fade(begin: .3),
                ),
                _Demo(
                  'scale',
                  _controlled(
                    _box(cs.secondary),
                  ).scale(begin: const Offset(.5, .5)),
                ),
                _Demo(
                  'scaleX',
                  _controlled(_box(cs.secondaryContainer)).scaleX(begin: 0),
                ),
                _Demo(
                  'scaleY',
                  _controlled(_box(cs.secondary)).scaleY(begin: 0),
                ),
                _Demo('rotate', _controlled(_box(cs.tertiary)).rotate()),
                _Demo('flip', _controlled(_box(cs.primary)).flip()),
                _Demo('flipH', _controlled(_box(cs.primaryContainer)).flipH()),
                _Demo('flipV', _controlled(_box(cs.primary)).flipV()),
                _Demo(
                  'move',
                  _controlled(
                    _box(cs.secondary),
                  ).move(begin: const Offset(-40, -40)),
                ),
                _Demo(
                  'moveX',
                  _controlled(_box(cs.secondaryContainer)).moveX(begin: -40),
                ),
                _Demo(
                  'moveY',
                  _controlled(_box(cs.secondary)).moveY(begin: 40),
                ),
                _Demo(
                  'slideX',
                  _controlled(_box(cs.tertiary)).slideX(begin: -1),
                ),
                _Demo(
                  'slideY',
                  _controlled(_box(cs.tertiaryContainer)).slideY(begin: 1),
                ),
              ]),
              _section('Filter / visual'),
              _grid([
                _Demo(
                  'blur',
                  _controlled(
                    _box(cs.secondary),
                  ).blur(begin: const Offset(12, 12), end: Offset.zero),
                ),
                _Demo(
                  'blurXY',
                  _controlled(
                    _box(cs.secondaryContainer),
                  ).blurXY(begin: 12, end: 0),
                ),
                _Demo(
                  'tint',
                  _controlled(
                    _box(cs.surfaceContainerHighest),
                  ).tint(color: cs.tertiaryContainer),
                ),
                _Demo(
                  'untint',
                  _controlled(
                    _box(cs.tertiaryContainer),
                  ).untint(color: cs.tertiaryContainer),
                ),
                _Demo(
                  'color',
                  _controlled(
                    _box(cs.surfaceContainerHigh),
                  ).color(end: cs.tertiary, blendMode: BlendMode.srcATop),
                ),
                _Demo(
                  'saturate',
                  _controlled(_box(cs.secondary)).saturate(begin: 0, end: 1),
                ),
                _Demo(
                  'desaturate',
                  _controlled(
                    _box(cs.secondary),
                  ).desaturate(begin: 0, end: 1),
                ),
                _Demo(
                  'boxShadow',
                  _controlled(_box(cs.tertiary)).boxShadow(
                    end: BoxShadow(
                      color: cs.shadow,
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ),
                ),
                _Demo(
                  'shimmer',
                  _controlled(
                    _box(cs.primaryContainer),
                  ).shimmer(color: cs.surfaceBright),
                ),
                _Demo('shake', _controlled(_box(cs.error)).shake(hz: 4)),
                _Demo(
                  'shakeX',
                  _controlled(_box(cs.errorContainer)).shakeX(hz: 4),
                ),
                _Demo(
                  'shakeY',
                  _controlled(_box(cs.error)).shakeY(hz: 4),
                ),
              ]),
              _section('Chained (.then)'),
              Center(
                child: _controlled(_box(cs.primary, size: 80))
                    .fadeIn()
                    .scale()
                    .then(delay: 100.ms)
                    .tint(color: cs.tertiary),
              ),
              _section('Builders: custom / toggle / swap'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _labeled(
                    'custom',
                    _controlled(_box(Colors.transparent)).custom(
                      builder: (context, value, child) => Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Color.lerp(cs.error, cs.primary, value),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  _labeled(
                    'toggle',
                    _controlled(const SizedBox.shrink()).toggle(
                      duration: 900.ms,
                      builder: (context, value, child) => Container(
                        width: 84,
                        height: 44,
                        alignment: Alignment.center,
                        color: value ? cs.tertiary : cs.surfaceContainerHighest,
                        child: Text(value ? 'Before' : 'After'),
                      ),
                    ),
                  ),
                  _labeled(
                    'swap',
                    _controlled(const Text('Before')).swap(
                      duration: 900.ms,
                      builder: (c, w) => const Text(
                        'After',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              _section('Visibility (show / hide)'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _labeled(
                    'show',
                    _controlled(
                      _box(cs.tertiary, size: 56),
                    ).show(delay: 500.ms, maintain: true),
                  ),
                  _labeled(
                    'hide',
                    _controlled(
                      _box(cs.error, size: 56),
                    ).hide(delay: 500.ms, maintain: true),
                  ),
                ],
              ),
              _section('Loop (onPlay repeat)'),
              Center(
                child:
                    Container(
                          width: 220,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Loading…',
                            style: TextStyle(color: cs.onPrimaryContainer),
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat())
                        .shimmer(duration: 1200.ms, color: cs.surfaceBright),
              ),
              _section('Toggle (target)'),
              Center(
                child: GestureDetector(
                  onTap: () => setState(() => _toggled = !_toggled),
                  child: _box(cs.tertiary, size: 80)
                      .animate(target: _toggled ? 1 : 0)
                      .scaleXY(end: 1.3, duration: 300.ms)
                      .rotate(end: .25),
                ),
              ),
              const SizedBox(height: 8),
              const Center(child: Text('Tap the orange box to toggle')),
              _section('Staggered list (AnimateList)'),
              ...List<Widget>.generate(
                4,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    tileColor: cs.secondaryContainer,
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text('Item ${i + 1}'),
                  ),
                ),
              ).animate(interval: 120.ms).fadeIn().slideX(begin: .2, end: 0),
              const SizedBox(height: 16),
            ],
          ),
        ),
        _controlBar(),
      ],
    );
  }

  Widget _controlBar() => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined),
          const SizedBox(width: 8),
          SizedBox(width: 64, child: Text('${_durationMs.round()}ms')),
          Expanded(
            child: Slider(
              min: 100,
              max: 2000,
              divisions: 19,
              value: _durationMs,
              label: '${_durationMs.round()}ms',
              onChanged: (v) => setState(() => _durationMs = v),
            ),
          ),
          FilledButton.icon(
            onPressed: _replay,
            icon: const Icon(Icons.replay),
            label: const Text('Replay'),
          ),
        ],
      ),
    ),
  );

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 12),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  Widget _grid(List<_Demo> demos) => GridView.count(
    crossAxisCount: 3,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    children: demos
        .map(
          (d) => Column(
            children: [
              Expanded(child: Center(child: d.child)),
              const SizedBox(height: 6),
              Text(d.label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        )
        .toList(),
  );

  Widget _box(Color color, {double size = 48}) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
  );

  // A single demo cell with a fixed-height slot above its label, used by the
  // builder and visibility sections (which are laid out in a Row).
  Widget _labeled(String label, Widget child) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(height: 64, child: Center(child: child)),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}

class _Demo {
  final String label;
  final Widget child;
  const _Demo(this.label, this.child);
}

class Test {
  final String id;
  final String title;
  final int score;
  final double average;
  final bool isPassed;

  const Test({
    required this.id,
    required this.title,
    required this.score,
    required this.average,
    required this.isPassed,
  });
}

class _ThirdTab extends StatefulWidget {
  const _ThirdTab();

  @override
  State<_ThirdTab> createState() => _ThirdTabState();
}

class _ThirdTabState extends State<_ThirdTab> with TickerProviderStateMixin {
  late final TabController _tabController;
  late final PageController _pageController;

  late final ValueNotifier<List<Test>> testNotifier;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();

    testNotifier = ValueNotifier<List<Test>>([]);
    testNotifier.value = randomList(
      10,
      (i) => Test(
        id: 'test_$i',
        title: DataGenerationType.string.generate(),
        score: DataGenerationType.integer.generate(),
        average: DataGenerationType.double.generate(),
        isPassed: DataGenerationType.bool.generate(),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    testNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: .bottomCenter,
      children: [
        PageView(
          controller: _pageController,
          children: [
            _firstPageView,
            _secondPageView,
            _thirdPageView,
          ],
          onPageChanged: (index) {
            _tabController.index = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          },
        ),
        TabPageSelector(
          controller: _tabController,
          color: context.colorScheme.surface,
          selectedColor: context.colorScheme.primary,
        )
      ],
    );
  }

  CustomScrollView get _firstPageView => CustomScrollView(
    slivers: [
      const SliverToBoxAdapter(
        child: CollapsibleTextWidget(
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since 1966, when designers at Letraset and James Mosley, the librarian at St Bride Printing Library in London, took a 1914 Cicero translation and scrambled it to make dummy text for Letraset\'s Body Type sheets. It has survived not only many decades, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised thanks to these sheets and more recently with desktop publishing software like Aldus PageMaker and Microsoft Word including versions of Lorem Ipsum.',
          maxLines: 3,
          readMoreText: 'Show more',
          readLessText: 'Show less',
        ),
      ),
      SliverList.separated(
        itemBuilder: (context, index) => Text(DataGenerationType.values[index].generate().toString()),
        separatorBuilder: (context, index) => const Gap(10),
        itemCount: DataGenerationType.values.length,
      ),
      ValueListenableBuilder(
        valueListenable: testNotifier,
        builder: (context, tests, child) {
          return SliverPadding(
            padding: const EdgeInsets.all(10.0),
            sliver: SliverReorderableList(
              itemBuilder: (context, index) => ReorderableDelayedDragStartListener(
                key: ValueKey(tests[index].id),
                index: index,
                child: Card(
                  child: ListTile(
                    title: Text(tests[index].title),
                    subtitle: Text('Score: ${tests[index].score}'),
                    isThreeLine: true,
                    trailing: ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle_rounded)),
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                  ),
                ),
              ),
              itemCount: tests.length,
              onReorderItem: (oldIndex, newIndex) {
                final list = [...tests];
                if (newIndex > oldIndex) newIndex -= 1;
                list.insert(newIndex, list.removeAt(oldIndex));
                testNotifier.value = list;
              },
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) {
                    final t = Curves.easeInOut.transform(animation.value);
                    return Transform.scale(
                      scale: 1 + 0.03 * t, // 1.0 → 1.03
                      child: Material(
                        elevation: 8 * t, // 0 → 8
                        color: Colors.transparent,
                        shadowColor: Theme.of(context).colorScheme.shadow,
                        borderRadius: BorderRadius.circular(12),
                        child: child,
                      ),
                    );
                  },
                );
              },
            ),
          );
        }
      ),
    ],
  );

  Widget get _secondPageView => const AnimationTextShowcase();

  Widget get _thirdPageView => const Placeholder();
}

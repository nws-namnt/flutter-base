import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_base/base.dart';
import 'package:flutter_base/common/app_extension.dart';
import 'package:flutter_base/pages/widgets/action_widget.dart';
import 'package:flutter_base/utils/extensions/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../common/app_dimensions.dart';
import '../../common/app_enums.dart';
import '../widgets/share_widget.dart';
import 'explore_cubit.dart';
import 'explore_state.dart';

/// The Explore tab screen, hosted inside the navigation shell at [Routers.explore].
///
/// Placeholder browse/search UI — a search field over a grid of category
/// tiles. Instantiates and owns its [ExploreCubit]; the cubit is closed in
/// [dispose].
class ExplorePage extends StatefulWidget {
  /// Creates an [ExplorePage].
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with TickerProviderStateMixin {
  final LayerLink _carouselLink = LayerLink();

  late final ExploreCubit _cubit;

  late final CarouselController _carouselController;

  late final OverlayPortalController _overlayPortalController;

  // Drives the size pulse — oscillates back and forth, so it needs
  // repeat(reverse: true).
  late final AnimationController _sizeController;
  late final Animation<double> _sizeAnimation;

  // Drives the spin — must NOT reverse, otherwise it winds forward then
  // unwinds backward instead of spinning continuously in one direction.
  // A plain repeat() restarts at 0 every time it hits 1 turn, which looks
  // seamless since 1 full turn is visually identical to 0.
  late final AnimationController _rotationController;
  late final AnimationController _refreshIconController;

  final GlobalKey _k1 = GlobalKey(debugLabel: 'firstModal');
  final GlobalKey _k2 = GlobalKey(debugLabel: 'secondModal');

  final _isOverlayVisible = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _sizeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _sizeAnimation = Tween<double>(begin: 20, end: 30).animate(
      CurvedAnimation(parent: _sizeController, curve: Curves.easeInOut),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _carouselController = CarouselController(initialItem: 1);

    _refreshIconController = AnimationController(
      vsync: this,
      duration: 1200.milliseconds,
    )..repeat();

    _overlayPortalController = OverlayPortalController();

    _cubit = ExploreCubit();
  }

  @override
  void dispose() {
    _sizeController.dispose();
    _rotationController.dispose();
    _cubit.close();
    super.dispose();
  }

  // Returns null instead of throwing when `key`'s widget isn't currently
  // mounted — e.g. while its Visibility/Offstage ancestor has it hidden, in
  // which case the subtree (and its RenderObject) doesn't exist at all.
  Size? _getSize(GlobalKey key) {
    final renderObject = key.currentContext?.findRenderObject();
    return renderObject is RenderBox ? renderObject.size : null;
  }

  // Shared by the "Action 1" button and the ArrowLeft shortcut, so both
  // trigger the exact same behavior.
  void _onAction1() {
    final size = _getSize(_k1);
    if (size != null) {
      context.showNotify(
        messageText: 'Flutter Logo size is $size',
        type: NotifyType.success,
      );
    }
    _cubit.toggleFirstModal();
  }

  // Shared by the "Action 2" button and the ArrowRight shortcut.
  void _onAction2() {
    final size = _getSize(_k2);
    if (size != null) {
      context.showNotify(
        messageText: 'Flutter Logo size is $size',
        type: NotifyType.success,
      );
    }
    _cubit.toggleSecondModal();
  }

  void _onToggleOverlayPortal() {
    _isOverlayVisible.value = !_isOverlayVisible.value;
    _overlayPortalController.toggle();
  }

  @override
  Widget build(BuildContext context) {
    // CallbackShortcuts only fires while focus is somewhere inside its
    // subtree — Focus(autofocus: true) grabs that focus as soon as the page
    // loads, so the arrows work immediately without the user tapping
    // anything first. Note: once the search field itself has focus, its own
    // text-editing behavior consumes ArrowLeft/ArrowRight first (cursor
    // movement) — the shortcuts won't fire while typing there.
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): _onAction1,
        const SingleActivator(LogicalKeyboardKey.arrowRight): _onAction2,
      },
      child: Focus(
        autofocus: true,
        child: BlocProvider.value(
          value: _cubit,
          child: BlocBuilder<ExploreCubit, ExploreState>(
            builder: (context, state) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Explore'),
                  actions: [
                    RotationRefresh(listenable: _refreshIconController),
                    ValueListenableBuilder(
                      valueListenable: _isOverlayVisible,
                      builder: (context, isOverlayVisible, child) {
                        return IconButton(
                          isSelected: isOverlayVisible,
                          onPressed: _onToggleOverlayPortal,
                          icon: const Icon(Icons.toggle_off),
                          selectedIcon: Icon(
                            Icons.toggle_on,
                            color: isOverlayVisible ? Colors.blue : Colors.transparent,
                          ),
                        );
                      }
                    ),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                body: ListView(
                  primary: true,
                  padding: const EdgeInsets.all(AppDimensions.padding),
                  children: [
                    OverlayPortal(
                      controller: _overlayPortalController,
                      overlayLocation: OverlayChildLocation.nearestOverlay,
                      overlayChildBuilder: (context) => CompositedTransformFollower(
                        link: _carouselLink,
                        targetAnchor: Alignment.center,
                        followerAnchor: Alignment.center,
                        offset: const Offset(-40, 0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(width: .5),
                            ),
                            child: const Text('I am FOX!'),
                          ),
                        ),
                      ),
                      child: CompositedTransformTarget(
                        link: _carouselLink,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: context.heightPx / 3,
                          ),
                          child: CarouselView.weightedBuilder(
                            controller: _carouselController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacing,
                            ),
                            flexWeights: const [1, 7, 1],
                            itemSnapping: true,
                            infinite: true,
                            itemCount: state.carousels.length,
                            itemBuilder: (context, index) {
                              final constraintWidth = context.widthPx * 7 / 8;
                              final constraintHeight = context.heightPx / 3;

                              final carousel = state.carousels[index];

                              return Stack(
                                alignment: .bottomStart,
                                children: <Widget>[
                                  ClipRect(
                                    child: OverflowBox(
                                      maxWidth: constraintWidth,
                                      minWidth: constraintWidth,
                                      maxHeight: constraintHeight,
                                      minHeight: constraintHeight,
                                      child: HeroImageWidget(
                                        heroTag: 'tag_$index',
                                        child: Image.asset(
                                          carousel.imagePath,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const .all(18.0),
                                    child: Column(
                                      crossAxisAlignment: .start,
                                      mainAxisSize: .min,
                                      children: <Widget>[
                                        Text(
                                          carousel.title,
                                          overflow: .clip,
                                          softWrap: false,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.headlineMedium,
                                        ),
                                        const Gap(10),
                                        Text(
                                          carousel.description,
                                          overflow: .clip,
                                          softWrap: false,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                        const Gap(10),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SearchAnchor.bar(
                      barHintText: 'Search categories',
                      barLeading: const Icon(Icons.search),
                      // Approximates the old TextField's OutlineInputBorder —
                      // SearchBar is shaped via barShape/barSide (a Material
                      // OutlinedBorder), not an InputDecoration border, so it
                      // can't be reused as-is.
                      barShape: const WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                      barSide: WidgetStatePropertyAll(
                        BorderSide(color: Theme.of(context).colorScheme.outline),
                      ),
                      // Same action as before: every keystroke still updates
                      // the grid below via the cubit, independent of the
                      // suggestions dropdown.
                      onChanged: _cubit.onSearchChanged,
                      // Suggestions are always filtered from the full category
                      // list (not state.filteredCategories) — that field is
                      // already query-filtered for the grid below, filtering it
                      // again here would just narrow the dropdown to whatever
                      // is currently typed, hiding every other match.
                      suggestionsBuilder: (context, controller) {
                        // if (controller.text.isEmpty) {
                        //   return const Iterable<Widget>.();
                        // }
                        final query = controller.text.toLowerCase();
                        return state.categories
                            .where(
                              (category) =>
                                  category.toLowerCase().contains(query),
                            )
                            .map(
                              (category) => ListTile(
                                title: Text(category),
                                onTap: () {
                                  controller.closeView(category);
                                  _cubit.onSearchChanged(category);
                                },
                              ),
                            );
                      },
                    ),
                    const SizedBox(height: AppDimensions.padding),
                    SizedBox(
                      height: context.heightPx / 3,
                      child: state.filteredCategories.isEmpty
                          ? const Center(child: Text('No categories found'))
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: AppDimensions.padding,
                                    crossAxisSpacing: AppDimensions.padding,
                                  ),
                              primary: false,
                              itemCount: state.filteredCategories.length,
                              itemBuilder: (context, index) {
                                final category =
                                    state.filteredCategories[index];
                                return Card(
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: () {},
                                    child: Center(
                                      child: Text(
                                        category,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const Gap(AppDimensions.padding),
                    const Divider(height: 1, thickness: 1),
                    const Gap(AppDimensions.padding),
                    Row(
                      children: [
                        BlocBuilder<ExploreCubit, ExploreState>(
                          buildWhen: (pre, cur) =>
                              pre.firstModalVisible != cur.firstModalVisible,
                          builder: (context, state) {
                            return Column(
                              children: [
                                Visibility(
                                  visible: state.firstModalVisible,
                                  child: AnimatedBuilder(
                                    animation: Listenable.merge([
                                      _sizeController,
                                      _rotationController,
                                    ]),
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle:
                                            _rotationController.value *
                                            2 *
                                            math.pi,
                                        child: Container(
                                          key: _k1,
                                          height: _sizeAnimation.value,
                                          width: 50 - _sizeAnimation.value,
                                          decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                ActionWidget(
                                  materialType: ActionMaterial.text,
                                  onAction: _onAction1,
                                  label: 'Action 1',
                                ),
                              ],
                            );
                          },
                        ).equalExpand,
                        BlocBuilder<ExploreCubit, ExploreState>(
                          buildWhen: (pre, cur) =>
                              pre.secondModalVisible != cur.secondModalVisible,
                          builder: (context, state) {
                            return Column(
                              children: [
                                Offstage(
                                  offstage: state.secondModalVisible,
                                  child: AnimatedBuilder(
                                    animation: Listenable.merge([
                                      _sizeController,
                                      _rotationController,
                                    ]),
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle:
                                            _rotationController.value *
                                            2 *
                                            math.pi,
                                        child: Container(
                                          key: _k2,
                                          height: _sizeAnimation.value,
                                          width: 50 - _sizeAnimation.value,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                ActionWidget(
                                  materialType: ActionMaterial.text,
                                  onAction: _onAction2,
                                  label: 'Action 2',
                                ),
                              ],
                            );
                          },
                        ).equalExpand,
                      ],
                    ),
                    const ShareWidget(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A refresh icon that continuously rotates, driven by the [listenable]
/// animation (expected to be a 0→1 [Animation] on a repeating controller).
class RotationRefresh extends AnimatedWidget {
  /// Creates a [RotationRefresh] bound to [listenable].
  const RotationRefresh({super.key, required super.listenable});

  Animation<double> get _turn => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _turn.value * 2 * math.pi,
      child: const Icon(Icons.refresh_rounded),
    );
  }
}

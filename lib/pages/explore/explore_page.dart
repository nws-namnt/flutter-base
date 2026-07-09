import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_base/pages/widgets/action_widget.dart';
import 'package:flutter_base/utils/extensions/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../common/app_dimensions.dart';
import '../../common/app_enums.dart';
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
  late final ExploreCubit _cubit;

  // Drives the size pulse — oscillates back and forth, so it needs
  // repeat(reverse: true).
  late final AnimationController _sizeController;
  late final Animation<double> _sizeAnimation;

  // Drives the spin — must NOT reverse, otherwise it winds forward then
  // unwinds backward instead of spinning continuously in one direction.
  // A plain repeat() restarts at 0 every time it hits 1 turn, which looks
  // seamless since 1 full turn is visually identical to 0.
  late final AnimationController _rotationController;

  final GlobalKey _k1 = GlobalKey(debugLabel: 'firstModal');

  final GlobalKey _k2 = GlobalKey(debugLabel: 'secondModal');

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
            appBar: AppBar(title: const Text('Explore')),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            body: Padding(
              padding: const EdgeInsets.all(AppDimensions.padding),
              child: Column(
                children: [
                  Autocomplete<String>(
                    // Suggestions are always filtered from the full category
                    // list (not state.filteredCategories) — that field is
                    // already query-filtered for the grid below, filtering it
                    // again here would just narrow the dropdown to whatever
                    // is currently typed, hiding every other match.
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      final query = textEditingValue.text.toLowerCase();
                      return state.categories.where(
                        (category) => category.toLowerCase().contains(query),
                      );
                    },
                    onSelected: _cubit.onSearchChanged,
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: _cubit.onSearchChanged,
                        decoration: const InputDecoration(
                          hintText: 'Search categories',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
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
                            itemCount: state.filteredCategories.length,
                            itemBuilder: (context, index) {
                              final category = state.filteredCategories[index];
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
                  const Divider(
                    height: 1,
                    thickness: 1,
                  ),
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
                                      _rotationController.value * 2 * math.pi,
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
                ],
              ),
            ),
          );
            },
          ),
        ),
      ),
    );
  }
}

import 'package:animations/animations.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_base/base.dart';
import 'package:flutter_base/utils/app_utils.dart';
import 'package:flutter_base/utils/extensions/widget_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../common/app_enums.dart' show DismissSwipeAction;
import '../../utils/completer_util.dart';
import '../../utils/extensions/enum_extension.dart';
import '../widgets/badge_widget.dart';
import '../widgets/empty_widget.dart';
import 'home_cubit.dart';
import 'home_state.dart';

/// The Home tab screen, hosted inside the navigation shell at [Routers.home].
///
/// Instantiates and owns its [HomeCubit]; the cubit is closed in [dispose].
class HomePage extends StatefulWidget {
  /// Creates a [HomePage].
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final HomeCubit _cubit;
  late final AnimationController _menuIconController;
  late final AnimationController _viewIconController;

  late final ScrollController _listScrollController;
  late final ScrollController _gridScrollController;

  late final ValueNotifier<ContentSensitivity> sensitive;

  late ThemeData _theme;

  @override
  void initState() {
    super.initState();
    _cubit = HomeCubit()..initialize();

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

    _menuIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _viewIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _listScrollController = ScrollController();
    _listScrollController.addListener(() => _handleScroll(_listScrollController));

    _gridScrollController = ScrollController();
    _gridScrollController.addListener(() => _handleScroll(_gridScrollController));

    sensitive = ValueNotifier<ContentSensitivity>(ContentSensitivity.notSensitive);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
  }

  @override
  void dispose() {
    _cubit.close();
    _menuIconController.dispose();
    _viewIconController.dispose();
    _listScrollController.dispose();
    _gridScrollController.dispose();
    sensitive.dispose();
    super.dispose();
  }

  // Docks the FAB to the top when the active scroll view reaches its bottom
  // edge, otherwise back to floating. Shared by both list and grid controllers.
  void _handleScroll(ScrollController c) {
    _cubit.moveFab(isTop: c.position.atEdge && c.position.pixels != 0.0);
  }

  // Opens/closes the drawer via the Scaffold key. A GlobalKey is required
  // here because this context sits above the Scaffold in the tree, so
  // Scaffold.of(context) is not available from the leading button.
  void _toggleDrawer() {
    final scaffold = _scaffoldKey.currentState;
    if (scaffold == null) return;
    if (scaffold.isDrawerOpen) {
      scaffold.closeDrawer();
    } else {
      scaffold.openDrawer();
    }
  }

  // Drives the menu/home AnimatedIcon in sync with the drawer open state.
  void _onDrawerChanged(bool isOpened) {
    if (isOpened) {
      _menuIconController.forward();
    } else {
      _menuIconController.reverse();
    }
  }

  // Switches the body between grid and reorderable-list layouts.
  void _toggleViewType() {
    _cubit.toggleViewType();
  }

  // Toggles the SensitiveContent wrapper below between sensitive and
  // notSensitive so it can be exercised manually from the UI.
  void _changeSensitiveContent() {
    final currentSensitive = sensitive.value;

    if (currentSensitive != ContentSensitivity.sensitive) {
      sensitive.value = ContentSensitivity.sensitive;
    } else {
      sensitive.value = ContentSensitivity.notSensitive;
    }
  }

  // When the FAB has moved to endTop (list scrolled to the bottom), pressing
  // it scrolls back to the top. Otherwise it runs the default add action.
  void _onFabPressed(HomeState state) {
    if (state is HomeSuccess && state.isTop) {
      if (state.isGridView) {
        _gridScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      } else {
        _listScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    }

    _cubit.addItem();
    showToast('Add Item Successful');
  }

  // Closes the drawer, then shows the standard Flutter about dialog.
  // Closing via the Scaffold key (not Navigator.pop from this context) for
  // the same reason as _toggleDrawer above.
  Future<void> _onAboutTap(BuildContext context) async {
    _scaffoldKey.currentState?.closeDrawer();
    final packageInfo = await PackageInfo.fromPlatform();
    if (!context.mounted) return;

    // showAboutDialog is the real Flutter API for this — it doesn't expose a
    // transitionBuilder, so it always plays Material's default dialog
    // transition (no FadeWrapper hook here, unlike _onDeviceInfoTap below).
    showAboutDialog(
      context: context,
      applicationName: packageInfo.fullVersion,
      applicationVersion: packageInfo.displayVersion,
      applicationIcon: const FlutterLogo(),
      children: const [
        Text(
          'Flutter production boilerplate built on BLoC/Cubit, GoRouter, and Material 3.',
        ),
      ],
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
    );
  }

  // Closes the drawer, then shows a device/app info dialog transitioned with
  // FadeWrapper. Built on showGeneralDialog (rather than showDialog) because
  // only showGeneralDialog exposes the transitionBuilder hook FadeWrapper
  // needs to drive.
  Future<void> _onDeviceInfoTap(BuildContext context) async {
    _scaffoldKey.currentState?.closeDrawer();

    // final result = await context.showConfirmDialog(
    //     title: 'Are you sure to open the device info?',
    //     message: 'This will show you the device info.',
    // );

    final result = await context.pushNamed(Routers.confirmDialog.routerName);

    if (result != null) {
      final packageInfo = await PackageInfo.fromPlatform();
      final devicePlugin = DeviceInfoPlugin();
      final platformName = devicePlugin.platformName;
      final osVersion = await devicePlugin.osVersion;
      final deviceModel = await devicePlugin.deviceModel;
      if (!context.mounted) return;

      showGeneralDialog<void>(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 150),
        pageBuilder: (context, animation, secondaryAnimation) {
          return SafeArea(
            child: AlertDialog(
              title: const Text('Device info'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App: ${packageInfo.appName} ${packageInfo.displayVersion}',
                  ),
                  const SizedBox(height: 8),
                  Text('Platform: $platformName'),
                  const SizedBox(height: 8),
                  Text('OS version: $osVersion'),
                  const SizedBox(height: 8),
                  Text('Device: $deviceModel'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return FadeWrapper(animation: animation, child: child);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<HomeCubit, HomeState>(
        listenWhen: (previous, current) =>
            previous is HomeSuccess &&
            current is HomeSuccess &&
            previous.isGridView != current.isGridView,
        listener: (context, state) {
          final isGridView = (state as HomeSuccess).isGridView;
          if (isGridView) {
            _viewIconController.forward();
          } else {
            _viewIconController.reverse();
          }
        },
        // Rebuilds the whole screen on every HomeState change.
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return SafeArea(
              child: Scaffold(
                key: _scaffoldKey,
                floatingActionButton: FloatingActionButton(
                  onPressed: () => _onFabPressed(state),
                  child: (state is HomeSuccess)
                      ? Icon(state.isTop ? Icons.arrow_downward : Icons.add)
                      : empty,
                ),
                floatingActionButtonLocation: (state is HomeSuccess)
                    ? state.fabLocation
                    : FloatingActionButtonLocation.endFloat,
                floatingActionButtonAnimator: FabAnimator(),
                appBar: AppBar(
                  backgroundColor: _theme.colorScheme.surface,
                  leading: IconButton(
                    icon: AnimatedIcon(
                      icon: AnimatedIcons.menu_home,
                      progress: _menuIconController,
                    ),
                    onPressed: _toggleDrawer,
                  ),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Home'),
                      const Gap(8),
                      BadgeWidget.shake(
                        badgeCount: state is HomeSuccess ? state.archived.length : 0,
                      ),
                    ],
                  ),
                  actions: [
                    ValueListenableBuilder(
                      valueListenable: sensitive,
                      builder: (context, s, child) {
                        return ElevatedButton.icon(
                          onPressed: _changeSensitiveContent,
                          icon: const Icon(Icons.sensors_outlined),
                          label: Text(s.value),
                        );
                      }
                    ),
                    IconButton(
                      icon: AnimatedIcon(
                        icon: AnimatedIcons.list_view,
                        progress: _viewIconController,
                      ),
                      onPressed: _toggleViewType,
                    ),
                  ],
                ),
                drawer: Drawer(
                  backgroundColor: _theme.colorScheme.surface,
                  child: Column(
                    children: [
                      ListenableBuilder(
                        listenable: routerNotifier,
                        builder: (context, _) {
                          final user = routerNotifier.currentUser;
                          final isSignedIn = user != null;

                          final header = UserAccountsDrawerHeader(
                            currentAccountPicture: CircleAvatar(
                              backgroundImage: user?.photoURL != null
                                  ? NetworkImage(user!.photoURL!)
                                  : null,
                              child: user?.photoURL == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            accountName: Text(user?.displayName ?? 'Guest'),
                            accountEmail: Text(user?.email ?? 'Not signed in'),
                            onDetailsPressed: isSignedIn ? null : () {
                              _scaffoldKey.currentState?.closeDrawer();
                              context.push(Routers.login.routerPath);
                            },
                          );

                          if (!isSignedIn) return header;

                          return GestureDetector(
                            onTap: () {
                              _scaffoldKey.currentState?.closeDrawer();
                              context.push(Routers.profile.routerPath);
                            },
                            child: header,
                          );
                        },
                      ),
                      const Spacer(),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('About'),
                        onTap: () => _onAboutTap(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.smartphone_outlined),
                        title: const Text('Device info'),
                        onTap: () => _onDeviceInfoTap(context),
                      ),
                    ],
                  ),
                ),
                onDrawerChanged: _onDrawerChanged,
                body: switch (state) {
                  HomeInitial() ||
                  HomeLoading() => const CircularProgressIndicator().center,
                  HomeSuccess(:final data, :final isGridView) =>
                    PageTransitionSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (child, primaryAnimation, secondaryAnimation) {
                            return FadeThroughTransition(
                              animation: primaryAnimation,
                              secondaryAnimation: secondaryAnimation,
                              child: child,
                            );
                          },
                      child: ValueListenableBuilder(
                        valueListenable: sensitive,
                        builder: (context, s, child) {
                          return SensitiveContent(
                            sensitivity: s,
                            child: isGridView
                                ? _buildGrid(data)
                                : _buildReorderableList(data),
                          );
                        }
                      ),
                    ),
                  HomeError(:final errMess) => Text(
                    errMess ?? 'Something went wrong',
                  ).center,
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // Builds the reorderable list with swipe-to-archive (right) and
  // swipe-to-delete (left) actions per item.
  Widget _buildReorderableList(List<String> data) {
    return RefreshIndicator(
      onRefresh: () => _cubit.initialize(),
      child: ReorderableListView.builder(
        key: const ValueKey('home_list_view'),
        scrollController: _listScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        physics: const BouncingScrollPhysics(),
        buildDefaultDragHandles: false,
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          // startToEnd (swipe right) archives, endToStart (swipe left) deletes.
          // Both confirm first; onDismissed then moves the item out of [data]
          // so the dismissed widget leaves the tree in sync (avoids a crash).
          return Dismissible(
            key: ValueKey(item),
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                _cubit.archiveItem(item);
                showToast('Archived item $item');
              } else {
                _cubit.removeItem(item);
                showToast('Deleted item $item');
              }
            },
            direction: DismissDirection.horizontal,
            background: const _DismissibleItem(),
            secondaryBackground: const _DismissibleItem.secondary(),
            confirmDismiss: (direction) async {
              final result = SafeCompleter<bool>();
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('${direction == .startToEnd ? 'Archive' : 'Delete'} item $item?'),
                  actions: [
                    TextButton.icon(
                      onPressed: () {
                        result.complete(false);
                        ctx.backDialog;
                      },
                      label: const Text('Cancel'),
                      icon: const Icon(Icons.cancel_rounded),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        result.complete(true);
                        ctx.backDialog;
                      },
                      label: Text(direction == .startToEnd ? 'Archive' : 'Delete'),
                      icon: Icon(direction == .startToEnd
                          ? Icons.archive_rounded
                          : Icons.delete_rounded),
                    ),
                  ],
                ),
              ).whenComplete(() => result.complete(false));

              return result.future;
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: OpenContainerWrapper<void>(
                tappable: false,
                closedElevation: 1,
                closedShape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                closedColor: index.isOdd ? AppColors.oldLace : AppColors.darkRaisin,
                closedBuilder: (context, openContainer) {
                  return ListTile(
                    onTap: openContainer,
                    textColor: index.isOdd
                        ? AppColors.darkRaisin
                        : AppColors.oldLace,
                    title: Text('Item $item'),
                    trailing: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                  );
                },
                openBuilder: (context, _) => HomeDetailPage(item: item),
              ),
            ),
          );
        },
        onReorderItem: (int oldIndex, int newIndex) {
          _cubit.reOrderItem(oldIndex, newIndex);
        },
      ),
    );
  }

  // Builds the two-column grid layout (no swipe actions).
  Widget _buildGrid(List<String> data) {
    return GridView.builder(
      key: const ValueKey('home_grid_view'),
      controller: _gridScrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return OpenContainerWrapper<void>(
          closedElevation: 1,
          closedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          closedColor: index.isOdd ? AppColors.oldLace : AppColors.darkRaisin,
          closedBuilder: (context, openContainer) {
            return Center(
              child: Text(
                'Item $item',
                style: TextStyle(
                  color: index.isOdd ? AppColors.darkRaisin : AppColors.oldLace,
                ),
              ),
            );
          },
          openBuilder: (context, _) => HomeDetailPage(item: item),
        );
      },
    );
  }
}

/// Colored background revealed behind a home item while it is being swiped.
///
/// Default constructor is the archive affordance (aligned left);
/// [_DismissibleItem.secondary] is the delete affordance (aligned right).
class _DismissibleItem extends StatelessWidget {
  /// Archive background — shown when swiping start-to-end.
  const _DismissibleItem() : swipeAction = .archive;

  /// Delete background — shown when swiping end-to-start.
  const _DismissibleItem.secondary() : swipeAction = .delete;

  final DismissSwipeAction swipeAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isArchive = swipeAction == .archive;

    return Container(
      decoration: BoxDecoration(
        color: isArchive
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: isArchive ? Alignment.centerLeft : Alignment.centerRight,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(
        isArchive ? Icons.archive_rounded : Icons.delete_rounded,
        color: isArchive
          ? theme.colorScheme.onPrimaryContainer
          : theme.colorScheme.onErrorContainer,
      ),
    );
  }
}

/// Animates the [HomePage] floating action button between its docked
/// positions with a linear offset tween and an eased rotate/scale effect.
class FabAnimator extends FloatingActionButtonAnimator {
  /// Linearly interpolates the FAB's position from [begin] to [end] at
  /// [progress].
  @override
  Offset getOffset({
    required Offset begin,
    required Offset end,
    required double progress,
  }) {
    final x = begin.dx + (end.dx - begin.dx) * progress;
    final y = begin.dy + (end.dy - begin.dy) * progress;
    return Offset(x, y);
  }

  /// Rotation animation played alongside the position change, eased with
  /// [Curves.easeInOutSine].
  @override
  Animation<double> getRotationAnimation({
    required Animation<double> parent,
  }) {
    return Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        curve: Curves.easeInOutSine,
        parent: parent,
      ),
    );
  }

  /// Scale animation played alongside the position change, eased with
  /// [Curves.easeInOutSine].
  @override
  Animation<double> getScaleAnimation({
    required Animation<double> parent,
  }) {
    return CurvedAnimation(
      curve: Curves.easeInOutSine,
      parent: parent,
    );
  }
}

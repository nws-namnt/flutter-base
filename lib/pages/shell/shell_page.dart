import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/animated_bottom_navigation_widget.dart';
import '../widgets/transition_shell_widget.dart' show ShellTransitionType;

/// Root scaffold for the bottom-navigation shell.
///
/// Wraps [AnimatedBranchContainer] (the tab body) and a [NavigationBar].
/// Re-tapping the active tab calls `shell.goBranch(index, initialLocation: true)`
/// which pops nested routes back to the branch root.
///
/// Built by [router_config.dart]'s `navigatorContainerBuilder` callback;
/// not instantiated directly in app code.
class ShellPage extends StatelessWidget {
  /// The [StatefulNavigationShell] provided by GoRouter.
  final StatefulNavigationShell shell;

  /// Prebuilt branch widgets from GoRouter's navigator container builder.
  final List<Widget> children;

  /// Creates a [ShellPage].
  const ShellPage({super.key, required this.shell, required this.children});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: AnimatedBranchContainer(
          currentIndex: shell.currentIndex,
          transitionType: ShellTransitionType.fade,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          children: children,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (index) => shell.goBranch(
            index,
            // Re-tap active tab → pop to branch root
            initialLocation: index == shell.currentIndex,
          ),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          animationDuration: const Duration(milliseconds: 150),
          height: 60,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
              tooltip: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.miscellaneous_services_outlined),
              selectedIcon: Icon(Icons.miscellaneous_services),
              label: 'Service',
              tooltip: 'Service',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
              tooltip: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

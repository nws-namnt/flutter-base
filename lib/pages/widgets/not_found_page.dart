import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/routers.dart';

/// 404 fallback page shown when no route matches.
///
/// Used as [GoRouter.errorBuilder] in [AppRouter] and wired to
/// [Routers.pageNotFound] in [router_config.dart].
/// Provides a "Go home" button that navigates to [Routers.home].
class NotFoundPage extends StatelessWidget {
  /// Creates a [NotFoundPage].
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('404', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Page not found'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go(Routers.home.routerPath),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    );
  }
}

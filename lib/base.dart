/// Flutter base project — production boilerplate built on BLoC/Cubit,
/// GoRouter, Material 3 theming, and multi-flavor Firebase support.
///
/// This library aggregates all five modules:
///
/// - **app** — global [AppCubit], [AppState], and [AppPage] root widget
/// - **common** — colors, theming, constants, and environment config
/// - **routing** — GoRouter setup, route registry, and navigation helpers
/// - **pages** — all screens, cubits, states, and shared widgets
/// - **utils** — structured logging and Dart/Flutter extension methods
// ignore: unnecessary_library_name
library base;

export 'app/app.dart';
export 'common/common.dart';
export 'pages/pages.dart';
export 'routing/routing.dart';
export 'utils/utils.dart';

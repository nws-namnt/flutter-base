enum Routers {
  /// Splash — entry point
  root('/', 'root'),

  /// Shell branches
  home('/home', 'home'),
  service('/service', 'service'),
  setting('/setting', 'setting'),

  /// Pages
  terms('/terms', 'terms'),
  privacy('/privacy', 'privacy'),

  /// Fallback
  pageNotFound('/pageNotFound', 'pageNotFound');

  final String routerPath;  /// Path used with context.go()
  final String routerName;  /// Name used with context.goNamed()

  const Routers(this.routerPath, this.routerName);
}
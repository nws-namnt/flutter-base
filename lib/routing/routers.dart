/// Centralised route registry for the app.
///
/// Each value pairs a URL [routerPath] (used with `context.go()`) with a
/// human-readable [routerName] (used with `context.goNamed()`).
///
/// Always add new routes here before wiring them in [router_config.dart].
enum Routers {
  /// Splash screen — app entry point (`/`).
  root('/', 'root'),

  /// Onboarding intro carousel (`/intro`), shown before the app shell.
  intro('/intro', 'intro'),

  /// Home tab inside the shell (`/home`).
  home('/home', 'home'),

  /// Service tab inside the shell (`/service`).
  service('/service', 'service'),

  /// Explore tab inside the shell (`/explore`).
  explore('/explore', 'explore'),

  /// Settings tab inside the shell (`/setting`).
  setting('/setting', 'setting'),

  /// Terms of Service page (`/terms`).
  terms('/terms', 'terms'),

  /// Privacy Policy page (`/privacy`).
  privacy('/privacy', 'privacy'),

  /// Hero image viewer page (`/imagePreview`).
  imagePreview('/imagePreview', 'imagePreview'),
  
  /// Bottom sheet
  languageSheet('/languageSheet', 'languageSheet'),

  /// AI support chat page (`/aiSupport`).
  /// Accepts `extra: {'screenName': 'Home'}` to inject context into the AI.
  aiSupport('/aiSupport', 'aiSupport'),

  /// User profile page (`/profile`).
  profile('/profile', 'profile'),

  /// Forgot password page (`/forgotPassword`).
  forgotPassword('/forgotPassword', 'forgotPassword'),

  /// Email verification page (`/emailVerification`).
  emailVerification('/emailVerification', 'emailVerification'),

  /// Phone number input page for phone auth (`/phoneInput`).
  phoneInput('/phoneInput', 'phoneInput'),

  /// SMS code input page — reached from [phoneInput] (`/smsCode`).
  smsCode('/smsCode', 'smsCode'),

  /// Login page (`/login`).
  login('/login', 'login'),

  /// Register page (`/register`).
  register('/register', 'register'),

  /// 404 fallback page (`/pageNotFound`).
  pageNotFound('/pageNotFound', 'pageNotFound');

  /// URL path used with `context.go(routerPath)`.
  final String routerPath;

  /// Named route used with `context.goNamed(routerName)`.
  final String routerName;

  const Routers(this.routerPath, this.routerName);
}
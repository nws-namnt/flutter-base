import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Google Sign-In button
//
// Uses FirebaseAuth.signInWithProvider (Firebase Auth web OAuth flow) instead
// of the google_sign_in_ios plugin. This bypasses GIDSignIn entirely, which
// avoids a native crash caused by google_sign_in_ios 5.9.0 not supporting
// UIScene lifecycle events (FlutterSceneDelegate).
// After sign-in succeeds, RouterNotifier picks up authStateChanges and
// GoRouter handles redirect — no manual navigation needed here.
// ---------------------------------------------------------------------------

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _loading = false;

  Future<void> _signIn() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider());
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Google sign-in failed')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _loading ? null : _signIn,
      child: _loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _GoogleLogo(),
                SizedBox(width: 12),
                Text('Continue with Google'),
              ],
            ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    // Uses the SocialIcons font bundled with firebase_ui_auth.
    // Codepoint 0xe000 = Google logo in that font.
    return const Text(
      '',
      style: TextStyle(
        fontFamily: 'SocialIcons',
        package: 'firebase_ui_auth',
        fontSize: 20,
        color: Color(0xFF4285F4),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

/// Max height of the collapsible header on auth screens.
const double kAuthHeaderMaxExtent = 200.0;

/// "──── or ────" row divider used between the email form and OAuth buttons.
class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

/// Shared collapsible header for all firebase_ui_auth screens.
/// Fades out as the user scrolls, exposing the form below.
Widget authHeaderBuilder(
  BuildContext context,
  BoxConstraints constraints,
  double shrinkOffset,
) {
  final opacity =
      (1.0 - shrinkOffset / constraints.maxHeight).clamp(0.0, 1.0);
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return Opacity(
    opacity: opacity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const FlutterLogo(size: 64, style: FlutterLogoStyle.markOnly),
        const SizedBox(height: 12),
        Text(
          'Flutter Base',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ),
  );
}

/// Applies auth-specific button and input overrides on top of the ambient theme.
///
/// Wrap any firebase_ui_auth screen with `Theme(data: authTheme(context), ...)`
/// to get taller, rounded buttons and filled, rounded text fields that match the
/// app's [ColorScheme] in both light and dark mode.
ThemeData authTheme(BuildContext context) {
  final base = Theme.of(context);
  final radius = BorderRadius.circular(12);
  const vPad = EdgeInsets.symmetric(vertical: 14);
  const minSize = Size.fromHeight(52);
  final shape = RoundedRectangleBorder(borderRadius: radius);

  return base.copyWith(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: vPad,
        minimumSize: minSize,
        shape: shape,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: vPad,
        minimumSize: minSize,
        shape: shape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: vPad,
        minimumSize: minSize,
        shape: shape,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: base.colorScheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: base.colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: base.colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: base.colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: base.colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: base.colorScheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}

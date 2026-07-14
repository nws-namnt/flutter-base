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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GoogleSignInWidget extends StatefulWidget {
  const GoogleSignInWidget({super.key});

  @override
  State<GoogleSignInWidget> createState() => _GoogleSignInWidgetState();
}

class _GoogleSignInWidgetState extends State<GoogleSignInWidget> {
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
          Text(
            '',
            style: TextStyle(
              fontFamily: 'SocialIcons',
              package: 'firebase_ui_auth',
              fontSize: 20,
              color: Color(0xFF4285F4),
            ),
          ),
          SizedBox(width: 12),
          Text('Continue with Google'),
        ],
      ),
    );
  }
}
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/pages/auth/auth_mixin.dart';

class ForgotPasswordPage extends StatelessWidget with AuthMixin {
  const ForgotPasswordPage({super.key, this.email});

  /// Pre-fills the email field when navigated from [LoginPage].
  final String? email;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: authTheme(context),
      child: ForgotPasswordScreen(
        email: email,
        headerBuilder: authHeaderBuilder,
        headerMaxExtent: AuthMixin.kAuthHeaderMaxExtent,
        subtitleBuilder: (context) => const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text("Enter your email and we'll send you a reset link."),
        ),
      ),
    );
  }
}

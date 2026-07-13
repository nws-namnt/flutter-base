import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/auth_header_builder.dart';

class ForgotPasswordPage extends StatelessWidget {
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
        headerMaxExtent: kAuthHeaderMaxExtent,
        subtitleBuilder: (context) => const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text("Enter your email and we'll send you a reset link."),
        ),
      ),
    );
  }
}

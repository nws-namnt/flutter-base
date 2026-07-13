import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/routers.dart';
import '../widgets/auth_header_builder.dart';

class EmailVerificationPage extends StatelessWidget {
  const EmailVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: authTheme(context),
      child: EmailVerificationScreen(
        headerBuilder: authHeaderBuilder,
        headerMaxExtent: kAuthHeaderMaxExtent,
        actions: [
          EmailVerifiedAction(() => context.go(Routers.home.routerPath)),
          AuthCancelledAction((context) {
            FirebaseUIAuth.signOut(context: context);
            context.go(Routers.login.routerPath);
          }),
        ],
      ),
    );
  }
}

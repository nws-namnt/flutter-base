import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/pages/auth/auth_mixin.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routers.dart';

class EmailVerificationPage extends StatelessWidget with AuthMixin {
  const EmailVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: authTheme(context),
      child: EmailVerificationScreen(
        headerBuilder: authHeaderBuilder,
        headerMaxExtent: AuthMixin.kAuthHeaderMaxExtent,
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

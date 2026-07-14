import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/pages/auth/auth_mixin.dart';
import 'package:go_router/go_router.dart';

import '../../routing/routers.dart';

class ProfilePage extends StatelessWidget with AuthMixin {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: authTheme(context),
      child: ProfileScreen(
        actions: [
          SignedOutAction((context) {
            context.go(Routers.home.routerPath);
          }),
        ],
      ),
    );
  }
}

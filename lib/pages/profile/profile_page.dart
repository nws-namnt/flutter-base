import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/routers.dart';
import '../widgets/auth_header_builder.dart';

class ProfilePage extends StatelessWidget {
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

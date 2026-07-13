import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/routers.dart';

class SmsCodePage extends StatelessWidget {
  const SmsCodePage({
    super.key,
    required this.flowKey,
    this.action,
  });

  final Object flowKey;
  final AuthAction? action;

  @override
  Widget build(BuildContext context) {
    return SMSCodeInputScreen(
      flowKey: flowKey,
      action: action,
      actions: [
        AuthStateChangeAction<SignedIn>((context, _) {
          context.go(Routers.home.routerPath);
        }),
      ],
    );
  }
}

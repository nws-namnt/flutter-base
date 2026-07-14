import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/pages/auth/items/google_sign_in_widget.dart';
import 'package:flutter_base/pages/auth/items/section_divider_widget.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routers.dart';
import '../auth_mixin.dart';

class RegisterPage extends StatelessWidget with AuthMixin {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final allProviders = FirebaseUIAuth.providersFor(FirebaseAuth.instance.app);
    final emailProvider =
        allProviders.whereType<EmailAuthProvider>().firstOrNull;

    return FirebaseUIActions(
      actions: [
        AuthStateChangeAction<UserCreated>((context, state) {
          final user = state.credential.user;
          if (user != null && !user.emailVerified) {
            context.push(Routers.emailVerification.routerPath);
          } else {
            context.go(Routers.home.routerPath);
          }
        }),
        AuthStateChangeAction<SignedIn>((context, _) {
          context.go(Routers.home.routerPath);
        }),
      ],
      child: Theme(
        data: authTheme(context),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _RegisterHeader(),
                  const SizedBox(height: 32),
                  if (emailProvider != null)
                    EmailForm(
                      action: AuthAction.signUp,
                      provider: emailProvider,
                      showPasswordVisibilityToggle: true,
                    ),
                  const SizedBox(height: 24),
                  const SectionDividerWidget(),
                  const SizedBox(height: 16),
                  const GoogleSignInWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        const FlutterLogo(size: 56, style: FlutterLogoStyle.markOnly),
        const SizedBox(height: 12),
        Text(
          'Create account',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Join Flutter Base to get started',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

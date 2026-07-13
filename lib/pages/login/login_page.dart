import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/routers.dart';
import '../widgets/auth_header_builder.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final allProviders = FirebaseUIAuth.providersFor(FirebaseAuth.instance.app);
    final emailProvider =
        allProviders.whereType<EmailAuthProvider>().firstOrNull;

    return FirebaseUIActions(
      actions: [
        AuthStateChangeAction<SignedIn>((context, _) {
          context.go(Routers.home.routerPath);
        }),
        AuthStateChangeAction<UserCreated>((context, state) {
          final user = state.credential.user;
          if (user != null && !user.emailVerified) {
            context.push(Routers.emailVerification.routerPath);
          } else {
            context.go(Routers.home.routerPath);
          }
        }),
        ForgotPasswordAction((context, email) {
          context.push(Routers.forgotPassword.routerPath, extra: email);
        }),
        SMSCodeRequestedAction((context, action, flowKey, phoneNumber) {
          context.push(
            Routers.smsCode.routerPath,
            extra: {'action': action, 'flowKey': flowKey},
          );
        }),
      ],
      child: Theme(
        data: authTheme(context),
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _AuthHeader(subtitle: 'Sign in to continue'),
                  const SizedBox(height: 32),
                  if (emailProvider != null)
                    EmailForm(
                      action: AuthAction.signIn,
                      provider: emailProvider,
                      showPasswordVisibilityToggle: true,
                    ),
                  const SizedBox(height: 24),
                  const AuthOrDivider(),
                  const SizedBox(height: 16),
                  const GoogleSignInButton(),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.push(Routers.register.routerPath),
                    child: const Text("Don't have an account? Sign up"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        const FlutterLogo(size: 72, style: FlutterLogoStyle.markOnly),
        const SizedBox(height: 16),
        Text(
          'Flutter Base',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/app_enums.dart';
import '../../utils/app_utils.dart';
import 'home_cubit.dart';
import 'home_state.dart';

/// The Home tab screen, hosted inside the navigation shell at [Routers.home].
///
/// Instantiates and owns its [HomeCubit]; the cubit is closed in [dispose].
class HomePage extends StatefulWidget {
  /// Creates a [HomePage].
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = HomeCubit();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Home')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: [
                  // Opens a URL in the platform default browser
                  _LaunchButton(
                    label: 'Open URL',
                    icon: Icons.language,
                    onTap: () => onLaunchExternalApp(
                      externalType: LaunchExternalType.webview,
                      data: 'https://flutter.dev',
                    ),
                  ),

                  // Opens the default email client with a pre-filled recipient
                  _LaunchButton(
                    label: 'Send Email',
                    icon: Icons.email_outlined,
                    onTap: () => onLaunchExternalApp(
                      externalType: LaunchExternalType.mail,
                      data: 'test@example.com',
                      mailSubject: 'Hello from Flutter Base',
                    ),
                  ),

                  // Dials a phone number
                  _LaunchButton(
                    label: 'Dial Phone',
                    icon: Icons.phone_outlined,
                    onTap: () => onLaunchExternalApp(
                      externalType: LaunchExternalType.tel,
                      data: '+84123456789',
                    ),
                  ),

                  // Opens the default SMS app with a pre-filled number
                  _LaunchButton(
                    label: 'Send SMS',
                    icon: Icons.sms_outlined,
                    onTap: () => onLaunchExternalApp(
                      externalType: LaunchExternalType.sms,
                      data: '+84123456789',
                    ),
                  ),

                  // Opens a URL inside an in-app web view
                  _LaunchButton(
                    label: 'In-App WebView',
                    icon: Icons.open_in_new,
                    onTap: () => onLaunchExternalApp(
                      externalType: LaunchExternalType.webview,
                      data: 'https://flutter.dev',
                      mode: LaunchMode.inAppWebView,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A reusable test button for [onLaunchExternalApp] scenarios.
class _LaunchButton extends StatelessWidget {
  const _LaunchButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

import 'main.dart' as runner;

/// Entry point for the **uat** flavor.
///
/// Delegates immediately to [runner.main], which detects the flavor at runtime
/// from the bundle ID suffix and loads the matching `.env.uat` and Firebase config.
Future<void> main() async {
  await runner.main();
}
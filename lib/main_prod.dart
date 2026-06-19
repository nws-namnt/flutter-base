import 'main.dart' as runner;

/// Entry point for the **prod** flavor.
///
/// Delegates immediately to [runner.main], which detects the flavor at runtime
/// from the bundle ID suffix (no suffix → prod) and loads `.env.prod` and the
/// production Firebase config.
Future<void> main() async {
  await runner.main();
}
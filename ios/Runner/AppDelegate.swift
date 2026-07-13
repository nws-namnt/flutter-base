import Flutter
import GoogleSignIn
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]?
    ) -> Bool {
        // Configure GIDSignIn with CLIENT_ID from GoogleService-Info.plist.
        // Required because google_sign_in plugin does not set this automatically
        // when GIDSignIn.configuration is nil at sign-in time.
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let clientId = plist["CLIENT_ID"] as? String {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
        }
        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }

    // Required for Google Sign-In redirect after authentication.
    // Handles the OAuth callback URL for non-scene app lifecycle (iOS < 13 fallback).
    // Scene-based apps (iOS 13+) receive callbacks in SceneDelegate.scene(_:openURLContexts:).
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        return super.application(app, open: url, options: options)
    }

    func didInitializeImplicitFlutterEngine(
        _ engineBridge: FlutterImplicitEngineBridge
    ) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

        let messenger = engineBridge.applicationRegistrar.messenger()
        BatteryApiSetup.setUp(binaryMessenger: messenger, api: BatteryApiBridge())
        DeviceApiSetup.setUp(binaryMessenger: messenger, api: DeviceApiBridge())
    }
}

import Flutter
import GoogleSignIn
import UIKit

class SceneDelegate: FlutterSceneDelegate {
    // Required for Google Sign-In OAuth redirect on iOS 13+ scene-based apps.
    // GIDSignIn 8.0 uses ASWebAuthenticationSession; the callback URL is
    // delivered here (not in AppDelegate.application(_:open:options:)) when
    // the app has an active UIWindowScene.
    override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            GIDSignIn.sharedInstance.handle(context.url)
        }
        super.scene(scene, openURLContexts: URLContexts)
    }
}

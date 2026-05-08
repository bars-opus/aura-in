import Flutter
import UIKit
import GoogleSignIn

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "com.barsOpus.florence/google_sign_in",
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "signInWithNonce" else {
        result(FlutterMethodNotImplemented)
        return
      }

      guard
        let args = call.arguments as? [String: String],
        let hashedNonce = args["hashedNonce"],
        let iosClientId = args["iosClientId"],
        let webClientId = args["webClientId"]
      else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing hashedNonce, iosClientId, or webClientId", details: nil))
        return
      }

      // serverClientID makes GIDSignIn set `aud` = webClientId in the ID token,
      // which is what Supabase expects when verifying the token.
      let config = GIDConfiguration(clientID: iosClientId, serverClientID: webClientId)
      GIDSignIn.sharedInstance.configuration = config

      // Sign out first so the account picker always appears.
      GIDSignIn.sharedInstance.signOut()

      guard let presentingVC = self?.window?.rootViewController else {
        result(FlutterError(code: "NO_VC", message: "No root view controller", details: nil))
        return
      }

      GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC, hint: nil, additionalScopes: ["email", "profile"], nonce: hashedNonce) { signInResult, error in
        if let error = error {
          let nsError = error as NSError
          // kGIDSignInErrorCodeCanceled == -5
          if nsError.code == -5 {
            result(nil) // user cancelled — return null to Flutter
          } else {
            result(FlutterError(code: "SIGN_IN_FAILED", message: error.localizedDescription, details: nil))
          }
          return
        }

        guard let user = signInResult?.user,
              let idToken = user.idToken?.tokenString else {
          result(FlutterError(code: "NO_TOKEN", message: "Google sign-in returned no ID token", details: nil))
          return
        }

        let accessToken = user.accessToken.tokenString
        result(["idToken": idToken, "accessToken": accessToken])
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

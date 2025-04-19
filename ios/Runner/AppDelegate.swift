import Flutter
import UIKit
import GoogleMaps

GMSServices.provideAPIKey("AIzaSyBhtsmBxXi6PNzVu9iAGN-F6HtDieUy8-I")

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

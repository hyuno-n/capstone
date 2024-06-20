import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
<<<<<<< HEAD
=======
    if #available(iOS 10.0, *) { 
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
>>>>>>> 42dba9f955c1c7b11776da37cd326a33e97f40ba
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

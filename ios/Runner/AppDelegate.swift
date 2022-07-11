import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    UIApplication.shared.registerForRemoteNotifications()

        if #available(iOS 10.0, *) {
            if UNUserNotificationCenter.self != nil {
                // iOS 10 or later
                // For iOS 10 display notification (sent via APNS)
                UNUserNotificationCenter.current().delegate = self
                let authOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
                UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { granted, error in
                    // ...
                })
            } else {
                // iOS 10 notifications aren't available; fall back to iOS 8-9 notifications.
                let allNotificationTypes: UIUserNotificationType = [.sound, .alert, .badge]
                let settings = UIUserNotificationSettings(types: allNotificationTypes, categories: nil)
                application.registerUserNotificationSettings(settings)
            }
        } else {
            // Fallback on earlier versions
        }

        application.registerForRemoteNotifications()
    

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

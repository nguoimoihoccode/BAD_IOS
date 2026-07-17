import UIKit
import SwiftUI
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // 1. Setup User Notification Center Delegate
        UNUserNotificationCenter.current().delegate = self
        
        // 2. Request Notification Authorization
        requestNotificationPermission()
        
        // 3. Boot SwiftUI App Interface
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainView = MainNavigation()
        let hostingController = UIHostingController(rootView: mainView)
        window?.rootViewController = hostingController
        window?.makeKeyAndVisible()
        return true
    }
    
    // Request permission from the user for Alerts, Badges, and Sounds
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
                // Register for remote notifications on the main thread
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - APNs Device Token Registration Callbacks
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device APNs Token initialized successfully: \(token)")
        
        // Stored locally for now. TODO: register this token with the backend when the push registration endpoint exists.
        UserDefaults.standard.set(token, forKey: "apns_device_token")
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
        // Fallback or debug mode token
        UserDefaults.standard.set("mock-apns-token-123456", forKey: "apns_device_token")
    }
    
    // MARK: - UNUserNotificationCenterDelegate (Foreground Presentation)
    
    // Display banner while app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner and play sound even if the app is active
        completionHandler([.banner, .list, .sound])
    }
    
    // Handle tap on notifications
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("User tapped notification with info: \(userInfo)")
        completionHandler()
    }
}

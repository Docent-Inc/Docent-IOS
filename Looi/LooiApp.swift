//
//  LooiApp.swift
//

import SwiftUI
import WebKit
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      
    // 알림 센터에 앱 등록
    UNUserNotificationCenter.current().delegate = self

    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
    )

    application.registerForRemoteNotifications()

    return true
  }
}

@main
struct LooiApp: App {
    @State private var isLoading = true
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                WebView {
                    self.isLoading = false
                }
                
                if isLoading {
                    SplashView()
                }
            }
       }
    }
}

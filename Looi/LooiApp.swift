//
//  LooiApp.swift
//

import SwiftUI
import WebKit
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

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

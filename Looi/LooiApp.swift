//
//  LooiApp.swift
//

import SwiftUI
import WebKit
import Firebase
import UserNotifications
import FirebaseMessaging

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


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool{
   
    // 1. Firebase 등록
    FirebaseApp.configure()
      
    // 2. 알림 센터에 앱 등록 및 권한 요청
    UNUserNotificationCenter.current().delegate = self
      
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
    )

    application.registerForRemoteNotifications()
      
    // 3. 파이어베이스 Meesaging 설정
    Messaging.messaging().delegate = self

    return true
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // 백그라운드에서 푸시 알림을 탭했을 때 실행
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("✅APNS token: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("✅22APNS token: \(deviceToken)")
      Messaging.messaging().apnsToken = deviceToken
    }
    
    // Foreground(앱 켜진 상태)에서도 알림 오는 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
    }
}

extension AppDelegate: MessagingDelegate {
    // 토큰 업데이트 시마다 호출
    // ex. 새 기기에서 앱 복원, 사용자가 앱 제거/재설치, 사용자가 앱 데이터 삭제
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("✅Firebase registration token: \(String(describing: fcmToken))")

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
        
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}


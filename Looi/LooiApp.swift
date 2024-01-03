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
      
    // 2. 파이어베이스 Meesaging 설정
    Messaging.messaging().delegate = self
      
    // 3. 알림 센터에 앱 등록 및 권한 요청
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

extension AppDelegate: UNUserNotificationCenterDelegate {
    // APNs Token 저장
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS token: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // Foreground에서도 푸시 오는 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("🔔userInfo", userInfo);
            
        completionHandler([.list, .banner])
    }
    
    // 푸시 메시지 클릭 시,
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        let landingUrl = userInfo["landing_url"] as? String ?? ""
        let application = UIApplication.shared
        
        print(">> url!", landingUrl)
        print(">> state!", application.applicationState)
        
        switch application.applicationState {
            case .active:
                print(">> state! active")
            case .inactive:
                print(">> state! inactive")
            case .background:
                print(">> state! background")

                let userDefault = UserDefaults.standard
                userDefault.set(landingUrl, forKey: "LANDING_URL")
                userDefault.synchronize()
            default:
                print(">> state!")
        }
        
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    
    // 토큰 업데이트 시마다 호출
    // ex. 새 기기에서 앱 복원, 사용자가 앱 제거/재설치, 사용자가 앱 데이터 삭제
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
}


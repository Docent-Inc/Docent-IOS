//
//  NotificationServiceExtension - NotificationService.swift
//  푸시 수신 시 처리 로직
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        let userInfo = request.content.userInfo
        print("[🔔NotificationService] userInfo", userInfo);
        
        if let bestAttemptContent = bestAttemptContent {
            
            // 1) 이미지가 있는 경우,
            if let image = (userInfo["fcm_options"] as? [String: Any])?["image"] as? String {
                print("[🔔NotificationService] image", image)
                
                do {
                    try saveFile(id: "looi-image.png", imageURLString: image) { fileURL in
                        do {
                            print(fileURL.absoluteURL)
                            let attachment = try UNNotificationAttachment(identifier: "", url: fileURL, options: nil)
                            bestAttemptContent.attachments = [attachment]
                        } catch {
                            print(error)
                        }
                    }
                } catch {
                    print(error)
                }
            }

            // 2. 랜딩 url이 있는 경우,
            print("[🔔NotificationService] landing_url", userInfo["landing_url"] as? String ?? "" );
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // (일정 시간 동안 푸시가 가지 않으면, original push 전송)
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    /**
     * saveFile - 이미지 저장
     * (일반적으로는 일정 시간이 지난 후에 자동으로 삭제됨)
     */
    private func saveFile(id: String, imageURLString: String, completion: @escaping (URL) throws -> Void) throws {
        let fileManager = FileManager.default
        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL = documentDirectory.appendingPathComponent(id)

        guard
            let imageURL = URL(string: imageURLString),
            let data = try? Data(contentsOf: imageURL)
        else { throw URLError(.cannotDecodeContentData) }

        try data.write(to: fileURL)
        try completion(fileURL)
    }

}

//
//  TokenMannager.swift
//  Looi
//
//  Created by 안재현 on 2/7/24.
//

import Foundation



//토큰 중앙 관리자입니다.
class TokenManager {
    static let shared = TokenManager()
    private init() {} // 외부에서 인스턴스 생성을 방지합니다.

    var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "access_token")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "access_token")
            UserDefaults.standard.synchronize() // iOS 12 이하를 대상으로 할 경우에는 호출할 수 있으나, 현대적인 iOS 버전에서는 필요 없습니다.
        }
    }
}

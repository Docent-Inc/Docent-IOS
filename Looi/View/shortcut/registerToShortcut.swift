//
//  registerToShortcut.swift
//  Looi
//
//  Created by 안재현 on 2/6/24.
//

import AppIntents

@available(iOS 17, *)
struct AppShortcuts: AppShortcutsProvider {
    
    //단축어 앱에 등록
    static var appShortcuts: [AppShortcut] {
        print("단축어 앱에 등록")
        
        AppShortcut(

            intent: MyFirstAppIntent(),
                    phrases: [
                        "Looi, \(.applicationName)",
                        "Looi, \(.applicationName)",
                    ],
                    shortTitle : "Looi", // 여기에 짧은 제목 추가
                    systemImageName: "waveform.path.ecg" // 여기에 시스템 이미지 이름 추가
                    )
    }
}

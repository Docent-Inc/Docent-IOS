//
//  shortcut.swift
//  shortcut
//
//  Created by 조태완 on 2/8/24.
//

import AppIntents

struct shortcut: AppIntent {
    static var title: LocalizedStringResource = "shortcut"
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

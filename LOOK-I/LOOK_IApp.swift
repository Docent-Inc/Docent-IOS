//
//  LOOK_IApp.swift
//

import SwiftUI
import WebKit

@main
struct LOOK_IApp: App {
    @State private var isLoading = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                WebView{
                    self.isLoading = false
                }
                
                if isLoading {
                    SplashView()
                }
            }
       }
    }
}

//
//  LooiApp.swift
//

import SwiftUI
import WebKit

@main
struct LooiApp: App {
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

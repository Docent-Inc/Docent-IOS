//
//  SplashView.swift
//
import SwiftUI

struct SplashView: View {
    var body: some View {
        Image("Splash")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
    }
}

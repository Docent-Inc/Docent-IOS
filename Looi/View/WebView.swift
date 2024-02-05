//
//  WebView.swift
//
import SwiftUI
import WebKit

struct WebView: UIViewControllerRepresentable {
    // 외부에서 레이아웃 업데이트를 제어하기 위한 Binding 변수
    @Binding var updateLayout: Bool
    var didFinishLoading: (() -> Void)?

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = ViewController()
        viewController.didFinishLoading = didFinishLoading
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // updateLayout 값이 변경될 때마다 ViewController의 adjustWebViewFrame 메서드를 호출하여 레이아웃을 업데이트합니다. 테스트용
        if let viewController = uiViewController as? ViewController {
            viewController.adjustWebViewFrame(shouldAdjustSafeArea: updateLayout)
        }
    }
}

//
//  WebView.swift
//
import SwiftUI
import WebKit

struct WebView: UIViewControllerRepresentable {
    // 외부에서 레이아웃 업데이트를 제어하기 위한 Binding 변수
    var didFinishLoading: (() -> Void)?

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = ViewController()
        viewController.didFinishLoading = didFinishLoading
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

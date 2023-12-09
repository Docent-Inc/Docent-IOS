//
//  WebView.swift
//
import SwiftUI
import WebKit

struct WebView: UIViewControllerRepresentable {
    var didFinishLoading: (() -> Void)?

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = ViewController()
        viewController.didFinishLoading = didFinishLoading
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
}

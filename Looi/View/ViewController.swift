//
//  ViewController.swift
//
import SwiftUI
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var didFinishLoading: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webViewInit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)

           guard Reachability.networkConnected() else {
               let alert = UIAlertController(title: "NetworkError", message: "네트워크가 연결되어있지 않습니다.", preferredStyle: .alert)
               let okAction = UIAlertAction(title: "종료", style: .default) { (action) in
                   exit(0)
               }
               alert.addAction(okAction)
               self.present(alert, animated: true, completion: nil)
               return
           }
           
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
    
    func webViewInit() {
        webViewSetting()
        
        // 쿠키, 세션, 로컬 스토리지, 캐시 등 데이터를 관리하는 객체 - 캐시 제거
        WKWebsiteDataStore.default().removeData(ofTypes:
        [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache],
        modifiedSince: Date(timeIntervalSince1970: 0)) { }
        
        // 스와이프를 통해 뒤로가기 활성화
        webView.allowsBackForwardNavigationGestures = true
        webView.isInspectable = true
        
        if let url = URL(string: "http://localhost:3000/") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func webViewSetting() {
        webView = WKWebView(frame: self.view.bounds)
        webView.navigationDelegate = self
        self.view.addSubview(webView)
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.didFinishLoading?()
   }
}

/**
 * WKUIDelegate
 */
extension ViewController: WKUIDelegate{
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            completionHandler()
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .default) { (action) in
            completionHandler(false)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            if let text = alert.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}

/**
 * Message Handler - 웹뷰와 통신
 */
extension ViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if(message.name == "locationSearch"){
            
//            let data:[String:String] = message.body as! Dictionary
            //location Event
            //data["action"] = searchLocation
            
        }
    }
}

//
//  ViewController.swift
//
import SwiftUI
import WebKit
import FirebaseMessaging

class ViewController: UIViewController, WKNavigationDelegate {
    let BASE_URL: String =  Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String ?? ""
    
    var webView: WKWebView!
    var didFinishLoading: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setObserver()
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
    
    func setObserver() {
        // Foreground 푸시를 통해 수신한 landing_url이 있는 경우,
        NotificationCenter.default.addObserver(forName: Notification.Name("loadNewUrl"), object: nil, queue: nil) { notification in
                guard let userInfo = notification.userInfo,
                      let landingUrl = userInfo["landing_url"]! as? String else { return }
                   
                if let url = URL(string: self.BASE_URL + landingUrl) {
                    self.webView.load(URLRequest(url: url))
                }
        }
    }
    
    func webViewInit() {
        let contentController = WKUserContentController()
        let configuration = WKWebViewConfiguration()
       
        // Bridge 함수 등록
        contentController.add(self, name: "reqFCMToken")
        configuration.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        // IOS App 구분을 위한 User-agent 설정
        let userAgent = webView.value(forKey: "userAgent")
        webView.customUserAgent = userAgent as! String + " looi-ios"
         
        self.view.addSubview(webView)
        
        // 쿠키, 세션, 로컬 스토리지, 캐시 등 데이터를 관리하는 객체 - 캐시 제거
        WKWebsiteDataStore.default().removeData(ofTypes:
        [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache],
        modifiedSince: Date(timeIntervalSince1970: 0)) { }
        
        // 스와이프를 통해 뒤로가기 활성화 - 비활성화
        // webView.allowsBackForwardNavigationGestures = true
        
        // TODO: 배포 시 주석 처리 - safari 개발자모드 디버깅 활성화
        webView.isInspectable = true
        
        // Background 푸시를 통해 수신한 landing_url이 있는 경우,
        let userDefault = UserDefaults.standard
        if let landingUrl:String = userDefault.string(forKey: "LANDING_URL") {
            if let url = URL(string: BASE_URL + landingUrl) {
                webView.load(URLRequest(url: url))
            }
            
            userDefault.removeObject(forKey: "LANDING_URL")
            userDefault.synchronize()
            
            return;
        }
        
        if let url = URL(string: BASE_URL) {
            webView.load(URLRequest(url: url))
        }
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
    /**
     * userContentController - 웹뷰로부터 수신한 브릿지 함수 (hybrid.js)
     */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("✈️Message received from Webview >>>", message.name, message.body);
        
        if(message.name == "reqFCMToken"){
//            let data:[String:String] = message.body as! Dictionary
            //location Event
            //data["action"] = searchLocation
            
            // 웹뷰 로드 후, FCM 토큰 등록
            Messaging.messaging().token { token, error in
              if let error = error {
                print("👀Error fetching FCM registration token: \(error)")
              } else if let token = token {
                print("👀FCM registration token: \(token)")
                self.callJavaScriptFunction(function: "resFCMToken", params: [token]);
              }
            }
        }
    }
    
    /**
     * callJavaScriptFunction - 웹뷰의 함수 실행 (functions.js)
     */
    func callJavaScriptFunction(function: String, params: [Any]) {
           var script = "\(function)("
           for (index, param) in params.enumerated() {
               if index > 0 {
                   script += ", "
               }
               if let stringParam = param as? String {
                   script += "'\(stringParam)'"
               } else {
                   script += "\(param)"
               }
           }
           script += ");"

            print("✈️Call Webview Function >>> ", script);
            webView.evaluateJavaScript(script) { (_, error) in
                if let error = error {
                    print(">>>>> error \(error)")
                } else {
                    print(">>>>> success")
                }
            }
       }
}


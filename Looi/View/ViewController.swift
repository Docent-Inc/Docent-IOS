//
//  ViewController.swift
//
import SwiftUI
import WebKit
import FirebaseMessaging
import SafariServices

class ViewController: UIViewController, WKNavigationDelegate {
    let BASE_URL: String =  Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String ?? ""
    
    var webView: WKWebView!
    var shouldAdjustSafeArea = false
    var initialBounds: CGRect = .zero
    var didFinishLoading: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialBounds = view.bounds
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
    }
    
    func openSFSafariViewController(url: String) {
            guard let url = URL(string: url) else { return }
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
        }
    
    func adjustWebViewFrame(shouldAdjustSafeArea: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                    if shouldAdjustSafeArea {
                        self.webView.frame = self.view.safeAreaLayoutGuide.layoutFrame
                    } else {
                        self.webView.frame = self.initialBounds

                    }
                    self.webView.layoutIfNeeded()
                }) { _ in
                }
            }
    }

    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
        contentController.add(self, name: "removeCache")
        contentController.add(self, name: "adjustSafeArea")
        contentController.add(self, name: "openKakaoLink")
        contentController.add(self, name: "openLink")
        
        configuration.userContentController = contentController
        
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.frame = initialBounds
        webView.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(webView)
        
        // IOS App 구분을 위한 User-agent 설정
        let userAgent = webView.value(forKey: "userAgent")
        webView.customUserAgent = userAgent as! String + " looi-ios"
        
        
        // 쿠키, 세션, 로컬 스토리지, 캐시 등 데이터를 관리하는 객체 - 캐시 제거 - 비활성화
        // WKWebsiteDataStore.default().removeData(ofTypes:
        // [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache],
        // modifiedSince: Date(timeIntervalSince1970: 0)) { }
        
        // 스와이프를 통해 뒤로가기 활성화 - 비활성화
        webView.allowsBackForwardNavigationGestures = true
        
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
        
        // [TODO] 사용 예시
        getAccessToken { accessToken in
            if let accessToken = accessToken {
                print("Access Token이 있습니다. >>> \(accessToken)")
            } else {
                print("Access Token이 없습니다.")
            }
        }
    }
    
    
    // 쿠키에서 액세스 토큰 가져오기
    func getAccessToken(completion: @escaping (String?) -> Void) {
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        cookieStore.getAllCookies { cookies in
            var accessToken: String?

            if let accessTokenCookie = cookies.first(where: { $0.name == "access_token" }) {
                print("[SAVE] cookie name: \(accessTokenCookie.name), cookie value: \(accessTokenCookie.value)")

                UserDefaults.standard.set(accessTokenCookie.value, forKey: "access_token")
                UserDefaults.standard.synchronize()

                accessToken = accessTokenCookie.value
                completion(accessToken)
                return
            }

            // 쿠키에는 없는데 UserDefault에 있는 경우, 초기화
            if UserDefaults.standard.object(forKey: "access_token") != nil {
                print("[REMOVE] access_token not found in cookies. Removing from UserDefaults.")
                UserDefaults.standard.removeObject(forKey: "access_token")
                UserDefaults.standard.synchronize()
            }

            completion(nil)
        }
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
            // 웹뷰 로드 후, FCM 토큰 등록
            Messaging.messaging().token { token, error in
                if let error = error {
                    print("👀Error fetching FCM registration token: \(error)")
                } else if let token = token {
                    print("👀FCM registration token: \(token)")
                    self.callJavaScriptFunction(function: "resFCMToken", params: [token]);
                }
            }
        } else if (message.name == "removeCache") {
            // 쿠키, 세션, 로컬 스토리지, 캐시 등 데이터를 관리하는 객체 - 웹뷰 캐시 제거
            WKWebsiteDataStore.default().removeData(ofTypes:
                                                        [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache],
                                                    modifiedSince: Date(timeIntervalSince1970: 0)) {
                print("삭제완료")
            }
        }
        else if message.name == "adjustSafeArea", let messageBody = message.body as? Bool {
            if (messageBody == true){
                adjustWebViewFrame(shouldAdjustSafeArea: true)
            }
            else{
                adjustWebViewFrame(shouldAdjustSafeArea: false)
            }
        }
        else if message.name == "openLink", let messageBody = message.body as? String
        {
            openSFSafariViewController(url: messageBody)
        }
        else if message.name == "openKakaoLink", let messageBody = message.body as? String
        {
            let url = URL(string: messageBody)!
            webView.load(URLRequest(url: url))
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


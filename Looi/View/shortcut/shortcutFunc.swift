//
//  shortcutFunc.swift
//  Looi
//
//  Created by 안재현 on 2/6/24.
//

import AppIntents
import Foundation

print("qwer")

struct CustomResult {
    var token: String
    var text: String
}



@available(iOS 16, *) // - 16 이상부터만 쓸 수 있다



struct MyFirstAppIntent: AppIntent {
    //url을 가져오거나 빈 문자열을 가져오거나
    let BASE_URL: String =  Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String ?? ""
    static var title: LocalizedStringResource = "Receive Text Input"
    // 단축어 실행 시 見える字
    @Parameter(title: "루이: 작성헤 주세요💙")
    // 入力をもらう변수
    var inputText: String

    
    
//     비동기적 데이터 처리 함수, 실행 함수 - AppIntent protocol에 들어가는 함수이기도함.!!⭐️⭐️⭐️
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        //TokenManager class에서 토늨을 가져옴.
        let token : String = TokenManager.shared.accessToken ?? ""

        processInputText(inputText,withToken: token)

        //return 값 처리 해야함 ☑️ -> 메모리 버그? -> 2.6일 해결
        return .result(dialog: "일기가 생성되면 알려드릴게요💙 \"\(inputText)\"")
    }
    
    
    
    // 토큰과 입력받은 텍스트를 받아 서버로 처리하는 함수
    private func processInputText(_ text: String, withToken token: String?) {
        guard let token = token, let url = URL(string: BASE_URL + "/api/chat") else { return }

        // JSON 본문을 생성합니다. 여기서 "type"은 예시로 0을 넣었습니다. -> 5번
        let body: [String: Any] = ["type": 5, "content": text]
        let bodyData = try? JSONSerialization.data(withJSONObject: body, options: [])

        // URLRequest를 설정합니다.
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        
        print("/n" + token)

        // URLSession을 사용하여 네트워크 요청을 시작합니다.
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // 오류가 발생했습니다. 여기서 오류를 처리합니다.
                print("Error: \(error)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // 성공적으로 데이터를 전송했습니다. 여기서 필요한 후속 처리를 수행합니다.
                print("Data successfully sent to the server.")
            } else {
                // 서버에서 예상치 못한 응답을 받았습니다. 여기서 응답을 처리합니다.
                print("Unexpected response from the server.")
            }
        }
        task.resume()
    }
    
    
}

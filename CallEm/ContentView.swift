import SwiftUI
import TwilioVoice
import SocketIO
import KeychainAccess

struct CallerIdResponse: Codable {
    let phoneNumber: String?
    let error: String?
    let statusCode: Int?
    
    enum CodingKeys: String, CodingKey {
        case phoneNumber = "phone_number"
        case error = "error"
        case statusCode = "status_code"
    }
}


class CallManager: NSObject, ObservableObject, CallDelegate, URLSessionDelegate {
    @Published var callStatus: String = "Ready to make a call"
    private var call: Call?
    @Published var callerId: String = ""
    private var accessToken: String?
    private let tokenManager = TokenManager()
    private var webSocketTask: URLSessionWebSocketTask?
    
    
    override init() {
        super.init()
        fetchAndSetToken()
    }
    
    private func fetchAndSetToken(completion: (() -> Void)? = nil) {
        tokenManager.getValidToken { [weak self] token in
            DispatchQueue.main.async {
                self?.accessToken = token
                completion?()
            }
        }
    }
    
    public func verify(phoneNumber: String, completion: @escaping (String?) -> Void) {
        guard var urlComponents = URLComponents(string: "http://localhost:4000/verify") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "phoneNumber", value: phoneNumber),
            URLQueryItem(name: "friendlyName", value: "test")
        ]
        
        guard let url = urlComponents.url else {
            print("Invalid URL with query parameters")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error during request: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response or status code")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response string: \(responseString)")
                completion(responseString) // Pass the string to the completion handler
            } else {
                print("Failed to decode data as string")
                completion(nil)
            }
        }
        task.resume()
    }
    
    public func getCallerId(outgoingCallerSid: String, completion: @escaping (CallerIdResponse?) -> Void){
        guard var urlComponents = URLComponents(string: "http://localhost:4000/getCallerId") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "outgoingCallerSid", value: outgoingCallerSid),
        ]
        
        guard let url = urlComponents.url else {
            print("Invalid URL with query parameters")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error during request: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(CallerIdResponse.self, from: data)
                DispatchQueue.main.async {
                    if let statusCode = decodedResponse.statusCode, statusCode == 404 {
                        print("404")
                        self.callerId = "Unknown"
                    } else {
                        print("Got phoneNumber")
                        self.callerId = decodedResponse.phoneNumber ?? "Unknown"
                    }
                }
                completion(decodedResponse)
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    func makeCall() {
        
        guard let accessToken = accessToken, tokenManager.isTokenValid(token: accessToken) else {
            print("Access token either not set or invalid, fetching token...")
            fetchAndSetToken {
                self.makeCall()
            }
            return
        }
        
        let params: [String: String] = ["twilio": "+13656560656", "rogers": "+18887643771", "z": "+14169091808", "me": "+14163008698"]
        
        let connectOptions = ConnectOptions(accessToken: accessToken) { builder in
            builder.params = ["from": self.callerId, "to": params["rogers"] ?? ""]
        }
        
        call = TwilioVoiceSDK.connect(options:connectOptions, delegate: self)
    }
    
    func endCall() {
        call?.disconnect()
    }
    
    func sendDigit(digit: String) -> Void {
        call?.sendDigits(digit)
    }
    
    func callDidConnect(call: Call) {
        DispatchQueue.main.async {
            self.callStatus = "Call connected"
        }
    }
    
    func callDidDisconnect(call: Call, error: Error?) {
        DispatchQueue.main.async {
            self.callStatus = "Call disconnected"
        }
    }
    
    func callDidFailToConnect(call: Call, error: Error) {
        DispatchQueue.main.async {
            self.callStatus = "Failed to connect call: \(error.localizedDescription)"
        }
    }
}

// A completion of this view will send a websocket message and update outgoingCallerId in keychain
struct VerifyNumber: View {
    @State private var phoneNumber: String = ""
    @State private var verificationCode: String = ""
    let callManager: CallManager
    
    
    var body: some View{
        VStack{
            VStack(spacing: 20) {
                TextField("Enter phone number", text: $phoneNumber)
                    .font(.title)
                    .padding()
                    .keyboardType(.phonePad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                
                if verificationCode.count != 0 {
                    Text(verificationCode).padding()
                } else {
                    Button(action: {
                        callManager.verify(phoneNumber: phoneNumber){ res in
                            verificationCode = res!
                        }
                    }) {
                        Text("Submit")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
    }
}

struct ContentView: View {
    @ObservedObject private var callManager = CallManager()
    @ObservedObject private var socket = Socket()
    
    init() {
        if socket.getOutgoingCallerSid() == nil {
            socket.connect()
        }
        else {
            socket.connect()
            fetchCallerId()
        }
        
        if callManager.callerId == "Unknown" {
            print("Unknown, now connecting socket")
            socket.connect()
            socket.deleteOutgoingCallerSid()
        }
    }
    
    var body: some View {
        VStack {
            if socket.getOutgoingCallerSid() == nil || callManager.callerId == "Unknown" {
                VerifyNumber(callManager: callManager)
            } else {
                if callManager.callerId.isEmpty {
                    Text("Caller ID Empty...")
                        .onAppear {
                            fetchCallerId()
                        }
                } else {
                    Text("Caller ID: \(callManager.callerId)")
                }
                
                Text(callManager.callStatus)
                    .padding()
                
                HStack{
                    Button("Make Call") {
                        callManager.makeCall()
                    }.padding()
                    
                    Button("End Call") {
                        callManager.endCall()
                    }.padding()
                }
                
                HStack{
                    DialButton(number: "1", manager: callManager)
                    DialButton(number: "2", manager: callManager)
                    DialButton(number: "3", manager: callManager)
                }
                HStack{
                    DialButton(number: "4", manager: callManager)
                    DialButton(number: "5", manager: callManager)
                    DialButton(number: "6", manager: callManager)
                }
                HStack{
                    DialButton(number: "7", manager: callManager)
                    DialButton(number: "8", manager: callManager)
                    DialButton(number: "9", manager: callManager)
                }
                HStack{
                    DialButton(number: "*", manager: callManager)
                    DialButton(number: "0", manager: callManager)
                    DialButton(number: "#", manager: callManager)
                }
            }
        }
        .onChange(of: socket.outgoingCallerSid) { oldValue, newValue in
            fetchCallerId()
        }
    }
    
    private func fetchCallerId() {
        guard let sid = socket.getOutgoingCallerSid() else {
            return
        }
        
        callManager.getCallerId(outgoingCallerSid: sid){ res in
//            print(res!)
        }
    }
    
}


struct DialButton: View {
    let number: String
    let manager: CallManager
    var body: some View {
        Button(number) {
            manager.sendDigit(digit: number)
        }
        .frame(width:40, height: 40)
        .background(Color.blue)
        .foregroundColor(Color.white)
    }
}

#Preview {
    ContentView()
}

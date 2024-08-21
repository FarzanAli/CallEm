import SwiftUI
import TwilioVoice

class CallManager: NSObject, ObservableObject, CallDelegate {
    @Published var callStatus: String = "Ready to make a call"
    private var call: Call?
    private var accessToken: String?
    private let tokenManager = TokenManager()
    
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
    
    func makeCall() {
        
        guard let accessToken = accessToken, tokenManager.isTokenValid(token: accessToken) else {
            print("Access token either not set or invalid, fetching token...")
            fetchAndSetToken {
                self.makeCall()
            }
            return
        }
        
        let params: [String: String] = ["twilio": "+13656560656", "rogers": "+18887643771"]
        
        let connectOptions = ConnectOptions(accessToken: accessToken) { builder in
            builder.params = ["to": params["rogers"] ?? ""]
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

struct ContentView: View {
    @StateObject private var callManager = CallManager()
    
    var body: some View {
        VStack {
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

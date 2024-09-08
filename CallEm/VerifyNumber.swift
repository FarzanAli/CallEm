//
//  VerifyNumber.swift
//  CallEm
//
//  Created by Farzan Ali Faisal on 2024-08-28.
//

import Foundation
import SwiftUI

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

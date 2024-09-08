//
//  KeyPad.swift
//  CallEm
//
//  Created by Farzan Ali Faisal on 2024-08-28.
//

import Foundation
import SwiftUI

struct KeyPad: View {
    let callManager: CallManager
    
    var body: some View {
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

//
//  TokenManager.swift
//  CallEm
//
//  Created by Farzan Ali Faisal on 2024-08-20.
//

import Foundation
import SwiftJWT
import KeychainAccess

struct MyClaims: Claims {
    var exp: Date
}

struct TokenManager {
    private let keychain = Keychain(service: "com.CallEm")
    
    func getAccessToken() -> String? {
        return keychain["accessToken"]
    }
    
    func storeAccessToken(token: String) {
        keychain["accessToken"] = token
    }
    
    func isTokenValid(token: String) -> Bool {
        do {
            let jwt = try JWT<MyClaims>(jwtString: token)
            let expirationDate = jwt.claims.exp
            return Date() < expirationDate
        } catch {
            print("Invalid token")
            return false
        }
    }
    
    func getValidToken(completion: @escaping (String?) -> Void) {
        if let token = getAccessToken(), isTokenValid(token: token) {
            completion(token)
        } else {
            // Fetch a new token and handle it asynchronously
            fetchNewToken { newToken in
                if let newToken = newToken {
                    self.storeAccessToken(token: newToken)
                }
                completion(newToken)
            }
        }
    }
    
    func fetchNewToken(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "http://localhost:4000/accessToken") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching access token: \(error.localizedDescription)")
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
            
            if let token = String(data: data, encoding: .utf8) {
                completion(token)
            } else {
                print("Failed to decode token")
                completion(nil)
            }
        }
        
        task.resume()
    }
}

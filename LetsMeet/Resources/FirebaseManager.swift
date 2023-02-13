//
//  FirebaseManager.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 09.02.2023.
//

import Foundation
import FirebaseAuth

class FirebaseManager {
    static let shared = FirebaseManager()
}

extension FirebaseManager {
    func createNewUser(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let authResult else {
                print(error ?? "")
                completion(nil, error)
                return
            }
            completion(authResult, nil)
        }
    }
    
    func reloadPassword(for email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    func login(withEmail email: String, password: String, completion: @escaping (AuthDataResult?, Error?, Bool) ->  Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            guard let authResult else {
                print(error!)
                completion(nil, error, false)
                return
            }
            if authResult.user.isEmailVerified {
                completion(authResult, nil, true)
            } else {
                completion(authResult, nil, false)
            }
            
        }
    }
}

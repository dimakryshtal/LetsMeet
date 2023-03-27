//
//  FirebaseManager.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 09.02.2023.
//

import Foundation
import FirebaseAuth
import ProgressHUD

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
    
    func resetPassword(for email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            ProgressHUD.showSucceed()
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
    
    
    private func resetEmail(email: String) {
        Auth.auth().currentUser?.reload(completion: { error in
            if let error {
                print(error)
                return
            }
            Auth.auth().currentUser?.sendEmailVerification(completion: { error in
                print(error?.localizedDescription)
            })
        })
    }
    
    
    func updateEmail(email: String) {
        guard var user = User.getCurrentUser() else { return }
        Auth.auth().currentUser?.updateEmail(to: email) { error in
            if let error {
                print(error.localizedDescription)
                return
            }
            user.email = email
            self.resetEmail(email: email)
            
            FirestoreManager.shared.updateUserData(dataToUpdate: ["email" : email]) {
                user.saveLocally()
            }
            
        }
    }
    
}

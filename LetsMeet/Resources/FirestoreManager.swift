//
//  FirestoreManager.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 09.02.2023.
//


import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


enum Gender: String, Codable {
    case male = "Male"
    case female = "Female"
}


class FirestoreManager {
    static let shared = FirestoreManager()
    
    let db = Firestore.firestore()
}

extension FirestoreManager {
    func userExistsInDb(user: String, completion: @escaping (DocumentSnapshot?, Bool, Error?) -> Void) {
        db.collection("users").document(user).getDocument { document, error in
            guard let document else {
                print(error!)
                completion(nil, false, error)
                return
            }
            switch document.exists {
            case true:
                completion(document, true, nil)
            case false:
                completion(document, false, nil)
            }
        }
    }
    
    
    func createUserInDB(userID: String) {
        let col = db.collection("users")
        guard let currentUser = UserDefaults.standard.data(forKey: K.currentUserIdentifier) else {
            print("No data with key 'currentUser' in")
            return
        }
        do {
            
            let user = try JSONDecoder().decode(User.self, from: currentUser)
            try col.document(userID).setData(from: user)
        } catch {
            print(error)
        }
        
        //        docRef.setData(["username": username, "email": email, "city": city, "birthDate": birthDate, "gender": gender])
        
        
    }
}

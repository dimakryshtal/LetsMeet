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
    func getUserFromDb(userID: String, completion: @escaping(DocumentSnapshot?, Error?) -> Void) {
        db.collection("users").document(userID).getDocument { document, error in
            guard let document else {
                print(error!)
                completion(nil, error)
                return
            }
            completion(document, nil)
        }
        
    }
    
    
    
    func setUserInDB(user: User, completion: @escaping(Error?) -> Void) {
        let col = db.collection("users")
//        guard let currentUser = UserDefaults.standard.data(forKey: K.currentUserIdentifier) else {
//            print("No data with key 'currentUser' in")
//            return
//        }
        do {
//
//            let user = try JSONDecoder().decode(User.self, from: currentUser)
            try col.document(user.objectId).setData(from: user, completion: { error in
                completion(error)
            })
        } catch {
            print(error)
        }
        
    }
    
    func updateUserData(dataToUpdate: [String: Any], completion: @escaping(Error?) -> Void) {
        db.collection("users").document(User.getCurrentUser()!.objectId).updateData(dataToUpdate) { err in
            completion(err)
        }
    }
    
    func getUsersFromDatabase(limit: Int,lastDocument: DocumentSnapshot?, completion: @escaping([User]?, DocumentSnapshot?) -> Void) {
        
        var query = db.collection("users").whereField("gender", isEqualTo: User.getCurrentUser()?.lookingFor.rawValue)
            .whereField("lookingFor", isEqualTo: User.getCurrentUser()?.gender.rawValue)
            .limit(to: limit)
        
        
        if let lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        
        
        
        query.getDocuments { snapshot, error in
            guard let snapshot else {
                print(error!)
                completion(nil, nil)
                return
            }
            let users: [User] = snapshot.documents.map { document in

                let user = try! document.data(as: User.self)
                return user
            }
            completion(users, snapshot.documents.last)
        }
    }
}

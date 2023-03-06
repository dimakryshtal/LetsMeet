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
        do {
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
    
    func downloadLikedUsers(forUserID: String, comletion: @escaping([User]) -> Void) {
        let likesQuery = db.collection("likes")
            .whereField("user", isEqualTo: forUserID)
            
        var users: [User] = []
        likesQuery.getDocuments { snapshot, error in
            guard let snapshot else {
                print(error?.localizedDescription)
                return
            }
            let documents = snapshot.documents
            for (i, document) in documents.enumerated() {
                let id = try! document.data(as: LikeObject.self).likedUser
                
                self.checkIfLikeIsMutual(likedUserID: id) { likes in
                    print(id, likes)
                    if likes {
                        self.getUserFromDb(userID: id) { userSnapshot, error in
                            guard let userSnapshot else {
                                print(error?.localizedDescription)
                                return
                            }
                            users.append(try! userSnapshot.data(as: User.self))
                            if i == documents.count - 1 {
                                comletion(users)
                            }
                        }
                    }
                }
            }
            
        }
        
    }
}


extension FirestoreManager {
    func setLikeInDB(like: LikeObject, completion: @escaping(Error?) -> Void) {
        let col = db.collection("likes")
        do {
            try col.document(like.id).setData(from: like, completion: { error in
                completion(error)
            })
        } catch {
            print(error)
        }
        
    }
    
    func checkIfLikeIsMutual(likedUserID: String, completion: @escaping(Bool) -> Void) {
        let query = db.collection("likes")
            .whereField("user", isEqualTo: likedUserID)
            .whereField("likedUser", isEqualTo: User.getCurrentUserID()!)
        
            query.getDocuments { snapshot, error in
                guard let snapshot, snapshot.count != 0 else {
                    completion(false)
                    return
                }
                
                completion(true)
            }
    }
}

//
//  FirestoreManager.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 09.02.2023.
//


import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import ProgressHUD

enum Gender: String, Codable {
    case male = "Male"
    case female = "Female"
}

enum FirestoreCollections: String {
    case users
    case likes
    case chats
    case matches
    case messages
    case typing
}


class FirestoreManager {
    static let shared = FirestoreManager()
    
//    var typingListener: ListenerRegistration?
    
    
    private func firebaseReference(_ reference: FirestoreCollections) -> CollectionReference {
        return Firestore.firestore().collection(reference.rawValue)
    }
}

//MARK: - User
extension FirestoreManager {
    func getUserFromDb(userID: String, completion: @escaping(User?) -> Void) {
        firebaseReference(.users).document(userID).getDocument { document, error in
            guard let document else {
                print(error!)
                completion(nil)
                return
            }
            let user = try! document.data(as: User.self)
            completion(user)
        }
        
    }
    
    func getUserFromDb(userID: String) async -> User? {
        await withCheckedContinuation({ continuation in
            getUserFromDb(userID: userID) { user in
                continuation.resume(returning: user)
            }
        })
    }
    

    
    func setUserInDB(user: User, completion: (() -> Void)? = nil) {
        ProgressHUD.show()
        let col = firebaseReference(.users)
        do {
            try col.document(user.objectId).setData(from: user, completion: { error in
                completion?()
                if let error {
                    ProgressHUD.showError(error.localizedDescription)
                    return
                }
                user.saveLocally()
                ProgressHUD.showSucceed()
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func setUserInDB(user: User) async {
        await withCheckedContinuation({ continuation in
            setUserInDB(user: user) {
                continuation.resume()
            }
        })
    }
    
    func updateUserData(dataToUpdate: [String: Any], completion: @escaping () -> Void) {
        firebaseReference(.users).document(User.getCurrentUser()!.objectId).updateData(dataToUpdate) { error in
            if let error {
                print(error.localizedDescription)
                return
            }
            completion()
        }
    }
    
    func getUsersFromDatabase(limit: Int,lastDocument: DocumentSnapshot?, completion: @escaping([User]?, DocumentSnapshot?) -> Void) {
        
        var query = firebaseReference(.users)
            .whereField("gender", isEqualTo: User.getCurrentUser()?.lookingFor.rawValue)
            .whereField("lookingFor", isEqualTo: User.getCurrentUser()?.gender.rawValue)
            .limit(to: limit)
            
        
        if let user = User.getCurrentUser(), user.likedUsers.count != 0 {
            query = query.whereField("objectid", notIn: User.getCurrentUser()!.likedUsers)
        }
            
        if let lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        
        query.getDocuments { snapshot, error in
            guard let snapshot else {
                print(error?.localizedDescription)
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
    
    func downloadLikedUsers(forUserID: String, completion: @escaping([User]?) -> Void) {
        let likesQuery = firebaseReference(.likes)
            .whereField("user", isEqualTo: forUserID)
        
        var users: [User] = []
        likesQuery.getDocuments { snapshot, error in
            guard let snapshot else {
                print(error?.localizedDescription)
                completion(nil)
                return
            }

            let documents = snapshot.documents
            for (i, document) in documents.enumerated() {
                let id = try! document.data(as: LikeObject.self).likedUser
                self.getUserFromDb(userID: id) { user in
                    guard let user else { return }
                    users.append(user)
                    if i == documents.count - 1 {
                        completion(users)
                    }
                }
            }

        }
    }
        
        

    
}

//MARK: - Matches
extension FirestoreManager {
    func downloadMatches(completion: @escaping([MatchObject]?) -> Void) {
        let matchedQuery = firebaseReference(.matches)
            .whereField("memberIDs", arrayContains: User.getCurrentUserID()!)
        
        
        matchedQuery.getDocuments { snapshot, error in
            guard let snapshot else {
                print(error!)
                return
            }
            
            let matches = snapshot.documents.map{try! $0.data(as: MatchObject.self)}.sorted{$0.date.compare($1.date) == .orderedDescending}
            
            completion(matches)
            
        }
    }
    
    func setMatchInDB(match: MatchObject) {
        let col = firebaseReference(.matches)
        
        do {
            try col.document(match.id).setData(from: match)
        } catch {
            print(error)
        }
    }
}

//MARK: - Likes
extension FirestoreManager {
    func setLikeInDB(like: LikeObject, completion: @escaping(Error?) -> Void) {
        let col = firebaseReference(.likes)
        do {
            try col.document(like.id).setData(from: like, completion: { error in
                print(error?.localizedDescription)
                completion(error)
            })
        } catch {
            print(error)
        }
        
    }
    
    
    func checkIfLikeIsMutual(likedUserID: String, completion: @escaping(Bool) -> Void) {
        let query = firebaseReference(.likes)
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

//MARK: - Chats

extension FirestoreManager {
    func createNewChat(newChat: ChatObject) {
        firebaseReference(.chats)
            .document(newChat.id)
            .getDocument { _, error in
               if let error {
                    print(error)
                    return
                }
                
                var chat1 = newChat
                chat1.ownerId = chat1.memberIDs[0]
                var chat2 = newChat
                chat2.ownerId = chat2.memberIDs[1]
                self.createChatsForEachUser(chat: chat1)
                self.createChatsForEachUser(chat: chat2)
                
                
            }
    }
    func getRecentChats(completion: @escaping ([ChatObject]?) -> Void) {
        firebaseReference(.chats)
            .document(User.getCurrentUserID()!)
            .collection("personalChats")
            .getDocuments { snapshot, error in
            guard let snapshot else {
                print(error!)
                completion(nil)
                return
            }
            let chats = snapshot.documents.map{
                print($0.documentID)
                return try! $0.data(as: ChatObject.self)
            }
            completion(chats)
        }
    }
    
    func updateChatData(chatToUpdate: ChatObject, fieldToUpdate: [String: Any]) {
        for member in chatToUpdate.memberIDs {
            firebaseReference(.chats)
                .document(member)
                .collection("personalChats")
                .document(chatToUpdate.id)
                .updateData(fieldToUpdate)
        }
    }
}

//MARK: - Messages
extension FirestoreManager {
    func createNewMessage(message: Message) {
        try! firebaseReference(.messages)
            .document(message.chatRoomId)
            .collection(FirestoreCollections.messages.rawValue)
            .document(message.id).setData(from: message)
    }
    
    func downloadMessages(for chatId: String, lastDocument: String?, limit: Int, completion: @escaping([Message]?) -> Void) {
        Task{
            var query = firebaseReference(.messages)
                .document(chatId)
                .collection(FirestoreCollections.messages.rawValue)
                .limit(to: limit).order(by: "date", descending: true)
            
            if let lastDocument {
                let document = try! await firebaseReference(.messages)
                    .document(chatId)
                    .collection(FirestoreCollections.messages.rawValue)
                    .document(lastDocument)
                    .getDocument()
                query = query.start(afterDocument: document)
            }
            
            
          
            query.getDocuments { snapshot, error in
                guard let snapshot else {
                    print("Could not download messages: \(error!)")
                    completion(nil)
                    return
                }
                
                let messages = snapshot.documents.map{ try! $0.data(as: Message.self)}
                completion(messages)
            }
        }
    }
    
    func listenForMessages(for chatId: String, since date: Date, callbackWhenReceived: ((Message) -> Void)? = nil, callbackWhenModified: ((Message) -> Void)? = nil) -> ListenerRegistration {
        return firebaseReference(.messages)
            .document(chatId)
            .collection(FirestoreCollections.messages.rawValue)
            .whereField("date", isGreaterThan: Calendar.current.date(byAdding: .second, value: 1, to: date)!).addSnapshotListener { snapshot, error in
                guard let snapshot else {
                    print(error!)
                    return
                }
                
                if !snapshot.isEmpty {
                    for change in snapshot.documentChanges {
                        if change.type == .added {
                            callbackWhenReceived?(try! change.document.data(as: Message.self))
                        } else if change.type == .modified {
                            callbackWhenModified?(try! change.document.data(as: Message.self))
                        }
                        
                    }
                }
            }
    }
    
    func setMessageStatusToRead(for chatId: String, messageId: String) {
        firebaseReference(.messages)
            .document(chatId)
            .collection(FirestoreCollections.messages.rawValue)
            .document(messageId)
            .updateData(["status": "Read"])
        
    }
}

//MARK: - TypingListener

extension FirestoreManager {
    func createTypingListener(chatId: String, userId: String, callBack: @escaping ((Bool) -> Void)) -> ListenerRegistration {
        let typingListener = firebaseReference(.typing).document(chatId).collection("members").document(userId).addSnapshotListener({ snapshot, error in
            guard let snapshot else { return }
            
            if snapshot.exists {
                var typing = try! snapshot.data(as: TypingModel.self)
                
                callBack(typing.isTyping)
            } else {
                try! self.firebaseReference(.typing).document(chatId).collection("members").document(userId).setData(from: TypingModel(isTyping: false))
                try! self.firebaseReference(.typing).document(chatId).collection("members").document(User.getCurrentUserID()!).setData(from: TypingModel(isTyping: false))
            }
        })
        return typingListener
    }
    
    func updateTypingListener(chatId: String, userId: String, isTyping: Bool) {
        firebaseReference(.typing).document(chatId).collection("members").document(userId).updateData(["isTyping": isTyping])
    }

}

//MARK: - Helpers
extension FirestoreManager {
    func getChatIdFrom(user1Id: String, user2Id: String) -> String {
        let value = user1Id.compare(user2Id).rawValue
        
        return value < 0 ? "\(user1Id)_\(user2Id)" : "\(user2Id)_\(user1Id)"
    }
    func createChatsForEachUser(chat: ChatObject) {
        do {
            try self.firebaseReference(.chats)
                .document(chat.ownerId)
                .collection("personalChats")
                .document(chat.id)
                .setData(from: chat)
        } catch {
            print(error)
        }
    }
}





//
//  User.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 09.02.2023.
//

import UIKit
import FirebaseAuth


struct User: Codable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.objectId == rhs.objectId
    }
    
    var objectId: String
    var username: String
    var email: String
    var aboutMe: String?
    var city: String
    var birthDate: String
    var gender: Gender
    var job: String?
    var education: String?
    var country: String?
    var height: String?
    var likedUsers: [String] = []
    var lookingFor: Gender
    var avatarLink: String?

    subscript(key: String) -> Any? {
        let m = Mirror(reflecting: self)
        return m.children.first { $0.label == key }?.value
    }
    
    
    
    
    func saveLocally() {
        
        let endoder = JSONEncoder()
        do {
            let data = try endoder.encode(self)
            UserDefaults.standard.set(data, forKey: K.currentUserIdentifier)
        } catch {
            print(error)
        }
        
        
    }
    
    
}

extension User {
    static func getCurrentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    static func getCurrentUser() -> User? {
        if let currentUserData = UserDefaults.standard.data(forKey: K.currentUserIdentifier) {
            do {
                let currentUser = try JSONDecoder().decode(Self.self, from: currentUserData)
                return currentUser
            } catch {
                print(error)
            }
        }
        return nil
    }
    
//    static func updateCurrentUser(dataToUpdate: [String: Any]) {
//        guard var user = User.getCurrentUser() else { fatalError("No current user")}
//        for (key, value) in dataToUpdate {
//            switch key {
//            case "username":
//                user.username = value
//            default:
//                return
//            }
//        }
//    }
    
    
    static func uploadMochDataToDatabase() {
        let names = ["Carl", "Emma", "John", "Miley", "Justing"]
        
        for i in 0..<names.count {
            let id = UUID().uuidString
            let user = User(objectId: id,
                            username: names[i],
                            email: "\(names[i])\(i)@test.com",
                            city: "Kyiv",
                            birthDate: String("18-09-1999"),
                            gender: Gender(rawValue: i % 2 == 0 ? "Female" : "Male")!,
                            lookingFor: Gender(rawValue: i % 2 == 0 ? "Male" : "Female")!,
                            avatarLink: "avatarImage")
            FirestoreManager.shared.setUserInDB(user: user) { error in
                if let error {
                    print(error)
                }
                let image = ImageItem(name: "avatarImage", image: UIImage(named: "user\(i+1)")!)
                FirebaseStorageManager.shared.uploadPictureToFirebase(userID: id, image: image) { error in
                    print(error)
                }
            }
        }
    }
    
}

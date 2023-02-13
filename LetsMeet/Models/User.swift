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
    var height: Double?
    var lookingFor: Gender?
    var avatarLink: String?

    
    
    
    func saveLocally() {
        let endoder = JSONEncoder()
        do {
            let data = try endoder.encode(self)
            UserDefaults.standard.set(data, forKey: K.currentUserIdentifier)
        } catch {
            print(error)
        }
        
        
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
    
}

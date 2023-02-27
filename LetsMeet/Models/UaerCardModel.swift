//
//  UaerCardModel.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 17.02.2023.
//

import Foundation

struct UserCardModel {
    let id: String
    let name: String
    let age: Int
    let occupation: String
    let imageLink: String
}

extension UserCardModel {
    static let mockData = [
        UserCardModel(id: "1", name: "AlfaCliff", age: 25, occupation: "Gangster", imageLink: "user1"),
        UserCardModel(id: "2", name: "Stepan", age: 25, occupation: "Hoe", imageLink: "user2"),
        UserCardModel(id: "3", name: "Temarlan", age: 25, occupation: "Gangster", imageLink: "user3"),
        UserCardModel(id: "4", name: "Andromed", age: 25, occupation: "Singer", imageLink: "user4"),
        UserCardModel(id: "5", name: "Bimbas", age: 25, occupation: "Donbass bomber", imageLink: "user5")
    ]
}

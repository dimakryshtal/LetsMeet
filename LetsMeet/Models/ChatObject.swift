//
//  ChatObject.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 12.03.2023.
//

import Foundation

struct ChatObject: Codable {
    let id: String
    var ownerId: String = ""
    let memberIDs: [String]
    var lastMessage: String = ""
    var lastMessageDate: Date = Date()
    var lastReadMessageId: String = ""
    var hasNewMessages: Bool = false
}

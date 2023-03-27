//
//  Message.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 19.03.2023.
//

import Foundation
import Firebase

struct Message: Codable {
    var id = ""
    var chatRoomId = ""
    var senderId = ""
    var senderName = ""
    var type = ""
    var incoming = false
    var date = Date()
    var message = ""
    var photoWidth = 0
    var photoHeight = 0
    var senderInitials = ""
    var mediaURL = ""
    var status = ""
    
    static func createOutgointMessage(chatRoomId: String, text: String?, image: UIImage?) -> Message {
        var message = Message()
        message.id = UUID().uuidString
        message.chatRoomId = chatRoomId
        guard let user = User.getCurrentUser() else { fatalError("No current user") }
        message.senderId = user.objectId
        message.senderName = user.username
        message.senderInitials = String(user.username.prefix(1))
        message.message = text ?? "Picture message"
        message.type = text != nil ? "text" : "picture"
        message.status = "Sent"
        
        return message
    }
}

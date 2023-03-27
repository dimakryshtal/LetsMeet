//
//  MKMessage.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 19.03.2023.
//

import Foundation
import MessageKit

class MKMessage: NSObject, MessageType {
    var messageId: String
    var kind: MessageKind
    var sentDate: Date
    var incoming: Bool
    var mksender: MKSender
    var photoItem: PhotoMessage?
    var sender: SenderType { return mksender }
    var senderInitials: String
    
//    var photoItem
    
    var status: String
    init(message: Message) {
        self.messageId = message.id
        self.kind = MessageKind.text(message.message)
        self.sentDate = message.date
        self.incoming = message.incoming
        self.mksender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.senderInitials = message.senderInitials
        self.status = message.status
    }
}

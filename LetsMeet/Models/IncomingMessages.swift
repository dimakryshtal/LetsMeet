//
//  IncomingMessages.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 20.03.2023.
//

import Foundation
import MessageKit

class IncomingMessage {
    var messagesCollectionView: MessagesViewController
    
    init(messagesCollectionView: MessagesViewController) {
        self.messagesCollectionView = messagesCollectionView
    }
    
    func createMessage(message: Message) -> MKMessage {
        let mkMessage = MKMessage(message: message)
        
        if message.type == "picture" {
            print("It is a picture")
            let photoItem = PhotoMessage(path: message.mediaURL)
            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)
            
            FirebaseStorageManager.shared.getImage(location: message.mediaURL) { image in
                mkMessage.photoItem?.image = image
                self.messagesCollectionView.messagesCollectionView.reloadData()
            }
        }
        
        
        return mkMessage
    }
}

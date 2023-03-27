//
//  ChatTableViewCell.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 10.03.2023.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var newMessageIndicator: UIView!
    
    var chatObject: ChatObject?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImage.contentMode = .scaleAspectFill
        userImage.layer.cornerRadius = userImage.frame.height / 2
        newMessageIndicator.layer.cornerRadius = newMessageIndicator.frame.height / 2
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure() {
        guard let chatObject else { return }
        let userId = chatObject.memberIDs.first {$0 != User.getCurrentUserID()!}
        FirestoreManager.shared.getUserFromDb(userID: userId!) { user in
            guard let user else { return }

            FirebaseStorageManager.shared.getImage(location: "images/\(user.objectId)/\(user.avatarLink!).jpeg") { image in
                self.userImage.image = image
                self.name.text = user.username
                self.message.text = chatObject.lastMessage
                self.newMessageIndicator.isHidden = !chatObject.hasNewMessages
            }
        }
    }
    
}

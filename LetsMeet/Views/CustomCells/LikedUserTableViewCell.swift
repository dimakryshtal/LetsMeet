//
//  LikedUserTableViewCell.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 03.03.2023.
//

import UIKit

class LikedUserTableViewCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    var userData: User?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImage.contentMode = .scaleAspectFill
        userImage.layer.cornerRadius = userImage.frame.height / 2
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configure(with user: User) {
        userData = user
        name.text = user.username
        FirebaseStorageManager.shared.getImage(location: "images/\(user.objectId)/\(user.avatarLink!).jpeg") { image in
            self.userImage.image = image
        }
    }
}

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
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configure() {
        guard let userData else { return }
        name.text = userData.username
        FirebaseStorageManager.shared.getImage(image: "\(userData.avatarLink!).jpeg", userID: userData.objectId) { image in
            self.userImage.image = image
        }
    }
}

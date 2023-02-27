//
//  UserCard.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 17.02.2023.
//

import UIKit
import Shuffle

class UserCard: SwipeCard {
    
    
    func configure(withModel model: User) {
        content = UserCardContentView(withUser: model)
        footer = UserCardFooterView(withTitle: "\(model.username), \(Date.calculateCurrentAge(birthDate: model.birthDate))", subTitle: model.job)
    }
}

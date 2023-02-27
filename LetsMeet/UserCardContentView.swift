//
//  UserCardContentView.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 17.02.2023.
//

import UIKit

class UserCardContentView: UIView {
    
    private let backgroundView: UIView = {
        let bv = UIView()
        bv.clipsToBounds = true
        bv.layer.cornerRadius = 10
        return bv
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let gradient: CAGradientLayer = {
       let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.withAlphaComponent(0.05).cgColor, UIColor.black.withAlphaComponent(0.8).cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        return gradient
    }()
    
    init(withUser user: User) {
        super.init(frame: .zero)
        FirebaseStorageManager.shared.getImage(image: "\(user.avatarLink!).jpeg", userID: user.objectId) { image in
            self.imageView.image = image
        }
        
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    private func configureViews() {
        addSubview(backgroundView)
        backgroundView.anchorToSuperview()
        backgroundView.addSubview(imageView)
        imageView.anchorToSuperview()
        applyShadow(radius: 8, opacity: 0.2, offset: CGSize(width: 0, height: 2))
        backgroundView.layer.insertSublayer(gradient, above: imageView.layer)
        
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let heightFactor: CGFloat = 0.35
        gradient.frame = CGRect(x: 0, y: (1 - heightFactor) * bounds.height, width: bounds.width, height: heightFactor * bounds.height)
    }
    
}

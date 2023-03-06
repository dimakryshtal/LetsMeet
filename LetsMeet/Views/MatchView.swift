//
//  MatchView.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 04.03.2023.
//

import UIKit

class MatchView: UIView {
    let userData: User?
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "user2")
        imageView.contentMode = .scaleAspectFill
        
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    let matchBanner: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 60/255, green: 36/255, blue: 98/255, alpha: 0.91)
        view.layer.cornerRadius = 40
        
        return view
    }()
    
    let matchImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "matchImage")
        imageView.contentMode = .scaleToFill
//        imageView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(hideButtonTap)))
        
        return imageView
    }()
    
    let messageButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "message"), for: .normal)
        
        return button
    }()
    let hideButton: UIButton = {
        let button = UIButton()
        
        button.setImage(UIImage(named: "dislike"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        button.addTarget(nil, action: #selector(hideButtonTap), for: .touchUpInside)
//        button.clipsToBounds = true
        
        return button
    }()
    
    init(user: User) {
        self.userData = user
        super.init(frame: CGRect())
        configureView()
        setConstraints()
    }
    
    override init(frame: CGRect) {
        self.userData = nil
        super.init(frame: frame)
        configureView()
        setConstraints()

    }


    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureView() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 40
        self.addSubview(imageView)
        imageView.addSubview(matchBanner)
        matchBanner.addSubview(hideButton)
        matchBanner.addSubview(matchImage)
        matchBanner.addSubview(messageButton)
        if let userData {
            FirebaseStorageManager.shared.getImage(image: "\(userData.avatarLink!).jpeg", userID: userData.objectId) { image in
                self.imageView.image = image
            }
        }
        
    }
    
    func setConstraints() {
        imageView.anchorToSuperview()
        matchBanner.anchor(left: imageView.leftAnchor,
                           bottom: imageView.bottomAnchor,
                           right: imageView.rightAnchor,
                           height: 121)
        matchImage.centerXAnchor.constraint(equalTo: matchBanner.centerXAnchor).isActive = true
        matchImage.centerYAnchor.constraint(equalTo: matchBanner.centerYAnchor).isActive = true
        matchImage.anchor(width: 144, height: 101)
        
        hideButton.anchor(right: matchImage.leftAnchor, paddingRight: 20, width: 54, height: 54)
        hideButton.centerYAnchor.constraint(equalTo: matchImage.centerYAnchor).isActive = true
        messageButton.anchor(left: matchImage.rightAnchor, paddingLeft: 20, width: 54, height: 54)
        messageButton.centerYAnchor.constraint(equalTo: matchImage.centerYAnchor).isActive = true
        
    }

    @objc func hideButtonTap() {
        print("tapped")
//        self.removeFromSuperview()
    }
}

//
//  CardViewController.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 17.02.2023.
//

import UIKit
import Shuffle
import FirebaseFirestore

class CardViewController: UIViewController {
    
    private var cardStack = SwipeCardStack()
    
    private var firstCardModel: [User] = []
    private var secondCardModel: [User] = []
    private var swapped = false {
        didSet {
            if swapped {
                firstCardModel = []
            } else {
                secondCardModel = []
            }
        }
    }
    
    private var numberOfSwapped = 0
    private var lastDocumentSnapshot: DocumentSnapshot?
    
    let smashButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "SmashButton"), for: .normal)
        
        return button
    }()
    
    let passButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Pass"), for: .normal)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        FirestoreManager.shared.getUsersFromDatabase(limit: 5, lastDocument: nil) { users, lastDocumentSnapshot in
            self.lastDocumentSnapshot = lastDocumentSnapshot
            guard let users else { return }
            for (i, user) in users.enumerated() {
                self.firstCardModel.append(user)
            }
            self.cardStack.reloadData()
        }

        smashButton.addTarget(self, action: #selector(smashButtonTapped), for: .touchUpInside)
        
        layoutCardStacKView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        FirestoreManager.shared.getUsersFromDatabase { users in
//
//        }
    }
    
    private func layoutCardStacKView() {
        cardStack.delegate = self
        cardStack.dataSource = self
        
        view.addSubview(cardStack)
        
        view.addSubview(smashButton)
        view.addSubview(passButton)
        
        smashButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, width: 60, height: 60)
        smashButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        
        
        cardStack.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.safeAreaLayoutGuide.leftAnchor,
                         bottom: smashButton.topAnchor,
                         right: view.safeAreaLayoutGuide.rightAnchor,
                         paddingTop: 10)
        passButton.anchor(left: smashButton.rightAnchor,
                          bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          paddingLeft: 10,
                          width: 60,
                          height: 60)
    }
    
    private func showUserProfileForUser(user: User) {
        guard let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileTableView")  as? UserProfileTableViewController else {
            fatalError("Could not typecast view to UserProfileTableviewController")
        }
        profileView.profileData = user
        
        self.present(profileView, animated: true)
    }
}

//MARK: - Selector methods

extension CardViewController {
    @objc func smashButtonTapped() {
        print("Smash tapped")
    }
}


//MARK: - SwipeCardDelegate
extension CardViewController: SwipeCardStackDelegate {
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        print("Did swipe all cards")
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        
        numberOfSwapped += 1

        print("\(index) swapped")
        
        if numberOfSwapped == 4 {
            
            FirestoreManager.shared.getUsersFromDatabase(limit: 5, lastDocument: lastDocumentSnapshot) { users, lastSnapshot in
                self.lastDocumentSnapshot = lastSnapshot
                guard let users else { return }
                var newUsers: [User] = []
                for (i, user) in users.enumerated() {
                    newUsers.append(user)
                }

                if !self.swapped {
                    self.secondCardModel = newUsers
                } else {
                    self.firstCardModel = newUsers
                }
            }
        }
        
        if numberOfSwapped == 5 {
            numberOfSwapped = 0
            swapped.toggle()
            
            
            cardStack.reloadData()
        }
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        print(index)
        showUserProfileForUser(user: swapped ? secondCardModel[index] : firstCardModel[index])
    }
    
}


//MARK: - SwipeCardStackDataSource
extension CardViewController: SwipeCardStackDataSource {
    func cardStack(_ cardStack: Shuffle.SwipeCardStack, cardForIndexAt index: Int) -> Shuffle.SwipeCard {
        

        let card = UserCard()
        card.footerHeight = 80
        card.swipeDirections = [.left, .right]
        
        for direction in card.swipeDirections {
            card.setOverlay(UserCardOverlay(direction: direction), forDirection: direction)
        }
        
        if !swapped {
            
            card.configure(withModel: firstCardModel[index])
            
        } else {
            card.configure(withModel: secondCardModel[index])
        }
        return card
    }
    
    func numberOfCards(in cardStack: Shuffle.SwipeCardStack) -> Int {
        return swapped ? secondCardModel.count : firstCardModel.count
    }
    
    
}

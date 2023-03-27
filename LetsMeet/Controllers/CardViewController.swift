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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        FirestoreManager.shared.getUsersFromDatabase(limit: 5, lastDocument: nil) { users, lastDocumentSnapshot in
            self.lastDocumentSnapshot = lastDocumentSnapshot
            guard let users else { return }
            for user in users {
                self.firstCardModel.append(user)
            }
            self.cardStack.reloadData()
        }

        
        
        layoutCardStacKView()
        
    }
    
    private func layoutCardStacKView() {
        cardStack.delegate = self
        cardStack.dataSource = self
        
        view.addSubview(cardStack)
        
        
        cardStack.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.safeAreaLayoutGuide.leftAnchor,
                         bottom: view.safeAreaLayoutGuide.bottomAnchor,
                         right: view.safeAreaLayoutGuide.rightAnchor,
                         paddingTop: 10,
                         paddingBottom: 10)
    }
    
    private func showUserProfileForUser(user: User) {
        guard let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileTableView")  as? UserProfileTableViewController else {
            fatalError("Could not typecast view to UserProfileTableviewController")
        }
        profileView.profileData = user
        profileView.delegate = self
        
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
                for user in users{
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
        
        if direction == .right {
            let likedUser = swapped ? secondCardModel[index] : firstCardModel[index]
            FirestoreManager.shared.setLikeInDB(like: LikeObject(id: UUID().uuidString,
                                                                 user: User.getCurrentUserID()!,
                                                                 likedUser: likedUser.objectId)) { error in
                if let error {
                    print(error)
                    return
                }
            }
            guard var user = User.getCurrentUser() else {
                return
            }
            
            
            user.likedUsers.append(likedUser.objectId)
            
            FirestoreManager.shared.updateUserData(dataToUpdate: ["likedUsers" : user.likedUsers]) {
                user.saveLocally()
            }
            
            FirestoreManager.shared.checkIfLikeIsMutual(likedUserID: likedUser.objectId) { likes in
                if likes {
                    self.presentMatchView(likedUser: likedUser)
                    let matchObject = MatchObject(id: UUID().uuidString, memberIDs: [likedUser.objectId, User.getCurrentUserID()!], date: Date.now)
                    FirestoreManager.shared.setMatchInDB(match: matchObject)
                } else {
                    print("The user has not liked you yet. ;(")
                }
            }
            
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

extension CardViewController: UserProfileTableViewDelegate {
    func swipeLeft() {
        cardStack.swipe(.left, animated: true)
    }
    
    func swipeRight() {
        cardStack.swipe(.right, animated: true)
    }
    
    
}


extension CardViewController {
    func presentMatchView(likedUser: User) {
        let matchView = MatchView(user: likedUser)
        matchView.alpha = 0
        self.view.addSubview(matchView)
        matchView.anchor(top: self.view.topAnchor,
                         left: self.view.leftAnchor,
                         bottom: self.view.bottomAnchor,
                         right: self.view.rightAnchor,
                         paddingTop: 107,
                         paddingLeft: 9,
                         paddingBottom: 107,
                         paddingRight: 9)
        UIView.animate(withDuration: 0.2, delay: 0) {
            matchView.alpha = 1
        }
    }
}

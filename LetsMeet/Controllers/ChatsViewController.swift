//
//  ChatsViewController.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 07.03.2023.
//

import UIKit

class ChatsViewController: UIViewController {
    
    @IBOutlet weak var recentsCollectionView: UICollectionView!
    @IBOutlet weak var chatsTableView: UITableView!
    
    var recentMatches:[MatchObject] = []
    var recentChats:[ChatObject] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recentsCollectionView.dataSource = self
        recentsCollectionView.delegate = self
        
        chatsTableView.dataSource = self
        chatsTableView.delegate = self
    
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getRecentUsersAndChats()
        
    }
}


//MARK: - CollectionViewDataSource
extension ChatsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recentMatches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recentCell", for: indexPath) as! RecentsCollectionViewCell
        
        cell.match = recentMatches[indexPath.item]
        cell.configure()
        
        return cell
    }
}

//MARK: - CollectionViewDelegate
extension ChatsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileTableView")  as? UserProfileTableViewController else {
            fatalError("Could not typecast view to UserProfileTableviewController")
        }
        let userID = recentMatches[indexPath.item].memberIDs.first { id in
            id != User.getCurrentUserID()
        }
        
        FirestoreManager.shared.getUserFromDb(userID: userID!) { user in
            profileView.profileData = user
//            profileView.hideSmashAndPassButtons()
            self.navigationController?.pushViewController(profileView, animated: true)
        }

        
    }
}


//MARK: - TableViewDataSource

extension ChatsViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatTableViewCell
        
        cell.chatObject = recentChats[indexPath.item]
        cell.configure()
        
        return cell
    }
    
    
}
//MARK: - TableViewDelegate

extension ChatsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        goToChat(chat: recentChats[indexPath.item])
    }
}

//MARK: - Helpers
extension ChatsViewController {
    func getRecentUsersAndChats() {
        FirestoreManager.shared.downloadMatches() { matches in
            guard let matches else {
                fatalError("Matches is nil")
            }
            self.recentMatches = matches
            self.recentsCollectionView.reloadData()
        }
        
        FirestoreManager.shared.getRecentChats { chats in
            guard let chats else {
                fatalError("Chats is nil")
            }
            print(chats)
            self.recentChats = chats
            self.chatsTableView.reloadData()
        }
    }
    
    private func goToChat(chat: ChatObject) {
        
        let recipient = chat.memberIDs.first {$0 != User.getCurrentUserID()!}!
        let chat = ChatViewController(chatData: chat, recipientName: "User")
        
        chat.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(chat, animated: true)
    }
}




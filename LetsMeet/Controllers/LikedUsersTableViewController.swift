//
//  LikedUsersTableViewController.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 03.03.2023.
//

import UIKit

class LikedUsersTableViewController: UITableViewController {
    
    var users: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        
        FirestoreManager.shared.downloadLikedUsers(forUserID: User.getCurrentUserID()!) { users in
            guard let users else { return }
            DispatchQueue.main.async {
                self.users = users
                self.tableView.reloadData()
            }
        }
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = tableView.dequeueReusableCell(withIdentifier: "likedUser", for: indexPath) as! LikedUserTableViewCell
        item.configure(with: users[indexPath.item])
        
        return item
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileTableView")  as? UserProfileTableViewController else {
            fatalError("Could not typecast view to UserProfileTableviewController")
        }
        
        profileView.profileData = (tableView.cellForRow(at: indexPath) as! LikedUserTableViewCell).userData

        
        self.navigationController?.pushViewController(profileView, animated: true)
        
        
    }

    

}

//
//  ViewController.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 09.02.2023.
//

import UIKit
import ProgressHUD

class WelcomeViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        ProgressHUD.show()
        
        guard let email = emailTextField.text, email != "" else {
            ProgressHUD.showError("Enter your e-mail.")
            return
        }
        
        FirebaseManager.shared.resetPassword(for: email)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        ProgressHUD.show()
        guard let email = emailTextField.text, email != "" else {
            ProgressHUD.showError("Enter your e-mail.")
            return
            
        }
        guard let password = passwordTextField.text, password != "" else {
            ProgressHUD.showError("Enter your password.")
            return
        }
        
        
        FirebaseManager.shared.login(withEmail: email, password: password) { authResult, error, isVerified in
            guard let authResult else {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            guard isVerified else {
                ProgressHUD.showError("Please, verify you e-mail.")
                return
            }
            
            
            FirestoreManager.shared.getUserFromDb(userID: authResult.user.uid) { user in

                if let user {
                    if let avatarLink = user.avatarLink {
                        FirebaseStorageManager.shared.getImage(location: "images/\(user.objectId)/\(avatarLink).jpeg")
                    }
                    user.saveLocally()

                } else {
                    guard let userData = UserDefaults.standard.data(forKey: K.currentUserIdentifier) else {
                        fatalError("No current user")
                    }
                    
                    do {
                        let user = try JSONDecoder().decode(User.self, from: userData)
                        FirestoreManager.shared.setUserInDB(user: user)
                    } catch {
                        print(error)
                    }
                }
                ProgressHUD.showSucceed()
            }
            
            
        }
        
    }
}



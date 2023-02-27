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
        
        FirebaseManager.shared.resetPassword(for: email) { error in
            if let error {
                ProgressHUD.showError(error.localizedDescription)
            }
            ProgressHUD.showSucceed()
        }
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
            
            
            FirestoreManager.shared.getUserFromDb(userID: authResult.user.uid) { document, error in
                guard let document else {
                    print(error!)
                    return
                }
                if document.exists {
                    do {
                        let user = try document.data(as: User.self)
                        if let avatarLink = user.avatarLink {
                            FirebaseStorageManager.shared.getImage(image: "\(avatarLink).jpeg",
                                                                   userID: user.objectId, completion: nil)
                        }
                        user.saveLocally()
                        
                    } catch {
                        print(error)
                    }
                } else {
                    guard let userData = UserDefaults.standard.data(forKey: K.currentUserIdentifier) else {
                        fatalError("No current user")
                    }
                    
                    do {
                        let user = try JSONDecoder().decode(User.self, from: userData)
                        FirestoreManager.shared.setUserInDB(user: user) { error in
                            if let error {
                                ProgressHUD.showError(error.localizedDescription)
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            ProgressHUD.showSucceed()
            
            
        }
        
    }
}



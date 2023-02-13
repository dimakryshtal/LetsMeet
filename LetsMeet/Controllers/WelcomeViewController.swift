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
        
        FirebaseManager.shared.reloadPassword(for: email) { error in
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
            
            
            FirestoreManager.shared.userExistsInDb(user: authResult.user.uid) { document, exists, error in
                guard let document else {
                    print(error!)
                    return
                }
                if exists {
                    do {
                        let user = try document.data(as: User.self)
                        user.saveLocally()
                        
                    } catch {
                        print(error)
                    }
                } else {
                    FirestoreManager.shared.createUserInDB(userID: authResult.user.uid)
                }
            }
            ProgressHUD.showSucceed()
            
            
        }
        
    }
}



//
//  RegisterViewController.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 09.02.2023.
//

import UIKit
import ProgressHUD

class RegisterViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var birthDateDatePicker: UIDatePicker!
    
    var gender: Gender = .male
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
    }
    
    //MARK: - IBActions
    @IBAction func genderSegmentValueChanged(_ sender: UISegmentedControl) {
        gender = sender.selectedSegmentIndex == 0 ? .male : .female
    }
    @IBAction func registerTapped(_ sender: Any) {
        
        guard let username = usernameTextField.text, username != "" else {
            ProgressHUD.showError("Enter your username.")
            return
        }
        guard let email = emailTextField.text, email != "" else {
            ProgressHUD.showError("Enter your e-mail.")
            return
        }
        guard let city = cityTextField.text, city != "" else {
            ProgressHUD.showError("Enter your city.")
            return
        }
        guard let password = passwordTextField.text, let passwordConfirmation = passwordConfirmationTextField.text,
                password == passwordConfirmation else {
            ProgressHUD.showError("Passwords do not match.")
            return
        }
        
        let birthDate = birthDateDatePicker.date.onlyDate()
        guard Date.calculateCurrentAge(birthDate: birthDate) >= 18 else {
            ProgressHUD.showError("You must be 18 or older.")
            return
        }
        
        ProgressHUD.show()
        FirebaseManager.shared.createNewUser(email: email, password: password) { authResult, error in
            guard let authResult else {
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            let user = User(objectId: authResult.user.uid,
                            username: username,
                            email: email,
                            city: city,
                            birthDate: birthDate,
                            gender: self.gender,
                            lookingFor: self.gender == .male ? .female : .male)
            user.saveLocally()

            authResult.user.sendEmailVerification { error in
                if let error {
                    print(error)
                    return
                }
                print("Successfully sent varification e-mail.")
            }

            self.dismiss(animated: true)
            ProgressHUD.showSucceed()
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

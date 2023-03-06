//
//  ProfileTableViewController.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 12.02.2023.
//

import UIKit
import FirebaseAuth
import PhotosUI
import ProgressHUD

class ProfileTableViewController: UITableViewController {
    //section 1 IBOutlets
    @IBOutlet weak var sectionOneView: UIView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameAgeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    //section 2 IBOutlets
    @IBOutlet weak var aboutMeTextView: UITextView!
    
    //section 3 IBOutlets
    @IBOutlet weak var jobTextField: UITextField!
    @IBOutlet weak var educationTextField: UITextField!
    
    //section 4 IBOutlets
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var lookingForTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    
    var userInteractionEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jobTextField.delegate = self
        educationTextField.delegate = self
        genderTextField.delegate = self
        cityTextField.delegate = self
        countryTextField.delegate = self
        lookingForTextField.delegate = self
        heightTextField.delegate = self
        
        configureSectionOne()
        changeEditingState()
        hideKeyboardWhenTappedAround()
        updateViewWhenKeyboardAppears()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showUserData()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        showPictureOptions()
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        if !userInteractionEnabled {
            toggleEditing()
        } else {
            let alert = UIAlertController(title: "You are leaving the edit mode without saving you changes.", message: "Would you like to continue", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { alert in
                self.toggleEditing()
                self.showUserData()
            }
            let noAction = UIAlertAction(title: "No", style: .default)
            
            alert.addAction([yesAction, noAction])
            
            present(alert, animated: true)
        }
    }
    
    
    @IBAction func settingButtonTapped(_ sender: Any) {
        showSettingsAlert()
    }
    
}


//MARK: - Configure Views
extension ProfileTableViewController {
    private func configureSectionOne() {
        sectionOneView.layer.cornerRadius = 100
        sectionOneView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
}

//MARK: - Helpers
extension ProfileTableViewController {
    private func toggleEditing() {
        userInteractionEnabled.toggle()
        changeEditingState()
        showSaveItem()
    }
    
    private func changeEditingState() {
        
        aboutMeTextView.isEditable = userInteractionEnabled
        jobTextField.isUserInteractionEnabled = userInteractionEnabled
        educationTextField.isUserInteractionEnabled = userInteractionEnabled
        genderTextField.isUserInteractionEnabled = userInteractionEnabled
        cityTextField.isUserInteractionEnabled = userInteractionEnabled
        countryTextField.isUserInteractionEnabled = userInteractionEnabled
        heightTextField.isUserInteractionEnabled = userInteractionEnabled
        lookingForTextField.isUserInteractionEnabled = userInteractionEnabled
    }
    
    private func showSaveItem() {
        let barItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = userInteractionEnabled ? barItem : nil
    }
    
    private func showUserData() {
        guard let user = User.getCurrentUser() else {
            fatalError("Current user not found")
        }
        
        print("Show user data called")
        
        if let imageLink = user.avatarLink {
            FirebaseStorageManager.shared.getImage(image: "\(imageLink).jpeg", userID: user.objectId) { image in
                guard let image else { return }
                self.avatar.image = image
            }
        }
        
        nameAgeLabel.text = "\(user.username), \(Date.calculateCurrentAge(birthDate: user.birthDate))"
        aboutMeTextView.text = user.aboutMe ?? ""
        educationTextField.text = user.education ?? ""
        genderTextField.text = user.gender.rawValue
        cityLabel.text = user.city
        cityTextField.text = user.city
        countryTextField.text = user.country ?? ""
        heightTextField.text = user.height ?? ""
    }
}

//MARK: - Alerts

extension ProfileTableViewController {
    private func showAlertWithTextField(fieldToChangeName: String) {
        let alert = UIAlertController(title: "Change \(fieldToChangeName)", message: "Enter your new \(fieldToChangeName)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { alertAction in
            if let textField = alert.textFields?[0], let newValue = textField.text {
                
                guard var user = User.getCurrentUser() else { return }
                if fieldToChangeName == "Username" {
                    user.username = newValue
                    FirestoreManager.shared.updateUserData(dataToUpdate: [fieldToChangeName.lowercased() : newValue]) { error in
                        if let error {
                            print(error)
                            return
                        }
                        user.saveLocally()
                        self.showUserData()
                    }
                } else {
                    FirebaseManager.shared.updateEmail(email: newValue) { error in
                        if error != nil { return }
                        user.email = newValue
                        FirebaseManager.shared.resetEmail(email: newValue) { error in
                            if let error {
                                print(error.localizedDescription)
                            }
                            return
                        }
                        
                        FirestoreManager.shared.updateUserData(dataToUpdate: [fieldToChangeName.lowercased() : newValue]) { error in
                            if error == nil {
                                user.saveLocally()
                                self.showUserData()
                            }
                        }
                    }
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addTextField { textField in
            textField.placeholder = fieldToChangeName
        }

        alert.addAction([okAction, cancel])

        self.present(alert, animated: true)
    }
    
    
    private func showAvatarOptions() {
        let alert = UIAlertController(title: "Change an Avatar", message: "Do you want to take a new photo or upload from your album?", preferredStyle: .alert)
        let avatarAction = UIAlertAction(title: "Camera", style: .default) { alert in
            self.showImagePicker()
        }
        let uploadPictures = UIAlertAction(title: "Photos", style: .default) { alert in
            self.showPHPicker(1, accessabilityLabel: "avatarSelector")
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction([avatarAction, uploadPictures, cancel])
        
        present(alert, animated: true)
    }
    
    private func showSettingsAlert() {
        let alert = UIAlertController(title: "Edit Account", message: "You can change your avatar or upload more photos.", preferredStyle: .actionSheet)
        let changeEmail = UIAlertAction(title: "Change Email", style: .default) { alert in
            print("Change email")
            self.showAlertWithTextField(fieldToChangeName: "Email")
        }
        let changeUsername = UIAlertAction(title: "Change Username", style: .default) { alert in
            print("Change name")
            self.showAlertWithTextField(fieldToChangeName: "Username")
        }
        let logOut = UIAlertAction(title: "Log Out", style: .destructive) { alert in
            do {
                try Auth.auth().signOut()
            } catch {
                print(error)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction([changeUsername, changeEmail, logOut, cancel])
        
        present(alert, animated: true)
    }
    
    private func showPictureOptions() {
        let alert = UIAlertController(title: "Upload Photos", message: "You can change your avatar or upload more photos.", preferredStyle: .actionSheet)
        let avatarAction = UIAlertAction(title: "Change an avatar", style: .default) { alert in
            self.showAvatarOptions()
        }
        let uploadPictures = UIAlertAction(title: "Upload photos", style: .default) { alert in
            self.showPHPicker(10, accessabilityLabel: "imagesSelector")
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction([avatarAction, uploadPictures, cancel])
        
        present(alert, animated: true)
    }
    
    
}

//MARK: - Actions
extension ProfileTableViewController {
    @objc func saveButtonTapped() {
        ProgressHUD.show()
        
        guard var user = User.getCurrentUser() else {
            return
        }
        
        user.aboutMe = aboutMeTextView.text
        user.city = cityTextField.text ?? ""
        user.country = countryTextField.text ?? ""
        user.education = educationTextField.text ?? ""
        user.gender = Gender(rawValue: genderTextField.text!)!
        user.lookingFor = Gender(rawValue: lookingForTextField.text!)!
        
        
        FirestoreManager.shared.setUserInDB(user: user) { error in
            if let error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            user.saveLocally()
            ProgressHUD.showSucceed()
            
        }
        toggleEditing()
    }
    
}

//MARK: - UITextFieldDelegate

extension ProfileTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }
}

//MARK: - ImagePicker

extension ProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func showImagePicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        avatar.image = image
    
        let imageItem = ImageItem(name: "avatarImage", image: image)
        
        FirebaseStorageManager.shared.uploadPictureToFirebase(userID: User.getCurrentUserID()!, image: imageItem) { error in
            if let error {
                print(error.localizedDescription)
                return
            }
            guard var user = User.getCurrentUser() else {
                fatalError("No current user")
            }
            user.avatarLink = imageItem.name
            FirestoreManager.shared.setUserInDB(user: user) { error in
                user.saveLocally()
                if let error {
                    print(error)
                }
            }
        }
    }
}

//MARK: - PHPicker

extension ProfileTableViewController: PHPickerViewControllerDelegate {
    
    
    
    func showPHPicker (_ numberOfItems: Int, accessabilityLabel: String? = nil) {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = numberOfItems
        
        let picker = PHPickerViewController(configuration: config)
        picker.accessibilityLabel = accessabilityLabel
        picker.delegate = self
        present(picker, animated: true)
    }
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        if picker.accessibilityLabel == "avatarSelector" {
            let assetId = results.first?.assetIdentifier
            guard let phAsset = PHAsset.fetchAssets(withLocalIdentifiers: [assetId!], options: nil).firstObject else { return }
            
            PHImageManager.default().requestImageDataAndOrientation(for: phAsset, options: nil) { data, _, _, _ in
                guard let data, let image = UIImage(data: data) else {
                    print("Could not parse Data to UIImage")
                    return
                }
                
                guard var user = User.getCurrentUser() else { return }
                FirebaseStorageManager.shared.uploadPictureToFirebase(userID: user.objectId,
                                                                      image: ImageItem(name: "avatarImage", image: image)) { error in
                    if let error {
                        print(error)
                        return
                    }
                    
                    user.avatarLink = "avatarImage"
                    FirestoreManager.shared.setUserInDB(user: user) { error in
                        user.saveLocally()
                        if let error {
                            print(error)
                        }
                    }
                }
            }
        }
        else if picker.accessibilityLabel == "imagesSelector" {
            print("imagesSelector")
            
            let localIdentifiers = results.map { $0.assetIdentifier!}
        
            let phAssets = PHAsset.fetchAssets(withLocalIdentifiers: localIdentifiers, options: nil)
            
            for i in 0..<(phAssets.count) {
                PHImageManager.default().requestImageDataAndOrientation(for: phAssets[i], options: nil) { data, _, _, _ in
                    guard let data, let image = UIImage(data: data) else {
                        print("Could not parse Data to UIImage")
                        return
                    }

                    FirebaseStorageManager.shared.uploadPictureToFirebase(userID: User.getCurrentUserID()!,
                                                                          image: ImageItem(name: String(phAssets[i].localIdentifier.prefix(8)), image: image)) { error in
                        if let error {
                            print(error)
                            return
                        }
                    }
                }
            }
        }
    }
}




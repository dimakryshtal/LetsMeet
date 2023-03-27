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
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var lookingForSegmentedControl: UISegmentedControl!
    var userInteractionEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jobTextField.delegate = self
        educationTextField.delegate = self
        cityTextField.delegate = self
        countryTextField.delegate = self
        heightTextField.delegate = self
        
        configureSectionOne()
        changeEditingState()
        hideKeyboardWhenTappedAround()
        updateViewWhenKeyboardAppears()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showUserData()
    }
    
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        showPictureOptions()
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        if !userInteractionEnabled {
            toggleEditing()
        } else {
            let alert = UIAlertController(title: "You are leaving the edit mode without saving you changes.", message: "Would you like to continue", preferredStyle: .alert)
            let noAction = UIAlertAction(title: "No", style: .default)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { alert in
                self.toggleEditing()
                self.showUserData()
            }
            
            alert.addAction([yesAction, noAction])
            
            present(alert, animated: true)
        }
    }
    
    
    @IBAction func settingButtonTapped(_ sender: Any) {
        showSettingsAlert()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
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
        toggleSaveNavBarItem()
    }
    
    private func changeEditingState() {
        aboutMeTextView.isEditable = userInteractionEnabled
        jobTextField.isUserInteractionEnabled = userInteractionEnabled
        educationTextField.isUserInteractionEnabled = userInteractionEnabled
        genderSegmentedControl.isUserInteractionEnabled = userInteractionEnabled
        cityTextField.isUserInteractionEnabled = userInteractionEnabled
        countryTextField.isUserInteractionEnabled = userInteractionEnabled
        heightTextField.isUserInteractionEnabled = userInteractionEnabled
        lookingForSegmentedControl.isUserInteractionEnabled = userInteractionEnabled
    }
    
    private func toggleSaveNavBarItem() {
        let barItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = userInteractionEnabled ? barItem : nil
    }
    
    private func showUserData() {
        guard let user = User.getCurrentUser() else {
            fatalError("Current user not found")
        }
        
        print("Show user data called")
        
        if let imageLink = user.avatarLink {
            FirebaseStorageManager.shared.getImage(location: "images/\(user.objectId)/\(imageLink).jpeg") { image in
                guard let image else { return }
                self.avatar.image = image
            }
        }
        
        nameAgeLabel.text = "\(user.username), \(Date.calculateCurrentAge(birthDate: user.birthDate))"
        aboutMeTextView.text = user.aboutMe ?? ""
        educationTextField.text = user.education ?? ""
        genderSegmentedControl.selectedSegmentIndex = user.gender == .male ? 0 : 1
        cityLabel.text = user.city
        cityTextField.text = user.city
        countryTextField.text = user.country ?? ""
        heightTextField.text = user.height ?? ""
        lookingForSegmentedControl.selectedSegmentIndex = user.lookingFor == .male ? 0 : 1
    }
    
    //TODO
    func saveAvatarImage(image: UIImage) {
        guard var user = User.getCurrentUser() else {
            fatalError("No current user")
        }
        FirebaseStorageManager.shared.uploadPictureToFirebase(location: "images/\(user.objectId)/avatarImage.jpeg",
                                                              userID: user.objectId,
                                                              image: image) {
            self.avatar.image = image
            user.avatarLink = "avatarImage"
            FirestoreManager.shared.setUserInDB(user: user)
        }
    }
}

//MARK: - Alerts

extension ProfileTableViewController {
    private func showAlertWithTextField(fieldToChangeName: String) {
        let alert = UIAlertController(title: "Change \(fieldToChangeName)", message: "Enter your new \(fieldToChangeName)", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let okAction = UIAlertAction(title: "OK", style: .default) { alertAction in
            guard var user = User.getCurrentUser() else { return }
            guard let textField = alert.textFields?[0], let newValue = textField.text else { return }
            if fieldToChangeName == "Username" {
                FirestoreManager.shared.updateUserData(dataToUpdate: [fieldToChangeName.lowercased() : newValue]) {
                    user.username = newValue
                    user.saveLocally()
                    self.showUserData()
                }
            } else {
                FirebaseManager.shared.updateEmail(email: newValue)
            }
        }
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
        guard var user = User.getCurrentUser() else { return }
        
        user.aboutMe = aboutMeTextView.text
        user.city = cityTextField.text ?? ""
        user.country = countryTextField.text ?? ""
        user.education = educationTextField.text ?? ""
        user.gender = genderSegmentedControl.selectedSegmentIndex == 0 ? .male : .female
        user.lookingFor = lookingForSegmentedControl.selectedSegmentIndex == 0 ? .male : .female
        
        Task {
            await FirestoreManager.shared.setUserInDB(user: user)
            toggleEditing()
        }
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
        
        guard var user = User.getCurrentUser() else {
            fatalError("No current user")
        }
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        saveAvatarImage(image: image)
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
                
                
                self.saveAvatarImage(image: image)
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
                    

                    let userId = User.getCurrentUserID()!

                    FirebaseStorageManager.shared.uploadPictureToFirebase(location:"images/\(userId)/\(UUID().uuidString).jpeg",
                                                                          userID: userId,
                                                                          image: image)
                }
            }
        }
    }
}




//
//  ProfileTableViewController.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 12.02.2023.
//

import UIKit

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
    
    var userInterractionEnabled = false
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSectionOne()
        changeEditingState()
        
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
        userInterractionEnabled.toggle()
        changeEditingState()
        showSaveItem()
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
    private func changeEditingState() {
        
        aboutMeTextView.isEditable = userInterractionEnabled
        jobTextField.isUserInteractionEnabled = userInterractionEnabled
        educationTextField.isUserInteractionEnabled = userInterractionEnabled
        genderTextField.isUserInteractionEnabled = userInterractionEnabled
        cityTextField.isUserInteractionEnabled = userInterractionEnabled
        countryTextField.isUserInteractionEnabled = userInterractionEnabled
        heightTextField.isUserInteractionEnabled = userInterractionEnabled
        lookingForTextField.isUserInteractionEnabled = userInterractionEnabled
        
        
        
    }
    
    private func showSaveItem() {
        let barItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: nil)
        navigationItem.rightBarButtonItem = userInterractionEnabled ? barItem : nil
    }
    
    private func showUserData() {
        guard let user = User.getCurrentUser() else {
            fatalError("Error: \(K.currentUserIdentifier) not found")
        }
        nameAgeLabel.text = "\(user.username), \(Date.calculateCurrentAge(birthDate: user.birthDate))"
        aboutMeTextView.text = user.aboutMe == "" ? ""
        educationTextField.text = user.education ?? ""
        genderTextField.text = user.gender.rawValue
        cityLabel.text = user.city
        cityTextField.text = user.city
        countryTextField.text = user.country ?? ""
        heightTextField.text = ""
    }
}

//MARK: - Alerts

extension ProfileTableViewController {
    private func showPictureOptions() {
        let alert = UIAlertController(title: "Upload picture", message: "You can change your avatar or upload more pictures.", preferredStyle: .actionSheet)
        let avatarAction = UIAlertAction(title: "Change avatar", style: .default) { alert in
            print("change avatar")
        }
        let uploadPictures = UIAlertAction(title: "Upload pictures", style: .default) { alert in
            print("upload pictures")
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction([avatarAction, uploadPictures, cancel])
        
        present(alert, animated: true)
    }
    
}

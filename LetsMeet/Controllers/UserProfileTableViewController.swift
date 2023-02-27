//
//  UserProfileTableViewController.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 24.02.2023.
//

import UIKit

class UserProfileTableViewController: UITableViewController {
    
    
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var aboutTextView: UITextView!

    @IBOutlet weak var educationLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var lookingForLabel: UILabel!
    
    var allImages: [ImageItem] = []
    
    
    var profileData: User? {
        didSet {
            guard let profileData else { return }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.isHidden = true
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        
        
        showUserData()
    
    }
    
    @IBAction func didTapPassButton(_ sender: Any) {
//        changeActivityIndicatorState()
    }
    
    
    @IBAction func didTapSmashButton(_ sender: Any) {
    }
    
}

extension UserProfileTableViewController {
    private func showUserData() {
        guard let profileData else {return}
        aboutTextView.text = profileData.aboutMe ?? ""
        educationLabel.text = profileData.education
        jobLabel.text = profileData.job
        genderLabel.text = profileData.gender.rawValue
        heightLabel.text = profileData.height
        lookingForLabel.text = profileData.lookingFor.rawValue
        

        
        FirebaseStorageManager.shared.downloadAllImages(UserID: profileData.objectId) { images in
            self.allImages += images
            self.allImages = self.allImages.sorted { image1, image2 in
                let imageName = "avatarImage.jpeg"
                return image1.name == imageName && image2.name != imageName
            }
            
            self.setPageControlPages()
            self.changeActivityIndicatorState()
            self.photosCollectionView.reloadData()
        }
    }
}

extension UserProfileTableViewController {
    private func changeActivityIndicatorState() {
        activityIndicator.isHidden.toggle()
        pageControl.isHidden.toggle()
        activityIndicator.isAnimating ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
    }
}

extension UserProfileTableViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

//MARK: - PageControl
extension UserProfileTableViewController {
    private func setPageControlPages() {
        self.pageControl.numberOfPages = allImages.count
    }
    
    private func setCurrentPage(number: Int) {
        self.pageControl.currentPage = number
    }
}

extension UserProfileTableViewController: UICollectionViewDelegate {}

extension UserProfileTableViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        
        
        
        cell.setupCell(image: allImages[indexPath.item].image, contry: profileData?.city ??  "", nameAge: profileData?.username ?? "", isFirst: indexPath.item == 0)
        
        return cell
    }
}

extension UserProfileTableViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        setCurrentPage(number: indexPath.item)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

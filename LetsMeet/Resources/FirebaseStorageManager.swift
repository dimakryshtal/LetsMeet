//
//  FirebaseStorageManager.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 14.02.2023.
//

import UIKit
import FirebaseStorage

class FirebaseStorageManager {
    static let shared = FirebaseStorageManager()
    
    let imagesCache = NSCache<NSString, UIImage>()
    
    
    let storage = Storage.storage()
    
    init() {
        imagesCache.totalCostLimit = 50_000_000
    }
}

extension FirebaseStorageManager {

    func getImage(image: String, userID: String, completion: ((UIImage?) -> Void)?) {
        let imageLink = "images/\(userID)/\(image)"

        let imageRef = storage.reference().child(imageLink)
        
        if let image = imagesCache.object(forKey: imageLink as NSString) {
            print("Retrieved image from cache")
            completion?(image)
            
            return
        }
        
        var task: StorageDownloadTask!
        
        task = imageRef.getData(maxSize: 4 * 1024 * 1024, completion: { data, error in
            guard let data, let image = UIImage(data: data) else {
                task.removeAllObservers()
                print(error!)
                completion?(nil)
                return
            }
            self.imagesCache.setObject(image, forKey: imageLink as NSString)
            task.removeAllObservers()
            completion?(image)
        })
        
    }
    
    func downloadAllImages(UserID: String, completion: @escaping([ImageItem])->Void) {
        let imagesRef = storage.reference().child("images/\(UserID)")
        var images:[ImageItem] = []
        
        imagesRef.listAll { storageResult, error in
            if let error {
                print(error)
                return
            }
            
            guard let storageResult else { return }
            
            for item in storageResult.items {
                let imageName = item.name
                print(imageName)
                self.getImage(image: imageName, userID: UserID) { image in
                    if let image {
                        images.append(ImageItem(name: imageName, image: image))
                    }
                    if images.count == storageResult.items.count {
                        completion(images)
                    }
                }
            }
        }
    }
    
    func uploadPictureToFirebase(userID: String, image: ImageItem, completion: @escaping(Error?) -> Void) {
        let imagesRef = storage.reference().child("images/\(userID)/\(image.name).jpeg")
        
        var task: StorageUploadTask!
        
        task = imagesRef.putData(image.image.jpegData(compressionQuality: 0.5)!) { _, error in
            task.removeAllObservers()
            completion(error)
        }
        
    }
}

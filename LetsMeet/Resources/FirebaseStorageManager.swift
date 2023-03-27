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

    func getImage(location: String, completion: ((UIImage?) -> Void)? = nil) {
//        let imageLink = "images/\(userID)/\(image)"

        let imageRef = storage.reference().child(location)
        
        if let image = imagesCache.object(forKey: location as NSString) {
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
            self.imagesCache.setObject(image, forKey: location as NSString)
            task.removeAllObservers()
            completion?(image)
        })
        
    }
    
    func downloadAllImages(location: String, completion: @escaping([ImageItem])->Void) {
        let imagesRef = storage.reference().child(location)
        var images:[ImageItem] = []
        
        imagesRef.listAll { storageResult, error in
            if let error {
                print(error)
                return
            }
            
            guard let storageResult else { return }
            
            for item in storageResult.items {
                let imageName = item.name
                self.getImage(location: "\(location)/\(imageName)") { image in
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
    
    func uploadPictureToFirebase(location: String, userID: String, image: UIImage, completion: (() -> Void)? = nil) {
        let imagesRef = storage.reference().child(location)
        
        var task: StorageUploadTask!
        
        task = imagesRef.putData(image.jpegData(compressionQuality: 0.5)!) { _, error in
            task.removeAllObservers()
            if let error {
                print(error)
                return
            }
            completion?()
        }
        
        task.observe(.progress) { storageSnapshot in
            let progress = Double(storageSnapshot.progress!.completedUnitCount) / Double(storageSnapshot.progress!.totalUnitCount)
            print(progress)
        }
        
        
    }
    
    func uploadPictureToFirebase(location: String, userID: String, image: UIImage) async {
        await withCheckedContinuation({ continuation in
            uploadPictureToFirebase(location: location, userID: userID, image: image) {
                continuation.resume()
            }
        })
        
        
    }
}

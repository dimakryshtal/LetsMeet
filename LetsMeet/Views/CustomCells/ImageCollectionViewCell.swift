//
//  ImageCollectionViewCell.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 27.02.2023.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameAgeLabel: UILabel!
    @IBOutlet weak var cityCountryLabel: UILabel!
    @IBOutlet weak var backgroundPlaceholder: UIView!
    
    var gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        image.layer.cornerRadius = 5
        image.clipsToBounds = true
        
        
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setGradientLayer()
        
    }
    
    func setupCell(image: UIImage, contry: String, nameAge: String, isFirst: Bool) {
        self.image.image = image
        if !isFirst {
            nameAgeLabel.isHidden = true
            cityCountryLabel.isHidden = true
            return
        }
        self.nameAgeLabel.text = nameAge
        self.cityCountryLabel.text = contry
    }
    
    func setGradientLayer() {
        gradientLayer.removeFromSuperlayer()
        let topColor = UIColor.clear.cgColor
        let bottomColor = UIColor.black.withAlphaComponent(0.8).cgColor
        
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.locations = [0.0, 1.0]
        
        gradientLayer.cornerRadius = 5
        gradientLayer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gradientLayer.frame = self.backgroundPlaceholder.bounds
        self.backgroundPlaceholder.layer.insertSublayer(gradientLayer, at: 0)
    }
}


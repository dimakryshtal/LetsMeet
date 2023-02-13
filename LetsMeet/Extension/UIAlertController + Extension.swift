//
//  UIAlertController + Extension.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 12.02.2023.
//

import UIKit

extension UIAlertController {
    func addAction(_ actions: [UIAlertAction]){
        for action in actions {
            addAction(action)
        }
    }
}


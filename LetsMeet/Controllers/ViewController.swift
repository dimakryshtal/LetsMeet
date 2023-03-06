//
//  ViewController.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 05.03.2023.
//

import UIKit

class ViewController: UIViewController {
    let matchView = MatchView()

    override func viewDidLoad() {
        super.viewDidLoad()

        print("View did load")
    }
    
    override func viewDidLayoutSubviews() {
        view.addSubview(matchView)
        setConstraint()
        
    }

    func setConstraint() {
        matchView.anchor(top: view.topAnchor,
                         left: view.leftAnchor,
                         bottom: view.bottomAnchor,
                         right: view.rightAnchor,
                         paddingTop: 107,
                         paddingLeft: 9,
                         paddingBottom: 107,
                         paddingRight: 9)
    }
}

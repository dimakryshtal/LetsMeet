//
//  UserCardOverlay.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 17.02.2023.
//

import UIKit
import Shuffle

class UserCardOverlay: UIView {

    init(direction: SwipeDirection) {
        super.init(frame: .zero)
        
        switch direction {
        case .left:
            createLeftOverlay()
        case .right:
            createRightOverlay()
        default:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    private func createLeftOverlay() {
        let leftTextView = TinderCardOverlayLabelView(withTitle: "NOPE", color: .sampleRed, rotation: CGFloat.pi/10)
        addSubview(leftTextView)
        leftTextView.anchor(top: topAnchor,
                            left: leftAnchor,
                            paddingTop: 30,
                            paddingLeft: 14)
    }
    
    private func createRightOverlay() {
        let rightTextView = TinderCardOverlayLabelView(withTitle: "LIKE", color: .sampleGreen, rotation: -CGFloat.pi/10)
        addSubview(rightTextView)
        rightTextView.anchor(top: topAnchor,
                            right: rightAnchor,
                            paddingTop: 30,
                            paddingRight: 14)
    }
    
}

private class TinderCardOverlayLabelView: UIView {

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    return label
  }()

  init(withTitle title: String, color: UIColor, rotation: CGFloat) {
    super.init(frame: CGRect.zero)
    layer.borderColor = color.cgColor
    layer.borderWidth = 4
    layer.cornerRadius = 4
    transform = CGAffineTransform(rotationAngle: rotation)

    addSubview(titleLabel)
    titleLabel.textColor = color
    titleLabel.attributedText = NSAttributedString(string: title,
                                                   attributes: NSAttributedString.Key.overlayAttributes)
    titleLabel.anchor(top: topAnchor,
                      left: leftAnchor,
                      bottom: bottomAnchor,
                      right: rightAnchor,
                      paddingLeft: 8,
                      paddingRight: 3)
  }

  required init?(coder aDecoder: NSCoder) {
    return nil
  }
}

extension NSAttributedString.Key {

  static var overlayAttributes: [NSAttributedString.Key: Any] = [
    // swiftlint:disable:next force_unwrapping
    NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 42)!,
    NSAttributedString.Key.kern: 5.0
  ]
}

extension UIColor {
  static var sampleRed = UIColor(red: 252 / 255, green: 70 / 255, blue: 93 / 255, alpha: 1)
  static var sampleGreen = UIColor(red: 49 / 255, green: 193 / 255, blue: 109 / 255, alpha: 1)
  static var sampleBlue = UIColor(red: 52 / 255, green: 154 / 255, blue: 254 / 255, alpha: 1)
}


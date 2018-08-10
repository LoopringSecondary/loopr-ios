//
//  NumericKeyboardCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/8/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class NumericKeyboardCell: UICollectionViewCell {
    
    lazy var button: UIButton = { [unowned self] in
        let button = UIButton(type: .custom)
        button.titleLabel?.textAlignment = .center
        
        button.addTarget(self, action: #selector(_buttonTapped), for: .touchUpInside)
        // let tapGesture = UITapGestureRecognizer(target: self, action: #selector(_buttonTapped(_:)))
        // tapGesture.numberOfTapsRequired = 1
        // button.addGestureRecognizer(tapGesture)

        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(_buttonLongPressed(_:)))
        button.addGestureRecognizer(longGesture)

        self.contentView.addSubview(button)
        let edges = UIEdgeInsets(top: 1, left: 1, bottom: 0, right: 0)
        button.constrainToEdges(edges)
        return button
    }()
    
    var item: NumericKeyboardItem! {
        didSet {
            button.title = item.title
            button.titleColor = UIColor.text1
            button.titleLabel?.font = item.font
            button.image = item.image
            button.theme_tintColor = GlobalPicker.textColor
            
            button.theme_setBackgroundImage(GlobalPicker.button, forState: .normal)
            button.theme_setBackgroundImage(GlobalPicker.keyboard, forState: .highlighted)
        }
    }
    
    var buttonTapped: ((UIButton) -> Void)?
    
    @IBAction func _buttonTapped(_ button: UIButton) {
        buttonTapped?(button)
    }

    var buttonLongPressed: ((UIButton) -> Void)?

    @IBAction func _buttonLongPressed(_ sender: UIGestureRecognizer) {
        buttonLongPressed?(button)
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            buttonTapped?(button)
        } else if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
        }
    }

}

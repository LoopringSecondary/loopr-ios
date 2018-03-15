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
        self.contentView.addSubview(button)
        let edges = UIEdgeInsets(top: 1, left: 1, bottom: 0, right: 0)
        button.constrainToEdges(edges)
        return button
    }()
    
    var item: NumericKeyboardItem! {
        didSet {
            button.title = item.title
            button.titleColor = item.titleColor
            button.titleLabel?.font = item.font
            button.image = item.image
            button.tintColor = item.titleColor
            
            // Set backgroundColor
            // item.backgroundColor = UIColor(white: 0.9, alpha: 1)
            
            var image = item.backgroundColor.map { UIImage(color: $0) }
            button.backgroundImage = image
            
            // Set backgroundColor
            item.selectedBackgroundColor = UIColor(white: 0.9, alpha: 1)
            image = item.selectedBackgroundColor.map { UIImage(color: $0) }

            button.setBackgroundImage(image, for: .highlighted)
            button.setBackgroundImage(image, for: .selected)
        }
    }
    
    var buttonTapped: ((UIButton) -> Void)?
    
    @IBAction func _buttonTapped(_ button: UIButton) {
        buttonTapped?(button)
    }

}

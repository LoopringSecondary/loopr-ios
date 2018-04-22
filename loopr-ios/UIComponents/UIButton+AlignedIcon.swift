//
//  RightAlignedIconButton.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/21/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

extension UIButton {

    func setRightImage(imageName: String, imagePaddingTop: CGFloat, imagePaddingLeft: CGFloat, titlePaddingRight: CGFloat) {
        semanticContentAttribute = .forceRightToLeft
        
        //Set image
        let image = UIImage(named: imageName)
        self.setImage(image, for: .normal)
        self.setImage(image?.alpha(0.3), for: .highlighted)

        self.imageEdgeInsets = UIEdgeInsets(top: imagePaddingTop, left: 0, bottom: 0, right: -imagePaddingLeft)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: titlePaddingRight)
    }

    // TODO: Add a function to set left image
}

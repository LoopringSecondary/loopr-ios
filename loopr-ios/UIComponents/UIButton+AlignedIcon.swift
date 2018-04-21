//
//  RightAlignedIconButton.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/21/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

extension UIButton {

    func setRightImage(imageName: String, imagePaddingTop: CGFloat, imagePaddingRight: CGFloat, titlePaddingLeft: CGFloat) {
        //Set image
        let image = UIImage(named: imageName)
        self.setImage(image, for: .normal)
        self.setImage(image?.alpha(0.3), for: .highlighted)
        
        //Calculate and set image inset to keep it left aligned
        let imageWidth = image?.size.width ?? 0.0
        print(imageWidth)
        let textWidth =  self.titleLabel?.intrinsicContentSize.width ?? 0.0
        print(textWidth)
        // let buttonWidth = self.bounds.width

        // let rightInset = buttonWidth - imageWidth!  - textWidth! - paddingRight
        let leftInset = imageWidth + textWidth*2 + imagePaddingRight
        
        self.imageEdgeInsets = UIEdgeInsets(top: imagePaddingTop, left: leftInset, bottom: 0, right: 0)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: titlePaddingLeft)
    }

    // TODO: Add a function to set left image
}

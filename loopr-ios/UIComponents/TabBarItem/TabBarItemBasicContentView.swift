//
//  TabBarItemBasicContentView.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/13/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class TabBarItemBasicContentView: ESTabBarItemContentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // textColor = UIColor.black
        highlightTextColor = UIColor.black
        // iconColor = UIColor.black
        highlightIconColor = UIColor.black
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

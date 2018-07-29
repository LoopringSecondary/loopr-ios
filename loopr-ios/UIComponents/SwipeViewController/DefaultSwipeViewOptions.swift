//
//  DefaultSwipeViewOptions.swift
//  loopr-ios
//
//  Created by xiaoruby on 7/29/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

public extension SwipeViewOptions {
    
    static func getDefault() -> SwipeViewOptions {
        var options = SwipeViewOptions()
        options.swipeTabView.height = 44
        options.swipeTabView.underlineView.height = 2
        options.swipeTabView.underlineView.margin = 0
        options.swipeTabView.underlineView.backgroundLineColor = UIColor.init(rgba: "#444444")
        options.swipeTabView.itemView.font = FontConfigManager.shared.getCharactorFont()
        options.swipeContentScrollView.isScrollEnabled = true
        options.swipeTabView.style = .segmented
        options.swipeTabView.margin = 15
        return options
    }
    
}

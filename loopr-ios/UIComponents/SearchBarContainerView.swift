//
//  SearchBarContainerView.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/16/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SearchBarContainerView: UIView {
    
    let searchBar: UISearchBar
    
    init(customSearchBar: UISearchBar) {
        searchBar = customSearchBar
        super.init(frame: CGRect.zero)
        addSubview(searchBar)
        
        // https://stackoverflow.com/questions/44932084/ios-11-navigationitem-titleview-width-not-set/46073452
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    override convenience init(frame: CGRect) {
        self.init(customSearchBar: UISearchBar())
        self.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.searchBar.frame = self.bounds
    }

    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }
}

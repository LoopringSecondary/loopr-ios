//
//  PriceStackView.swift
//  loopr-ios
//
//  Created by kenshin on 2018/5/27.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import UIKit

protocol PriceStackViewDelegate: class {
    func setResultOfPrice(with tag: Int)
}

open class PriceStackView: UIStackView {

    weak var delegate: PriceStackViewDelegate?
    
    var priceButton: PriceButton!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        let color = UIColor.init(rgba: "#0094FF")
        let sell = LocalizedString("Selling Price", comment: "")
        let buy = LocalizedString("Buying Price", comment: "")
        let market = LocalizedString("Market Price", comment: "")
        let custom = LocalizedString("Customer Price", comment: "")
        priceButton = PriceButton(
            images: [ nil, nil, nil, nil],
            states: [custom, sell, buy, market],
            colors: [color, color, color, color],
            backgroundColors: [nil, nil, nil, nil]
        ) { button in
            self.delegate?.setResultOfPrice(with: button.currentStateIndex)
        }
        priceButton.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        priceButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        priceButton.contentHorizontalAlignment = .right
        self.addSubview(priceButton)
        
        self.axis = .horizontal
        self.distribution = .equalCentering
    }
    
    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

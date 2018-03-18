//
//  TradeTokenView.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class TradeTokenView: UIView {
    
    var titleLabel: UILabel
    var iconImageView: UIImageView
    var amountLabel: UILabel
    
    override init(frame: CGRect) {
        let padding: CGFloat = 10

        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 40))
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.black
        titleLabel.font = FontConfigManager.shared.getLabelFont()

        iconImageView = UIImageView(frame: CGRect(x: 0, y: titleLabel.frame.maxY + padding, width: frame.width, height: 60))
        iconImageView.contentMode = .scaleAspectFit

        amountLabel = UILabel(frame: CGRect(x: 0, y: iconImageView.frame.maxY + padding, width: frame.width, height: 40))
        amountLabel.textAlignment = .center
        amountLabel.font = UIFont.init(name: FontConfigManager.shared.getRegular(), size: 17)

        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(iconImageView)
        addSubview(amountLabel)
    }

    // Used in ConvertETHViewController
    func update(symbol: String) {
        amountLabel.text = symbol
        iconImageView.image = UIImage(named: symbol) ?? nil
    }
    
    func update(title: String, symbol: String, amount: Double) {
        titleLabel.text = title
        amountLabel.text = "\(amount) \(symbol)"

        // TODO: use symbol icon
        iconImageView.image = UIImage(named: symbol) ?? nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//
//  MarketDetailDepthTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 7/29/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

protocol MarketDetailDepthTableViewCellDelegate: class {
    // Use String since it's what users see.
    func clickedMarketDetailDepthTableViewCell(amount: String, price: String)
}

class MarketDetailDepthTableViewCell: UITableViewCell {

    weak var delegate: MarketDetailDepthTableViewCellDelegate?
    
    var buyDepth: Depth?
    var sellDepth: Depth?
    
    var baseViewBuy: UIView = UIView()
    var baseViewSell: UIView = UIView()
    
    var fakeBuyButton: UIButton = UIButton()
    var fakeSellButton: UIButton = UIButton()
    
    var label1: UILabel = UILabel()
    var label2: UILabel = UILabel()
    var label3: UILabel = UILabel()
    var label4: UILabel = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        clipsToBounds = true
        selectionStyle = .none
        theme_backgroundColor = GlobalPicker.backgroundColor
        
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        baseViewBuy.frame = CGRect(x: 15, y: 0, width: (screenWidth - 15*2 - 5)*0.5, height: 33+10)
        baseViewBuy.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        addSubview(baseViewBuy)
        
        label1 = UILabel(frame: CGRect(x: 10, y: 0, width: (baseViewBuy.width-30)*0.5, height: 33))
        label1.theme_textColor = GlobalPicker.textLightColor
        label1.font = FontConfigManager.shared.getMediumFont(size: 12)
        label1.textAlignment = .left
        baseViewBuy.addSubview(label1)
        
        label2 = UILabel(frame: CGRect(x: 10 + label1.frame.maxX, y: 0, width: (baseViewBuy.width-30)*0.5, height: 33))
        label2.theme_textColor = GlobalPicker.textLightColor
        label2.font = FontConfigManager.shared.getMediumFont(size: 12)
        label2.textAlignment = .right
        label2.textColor = UIColor.themeRed
        label2.lineBreakMode = .byCharWrapping
        baseViewBuy.addSubview(label2)
        
        fakeBuyButton.frame = baseViewBuy.frame
        fakeBuyButton.backgroundColor = UIColor.clear
        fakeBuyButton.setTitle("", for: .normal)
        fakeBuyButton.addTarget(self, action: #selector(pressedFakeBuyButton(_:)), for: UIControlEvents.touchUpInside)
        addSubview(fakeBuyButton)
        
        baseViewSell.frame = CGRect(x: baseViewBuy.frame.maxX+5, y: baseViewBuy.frame.minY, width: baseViewBuy.width, height: baseViewBuy.height)
        baseViewSell.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        addSubview(baseViewSell)
        
        label3 = UILabel(frame: CGRect(x: 10, y: 0, width: (baseViewBuy.width-30)*0.5, height: 33))
        label3.theme_textColor = GlobalPicker.textLightColor
        label3.font = FontConfigManager.shared.getMediumFont(size: 12)
        label3.textAlignment = .left
        baseViewSell.addSubview(label3)
        
        label4 = UILabel(frame: CGRect(x: 10 + label3.frame.maxX, y: 0, width: (baseViewBuy.width-30)*0.5, height: 33))
        label4.theme_textColor = GlobalPicker.textLightColor
        label4.font = FontConfigManager.shared.getMediumFont(size: 12)
        label4.textAlignment = .right
        label4.textColor = UIColor.themeGreen
        label4.lineBreakMode = .byClipping
        baseViewSell.addSubview(label4)
        
        fakeSellButton.frame = baseViewSell.frame
        fakeSellButton.backgroundColor = UIColor.clear
        fakeSellButton.setTitle("", for: .normal)
        fakeSellButton.addTarget(self, action: #selector(pressedFakeSellButton(_:)), for: UIControlEvents.touchUpInside)
        addSubview(fakeSellButton)
    }
    
    func update() {
        if let buyDepth = buyDepth {
            label1.text = buyDepth.amountA.toDecimalPlaces(2)
            label2.text = buyDepth.price.toDecimalPlaces(6)
        } else {
            label1.text = ""
            label2.text = ""
        }
        
        if let sellDepth = sellDepth {
            label3.text = sellDepth.amountA.toDecimalPlaces(2)
            label4.text = sellDepth.price.toDecimalPlaces(6)
        } else {
            label3.text = ""
            label4.text = ""
        }
    }

    @objc func pressedFakeBuyButton(_ sender: Any) {
        print("pressedFakeBuyButton")
        if buyDepth != nil {
            // TODO: What is the color when a button is highlighed?
            baseViewBuy.backgroundColor = UIColor.dark3
            delegate?.clickedMarketDetailDepthTableViewCell(amount: buyDepth!.amountA, price: buyDepth!.price)
            // delegate?.clickedMarketDetailDepthTableViewCell(amount: Double(buyDepth!.amountA) ?? 0, price: Double(buyDepth!.price) ?? 0)
        }
    }

    @objc func pressedFakeSellButton(_ sender: Any) {
        print("pressedFakeBuyButton")
        if sellDepth != nil {
            baseViewSell.backgroundColor = UIColor.dark3
            delegate?.clickedMarketDetailDepthTableViewCell(amount: sellDepth!.amountA, price: sellDepth!.price)
            // delegate?.clickedMarketDetailDepthTableViewCell(amount: Double(sellDepth!.amountA) ?? 0, price: Double(sellDepth!.price) ?? 0)
        }
    }
    
    class func getCellIdentifier() -> String {
        return "MarketDetailDepthTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 32
    }
}

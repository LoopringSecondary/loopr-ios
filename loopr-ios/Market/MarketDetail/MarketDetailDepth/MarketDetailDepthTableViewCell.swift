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
    func clickedMarketDetailDepthTableViewCell(amount: String, price: String, tradeType: TradeType)
    func tappedDepthInfoIcon()
}

class MarketDetailDepthTableViewCell: UITableViewCell {

    weak var delegate: MarketDetailDepthTableViewCellDelegate?
    
    var buyDepth: Depth?
    var sellDepth: Depth?
    var maxAmountInDepthView: Double = 0
    var minSellPrice: Double = 0
    
    var baseViewBuy: UIView = UIView()
    var baseViewSell: UIView = UIView()
    
    var depthViewBuy: UIView = UIView()
    var depthViewSell: UIView = UIView()

    var fakeBuyButton: UIButton = UIButton()
    var fakeSellButton: UIButton = UIButton()
    
    var label1: UILabel = UILabel()
    var label2: UILabel = UILabel()
    var label3: UILabel = UILabel()
    var label4: UILabel = UILabel()
    
    var depthInfoImageView: UIImageView = UIImageView()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        clipsToBounds = true
        selectionStyle = .none
        theme_backgroundColor = ColorPicker.backgroundColor
        
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        baseViewBuy.frame = CGRect(x: 15, y: 0, width: (screenWidth - 15*2 - 5)*0.5, height: 33+10)
        baseViewBuy.theme_backgroundColor = ColorPicker.cardBackgroundColor
        addSubview(baseViewBuy)
        
        depthViewBuy.frame = CGRect(x: 0, y: 0, width: 0, height: baseViewBuy.height)
        depthViewBuy.backgroundColor = UIColor.success.withAlphaComponent(0.1)
        baseViewBuy.addSubview(depthViewBuy)

        label1 = UILabel(frame: CGRect(x: 10, y: 0, width: (baseViewBuy.width-30)*0.5, height: 33))
        label1.textColor = UIColor.success
        label1.font = FontConfigManager.shared.getMediumFont(size: 12)
        label1.textAlignment = .left
        baseViewBuy.addSubview(label1)
        
        label2 = UILabel(frame: CGRect(x: 10 + label1.frame.maxX, y: 0, width: (baseViewBuy.width-30)*0.5, height: 33))
        label2.theme_textColor = GlobalPicker.textColor
        label2.font = FontConfigManager.shared.getMediumFont(size: 12)
        label2.textAlignment = .right
        label2.lineBreakMode = .byCharWrapping
        baseViewBuy.addSubview(label2)
        
        fakeBuyButton.frame = baseViewBuy.frame
        fakeBuyButton.backgroundColor = UIColor.clear
        fakeBuyButton.setTitle("", for: .normal)
        fakeBuyButton.addTarget(self, action: #selector(pressedFakeBuyButton(_:)), for: UIControlEvents.touchUpInside)
        addSubview(fakeBuyButton)
        
        // depthInfoImageView is on top of fakeBuyButton
        depthInfoImageView.image = UIImage(named: "Info-small")
        depthInfoImageView.contentMode = .center
        depthInfoImageView.frame = CGRect(x: 100, y: (33-30)*0.5, width: 30, height: 30)
        fakeBuyButton.addSubview(depthInfoImageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.delegate = self
        depthInfoImageView.isUserInteractionEnabled = true
        depthInfoImageView.addGestureRecognizer(tap)
        
        baseViewSell.frame = CGRect(x: baseViewBuy.frame.maxX+5, y: baseViewBuy.frame.minY, width: baseViewBuy.width, height: baseViewBuy.height)
        baseViewSell.theme_backgroundColor = ColorPicker.cardBackgroundColor
        addSubview(baseViewSell)
        
        depthViewSell.frame = CGRect(x: 0, y: 0, width: 0, height: baseViewBuy.height)
        depthViewSell.backgroundColor = UIColor.fail.withAlphaComponent(0.1)
        baseViewSell.addSubview(depthViewSell)
        
        label3 = UILabel(frame: CGRect(x: 10, y: 0, width: (baseViewBuy.width-30)*0.5, height: 33))
        label3.textColor = UIColor.fail
        label3.font = FontConfigManager.shared.getMediumFont(size: 12)
        label3.textAlignment = .left
        baseViewSell.addSubview(label3)
        
        label4 = UILabel(frame: CGRect(x: 10 + label3.frame.maxX, y: 0, width: (baseViewBuy.width-30)*0.5, height: 33))
        label4.theme_textColor = GlobalPicker.textColor
        label4.font = FontConfigManager.shared.getMediumFont(size: 12)
        label4.textAlignment = .right
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
            label1.text = buyDepth.price.toDecimalPlaces(6)
            label2.text = buyDepth.amountA.toDecimalPlaces(2).trailingZero()
            
            var percentage = (buyDepth.amountAInDouble)/(maxAmountInDepthView)
            if percentage > 1.0 {
                percentage = 1.0
            }
            depthViewBuy.frame = CGRect(x: baseViewBuy.width*CGFloat(1.0-percentage), y: 1, width: baseViewBuy.width*CGFloat(percentage), height: MarketDetailDepthTableViewCell.getHeight()-2)
            
            let currentBuyDepthPrice = Double(buyDepth.price) ?? 0
            if currentBuyDepthPrice > minSellPrice && minSellPrice > 0 {
                depthInfoImageView.x = (label1.text?.textWidth(font: label1.font))! + label1.x - 4
                depthInfoImageView.isHidden = false
            } else {
                depthInfoImageView.isHidden = true
            }
            
        } else {
            label1.text = ""
            label2.text = ""
            depthViewBuy.frame = CGRect.zero
            depthInfoImageView.isHidden = true
        }
        
        if let sellDepth = sellDepth {
            label3.text = sellDepth.price.toDecimalPlaces(6)
            label4.text = sellDepth.amountA.toDecimalPlaces(2).trailingZero()
            
            var percentage = (sellDepth.amountAInDouble)/(maxAmountInDepthView)
            if percentage > 1.0 {
                percentage = 1.0
            }
            depthViewSell.frame = CGRect(x: baseViewSell.width*CGFloat(1.0-percentage), y: 1, width: baseViewSell.width*CGFloat(percentage), height: MarketDetailDepthTableViewCell.getHeight()-2)
            
        } else {
            label3.text = ""
            label4.text = ""
            baseViewSell.frame = CGRect.zero
        }
    }

    @objc func pressedFakeBuyButton(_ sender: Any) {
        print("pressedFakeBuyButton")
        if buyDepth != nil {
            baseViewBuy.backgroundColor = UIColor.dark3
            UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveLinear, animations: {
                self.baseViewBuy.theme_backgroundColor = ColorPicker.cardBackgroundColor
            }, completion: { (_) in
                
            })
            delegate?.clickedMarketDetailDepthTableViewCell(amount: buyDepth!.amountA, price: buyDepth!.price)
            delegate?.clickedMarketDetailDepthTableViewCell(amount: buyDepth!.amountA, price: buyDepth!.price, tradeType: .buy)
        }
    }

    @objc func pressedFakeSellButton(_ sender: Any) {
        print("pressedFakeBuyButton")
        if sellDepth != nil {
            baseViewSell.backgroundColor = UIColor.dark3
            UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveLinear, animations: {
                self.baseViewSell.theme_backgroundColor = ColorPicker.cardBackgroundColor
            }, completion: { (_) in
                
            })
            delegate?.clickedMarketDetailDepthTableViewCell(amount: sellDepth!.amountA, price: sellDepth!.price)
            delegate?.clickedMarketDetailDepthTableViewCell(amount: sellDepth!.amountA, price: sellDepth!.price, tradeType: .sell)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        print("handleTap")
        delegate?.tappedDepthInfoIcon()
    }
    
    class func getCellIdentifier() -> String {
        return "MarketDetailDepthTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 32
    }
}

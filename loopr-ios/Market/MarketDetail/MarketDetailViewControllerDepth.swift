//
//  MarketDetailViewControllerDepth.swift
//  loopr-ios
//
//  Created by Ruby on 11/29/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

extension MarketDetailViewController {
    
    func getDepthFromRelay() {
        MarketDepthDataManager.shared.getDepthFromServer(market: market.name, completionHandler: { buys, sells, _ in
            self.preivousMarketName = self.market.name
            self.buys = buys
            self.sells = sells
            
            if buys.count > 0 && sells.count > 0 {
                self.maxAmountInDepthView = max(buys[buys.count / 2].amountAInDouble, sells[sells.count / 2].amountAInDouble) * 1.5
            } else if buys.count > 0 {
                self.maxAmountInDepthView = buys[buys.count / 2].amountAInDouble * 1.5
            } else if sells.count > 0 {
                self.maxAmountInDepthView = sells[sells.count / 2].amountAInDouble * 1.5
            } else {
                self.maxAmountInDepthView = 0
            }
            
            if sells.count > 0 {
                self.minSellPrice = Double(sells[0].price) ?? 0
            }
            
            DispatchQueue.main.async {
                /*
                if self.isLaunching == true {
                    self.isLaunching = false
                }
                 */
                self.tableView.reloadData()
            }
        })
    }
    
    func getNumberOfRowsInDepthSection() -> Int {
        let maxCount = buys.count > sells.count ? buys.count : sells.count
        if maxCount > 10 {
            return 10
        } else {
            return maxCount
        }
    }
    
    func getHeightForHeaderInSection() -> CGFloat {
        return 30 + 10 + 1
    }
    
    func getHeaderViewInDepthSection() -> UIView {
        let screenWidth = view.frame.size.width
        let labelWidth = (screenWidth - 15*2 - 5)*0.5
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30 + 10 + 1))
        headerView.theme_backgroundColor = ColorPicker.backgroundColor
        
        let baseViewBuy = UIView(frame: CGRect(x: 15, y: 10, width: (screenWidth - 15*2 - 5)*0.5, height: 30))
        baseViewBuy.theme_backgroundColor = ColorPicker.cardBackgroundColor
        baseViewBuy.round(corners: [.topLeft], radius: 6)
        headerView.addSubview(baseViewBuy)
        
        let label1 = UILabel(frame: CGRect(x: 10, y: 0, width: labelWidth, height: 30))
        label1.theme_textColor = GlobalPicker.textLightColor
        label1.font = FontConfigManager.shared.getMediumFont(size: 12)
        if SettingDataManager.shared.getCurrentLanguage().name == "zh-Hans" || SettingDataManager.shared.getCurrentLanguage().name  == "zh-Hant" {
            label1.text = "\(LocalizedString("Buy Price", comment: ""))(\(market.tradingPair.tradingB))"
        } else {
            label1.text = "\(LocalizedString("Buy Price", comment: ""))"
        }
        label1.textAlignment = .left
        baseViewBuy.addSubview(label1)
        
        let label2 = UILabel(frame: CGRect(x: 10, y: 0, width: labelWidth-20, height: 30))
        label2.theme_textColor = GlobalPicker.textLightColor
        label2.font = FontConfigManager.shared.getMediumFont(size: 12)
        label2.text = "\(LocalizedString("Amount", comment: ""))(\(market.tradingPair.tradingA))"
        label2.textAlignment = .right
        baseViewBuy.addSubview(label2)
        
        let baseViewSell = UIView(frame: CGRect(x: baseViewBuy.frame.maxX+5, y: baseViewBuy.frame.minY, width: baseViewBuy.width, height: baseViewBuy.height))
        baseViewSell.theme_backgroundColor = ColorPicker.cardBackgroundColor
        baseViewSell.round(corners: [.topRight], radius: 6)
        headerView.addSubview(baseViewSell)
        
        let label3 = UILabel(frame: CGRect(x: 10, y: 0, width: labelWidth, height: 30))
        label3.theme_textColor = GlobalPicker.textLightColor
        label3.font = FontConfigManager.shared.getMediumFont(size: 12)
        if SettingDataManager.shared.getCurrentLanguage().name == "zh-Hans" || SettingDataManager.shared.getCurrentLanguage().name  == "zh-Hant" {
            label3.text = "\(LocalizedString("Sell Price", comment: ""))(\(market.tradingPair.tradingB))"
        } else {
            label3.text = "\(LocalizedString("Sell Price", comment: ""))"
        }
        label3.textAlignment = .left
        baseViewSell.addSubview(label3)
        
        let label4 = UILabel(frame: CGRect(x: 10, y: 0, width: labelWidth-20, height: 30))
        label4.theme_textColor = GlobalPicker.textLightColor
        label4.font = FontConfigManager.shared.getMediumFont(size: 12)
        label4.text = "\(LocalizedString("Amount", comment: ""))(\(market.tradingPair.tradingA))"
        label4.textAlignment = .right
        baseViewSell.addSubview(label4)
        
        return headerView
    }
    
    func getMarketDetailDepthTableViewCell(cellForRowAt indexPath: IndexPath) -> MarketDetailDepthTableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: MarketDetailDepthTableViewCell.getCellIdentifier()) as? MarketDetailDepthTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("MarketDetailDepthTableViewCell", owner: self, options: nil)
            cell = nib![0] as? MarketDetailDepthTableViewCell
            cell?.maxAmountInDepthView = maxAmountInDepthView
            cell?.delegate = self
        }
        if indexPath.row < buys.count {
            cell?.buyDepth = buys[indexPath.row]
        }
        if indexPath.row < sells.count {
            cell?.sellDepth = sells[indexPath.row]
        }
        cell?.update()
        
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            cell?.baseViewBuy.round(corners: [.bottomLeft], radius: 6)
            cell?.baseViewSell.round(corners: [.bottomRight], radius: 6)
        } else {
            cell?.baseViewBuy.round(corners: [], radius: 0)
            cell?.baseViewSell.round(corners: [], radius: 0)
        }
        return cell!
    }
    
    func clickedMarketDetailDepthTableViewCell(amount: String, price: String) {
        
    }
    
    func clickedMarketDetailDepthTableViewCell(amount: String, price: String, tradeType: TradeType) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let viewController = BuyAndSellSwipeViewController()
            viewController.market = self.market
            viewController.initialType = tradeType
            viewController.initialPrice = price
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func tappedDepthInfoIcon() {
        // TODO: need improvement
        // Putting two tips in the message is too long.
        let alert = UIAlertController(title: LocalizedString("Order Depth Tips", comment: ""), message: LocalizedString("The depth maybe under matching: Miners may need some time to submit txs to ethereum.", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedString("OK", comment: ""), style: .default, handler: { _ in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }

}

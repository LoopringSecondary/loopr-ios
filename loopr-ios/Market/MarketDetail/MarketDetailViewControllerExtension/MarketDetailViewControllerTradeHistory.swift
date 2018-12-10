//
//  MarketDetailViewControllerTradeHistory.swift
//  loopr-ios
//
//  Created by Ruby on 11/29/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

extension MarketDetailViewController {
    
    func getTradeHistoryFromRelay() {
        MarketTradeHistoryDataManager.shared.getTradeHistoryFromServer(market: market.name, completionHandler: { (orderFills, _) in
            self.preivousMarketName = self.market.name
            self.orderFills = orderFills
            DispatchQueue.main.async {
                if self.isTradeHistoryLaunching == true {
                    self.isTradeHistoryLaunching = false
                }
                self.tableView.reloadData()
            }
        })
    }
    
    private func isTradeHistoryEmpty() -> Bool {
        return orderFills.count == 0 && !isTradeHistoryLaunching
    }
    
    func getNumberOfRowsInSectionTradeHistory() -> Int {
        guard !isTradeHistoryEmpty() else {
            return 1
        }
        return orderFills.count
    }
    
    func getHeightForRowAtSectionTradeHistory(indexPath: IndexPath) -> CGFloat {
        if isTradeHistoryEmpty() {
            return OrderNoDataTableViewCell.getHeight() - 200
        } else {
            if indexPath.row == tableView.numberOfRows(inSection: MarketDetailSection.depthAndTradeHistory.rawValue) - 1 {
                return MarketDetailTradeHistoryTableViewCell.getHeight() + 10
            } else {
                return MarketDetailTradeHistoryTableViewCell.getHeight()
            }
        }
    }
    
    func getHeightForHeaderInSectionTradeHistory() -> CGFloat {
        return 30 + 10 + 1
    }
    
    func getHeaderViewInSectionTradeHistory() -> UIView {
        let screenWidth = view.frame.size.width
        let labelWidth = (screenWidth - 15*2 - 5)*0.5
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30 + 10 + 1))
        headerView.theme_backgroundColor = ColorPicker.backgroundColor
        
        let baseViewBuy = UIView(frame: CGRect(x: 15, y: 10, width: (screenWidth - 15*2)*0.5, height: 30))
        baseViewBuy.theme_backgroundColor = ColorPicker.cardBackgroundColor
        baseViewBuy.round(corners: [.topLeft], radius: 6)
        headerView.addSubview(baseViewBuy)
        
        let label1 = UILabel(frame: CGRect(x: 10, y: 0, width: labelWidth, height: 30))
        label1.theme_textColor = GlobalPicker.textLightColor
        label1.font = FontConfigManager.shared.getMediumFont(size: 12)
        label1.text = LocalizedString("Price", comment: "")
        label1.textAlignment = .left
        baseViewBuy.addSubview(label1)
        
        let label2 = UILabel(frame: CGRect(x: 10, y: 0, width: labelWidth-20, height: 30))
        label2.theme_textColor = GlobalPicker.textLightColor
        label2.font = FontConfigManager.shared.getMediumFont(size: 12)
        label2.text = LocalizedString("Amount", comment: "")
        label2.textAlignment = .right
        baseViewBuy.addSubview(label2)
        
        let baseViewSell = UIView(frame: CGRect(x: baseViewBuy.frame.maxX, y: baseViewBuy.frame.minY, width: baseViewBuy.width, height: baseViewBuy.height))
        baseViewSell.theme_backgroundColor = ColorPicker.cardBackgroundColor
        baseViewSell.round(corners: [.topRight], radius: 6)
        headerView.addSubview(baseViewSell)
        
        let label3 = UILabel(frame: CGRect(x: 10, y: 0, width: baseViewSell.width*0.5-15, height: 30))
        label3.theme_textColor = GlobalPicker.textLightColor
        label3.font = FontConfigManager.shared.getMediumFont(size: 12)
        label3.text = LocalizedString("Fee", comment: "") + " (LRC)"
        label3.textAlignment = .right
        baseViewSell.addSubview(label3)
        
        let label4 = UILabel(frame: CGRect(x: 10, y: 0, width: labelWidth-20, height: 30))
        label4.theme_textColor = GlobalPicker.textLightColor
        label4.font = FontConfigManager.shared.getMediumFont(size: 12)
        label4.text = LocalizedString("Time", comment: "")
        label4.textAlignment = .right
        baseViewSell.addSubview(label4)
        
        return headerView
    }

    func getMarketDetailTradeHistoryTableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isTradeHistoryEmpty() {
            var cell = tableView.dequeueReusableCell(withIdentifier: OrderNoDataTableViewCell.getCellIdentifier()) as? OrderNoDataTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("OrderNoDataTableViewCell", owner: self, options: nil)
                cell = nib![0] as? OrderNoDataTableViewCell
            }
            cell?.noDataLabel.text = LocalizedString("No-data-transaction", comment: "")
            cell?.noDataImageView.image = UIImage(named: "No-data-transaction")
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: MarketDetailTradeHistoryTableViewCell.getCellIdentifier()) as? MarketDetailTradeHistoryTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("MarketDetailTradeHistoryTableViewCell", owner: self, options: nil)
                cell = nib![0] as? MarketDetailTradeHistoryTableViewCell
            }
            cell?.orderFill = orderFills[indexPath.row]
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
    }

}

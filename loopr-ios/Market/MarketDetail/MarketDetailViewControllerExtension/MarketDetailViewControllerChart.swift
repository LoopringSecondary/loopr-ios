//
//  MarketDetailViewControllerChart.swift
//  loopr-ios
//
//  Created by Ruby on 11/29/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

extension MarketDetailViewController {
    
    func getHeightForHeaderInSectionChart() -> CGFloat {
        return 80
    }
    
    func getMarketDetailPriceChartTableViewCell() -> MarketDetailPriceChartTableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: MarketDetailPriceChartTableViewCell.getCellIdentifier()) as? MarketDetailPriceChartTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("MarketDetailPriceChartTableViewCell", owner: self, options: nil)
            cell = nib![0] as? MarketDetailPriceChartTableViewCell
        }
        cell?.setup(trends: trends)
        return cell!
    }
}

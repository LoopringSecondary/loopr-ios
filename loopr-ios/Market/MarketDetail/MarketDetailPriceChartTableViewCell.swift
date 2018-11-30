//
//  MarketDetailPriceChartTableViewCell.swift
//  loopr-ios
//
//  Created by Ruby on 11/29/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Charts

class MarketDetailPriceChartTableViewCell: UITableViewCell {

    @IBOutlet weak var transactionBarChartView: BarChartView!
    
    var trends: [Trend] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        theme_backgroundColor = ColorPicker.backgroundColor
        
        transactionBarChartView.minOffset = 0
        transactionBarChartView.isUserInteractionEnabled = false
        transactionBarChartView.highlightFullBarEnabled = false
        transactionBarChartView.xAxis.enabled = false
        transactionBarChartView.drawValueAboveBarEnabled = false
        transactionBarChartView.leftAxis.enabled = false
        transactionBarChartView.rightAxis.enabled = false
        transactionBarChartView.legend.enabled = false
        
    }

    func setup(trends: [Trend]) {
        print("MarketDetailPriceChartTableViewCell")
        print(trends.count)
        self.trends = trends
        
        setData()
    }
    
    func setData() {
        var upVals: [BarChartDataEntry] = []
        var downVals: [BarChartDataEntry] = []
        
        trends = trends.filter { (trend) -> Bool in
            return trend.vol > 0
        }
        
        for (i, trend) in trends.enumerated() {
            let dataEntry = BarChartDataEntry(x: Double(i), y: trend.vol)
            if trend.open <= trend.close {
                upVals.append(dataEntry)
            } else {
                downVals.append(dataEntry)
            }
            
            if upVals.count + downVals.count > 30 {
                break
            }
        }

        let upDataSet: BarChartDataSet = BarChartDataSet(values: upVals, label: nil)
        upDataSet.setColor(UIColor.upInChart)
        let downDataSet: BarChartDataSet = BarChartDataSet(values: downVals, label: nil)
        downDataSet.setColor(UIColor.downInChart)
        
        let data = BarChartData(dataSet: upDataSet)
        data.addDataSet(downDataSet)
        data.barWidth = 0.9
        for set in data.dataSets {
            set.drawValuesEnabled = false
        }
        transactionBarChartView.data = data
    }
    
    class func getCellIdentifier() -> String {
        return "MarketDetailPriceChartTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 80
    }

}

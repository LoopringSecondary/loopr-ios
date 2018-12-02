//
//  MarketDetailPriceChartTableViewCell.swift
//  loopr-ios
//
//  Created by Ruby on 11/29/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Charts

protocol MarketDetailPriceChartTableViewCellDelegate: class {
    func trendIntervalUpdated(newTrendInterval: TrendInterval)
}

class MarketDetailPriceChartTableViewCell: UITableViewCell {

    weak var delegate: MarketDetailPriceChartTableViewCellDelegate?
    
    var rangeButtons: [UIButton] = []

    @IBOutlet weak var oneDayRangeButton: UIButton!
    @IBOutlet weak var oneMonthRangeButton: UIButton!
    @IBOutlet weak var oneYearRangeButton: UIButton!
    @IBOutlet weak var twoYearsRangeButton: UIButton!
    @IBOutlet weak var allRangeButton: UIButton!
    
    @IBOutlet weak var priceCandleStickChartViewTitle: UILabel!
    @IBOutlet weak var priceCandleStickChartView: CandleStickChartView!

    @IBOutlet weak var transactionBarChartViewTitle: UILabel!
    @IBOutlet weak var transactionBarChartView: BarChartView!
    
    // Empty bar doesn't look good. There is also an min step value in the bar.
    // So add a min value in bar and use a UIView to shorten the height.
    @IBOutlet weak var transactionBarChartViewBottomLine: UIView!
    
    // SeperateLines
    @IBOutlet weak var seperateLine0: UIView!
    @IBOutlet weak var seperateLine1: UIView!
    @IBOutlet weak var seperateLine2: UIView!
    @IBOutlet weak var seperateLine3: UIView!
    @IBOutlet weak var seperateLine4: UIView!
    
    let barCount: Int = 30
    
    // TODO: need to find params for the width in CandleStickChartView
    let barWidth: CGFloat = 0.8
    
    var trends: [Trend] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        theme_backgroundColor = ColorPicker.backgroundColor
        transactionBarChartViewBottomLine.theme_backgroundColor = ColorPicker.backgroundColor

        oneDayRangeButton.title = LocalizedString("1D", comment: "")
        oneMonthRangeButton.title = LocalizedString("1M", comment: "")
        oneYearRangeButton.title = LocalizedString("1Y", comment: "")
        twoYearsRangeButton.title = LocalizedString("2Y", comment: "")
        allRangeButton.title = LocalizedString("All", comment: "")

        rangeButtons = [oneDayRangeButton, oneMonthRangeButton, oneYearRangeButton, twoYearsRangeButton, allRangeButton]
        rangeButtons.forEach {
            $0.titleLabel?.font = FontConfigManager.shared.getRegularFont(size: 12)
            
            $0.setBackgroundColor(UIColor.theme, for: .selected)
            // $0.setBackgroundColor(UIColor.theme, for: .normal)
            $0.setBackgroundColor(UIColor.clear, for: .normal)

            $0.theme_setTitleColor(GlobalPicker.textColor, forState: .selected)
            $0.theme_setTitleColor(GlobalPicker.textLightColor, forState: .normal)
            $0.round(corners: .allCorners, radius: 6)
            $0.addTarget(self, action: #selector(pressedRangeButton), for: .touchUpInside)
        }
        
        // Selected range button
        oneDayRangeButton.isSelected = true

        seperateLine0.theme_backgroundColor = ColorPicker.cardHighLightColor
        seperateLine1.theme_backgroundColor = ColorPicker.cardHighLightColor
        seperateLine2.theme_backgroundColor = ColorPicker.cardHighLightColor
        seperateLine3.theme_backgroundColor = ColorPicker.cardHighLightColor
        seperateLine4.theme_backgroundColor = ColorPicker.cardHighLightColor

        // priceCandleStickChartViewTitle.isHidden = true
        // transactionBarChartViewTitle.isHidden = true
        
        priceCandleStickChartViewTitle.text = LocalizedString("Kline Chart", comment: "") + ": "
        priceCandleStickChartViewTitle.font = FontConfigManager.shared.getRegularFont(size: 12)
        priceCandleStickChartViewTitle.theme_textColor = GlobalPicker.textColor
        
        priceCandleStickChartView.minOffset = 0
        priceCandleStickChartView.isUserInteractionEnabled = false
        priceCandleStickChartView.xAxis.enabled = false
        priceCandleStickChartView.leftAxis.enabled = false
        priceCandleStickChartView.rightAxis.enabled = false
        priceCandleStickChartView.legend.enabled = false
        
        transactionBarChartViewTitle.text = LocalizedString("Volume", comment: "") + ": "
        transactionBarChartViewTitle.font = FontConfigManager.shared.getRegularFont(size: 12)
        transactionBarChartViewTitle.theme_textColor = GlobalPicker.textColor
        
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
        
        setDataForTransactionBarChartView()
        setDataForPriceCandleStickChartView()
    }
    
    func setDataForTransactionBarChartView() {
        var upVals: [BarChartDataEntry] = []
        var downVals: [BarChartDataEntry] = []

        for (i, trend) in trends.enumerated() {
            if upVals.count + downVals.count > barCount {
                break
            }

            var vol = trend.vol
            if trend.vol == 0 {
                vol = 0.001
            }
            let dataEntry = BarChartDataEntry(x: Double(i), y: vol)

            // align with decreasingColor in CandleStickChartView
            if trend.open >= trend.close {
                upVals.append(dataEntry)
            } else {
                downVals.append(dataEntry)
            }
        }

        let upDataSet: BarChartDataSet = BarChartDataSet(values: upVals, label: nil)
        upDataSet.setColor(UIColor.upInChart)
        
        let downDataSet: BarChartDataSet = BarChartDataSet(values: downVals, label: nil)
        downDataSet.setColor(UIColor.downInChart)
        
        let data = BarChartData(dataSet: upDataSet)
        data.addDataSet(downDataSet)
        data.barWidth = Double(barWidth)
        
        for set in data.dataSets {
            set.drawValuesEnabled = false
        }
        transactionBarChartView.data = data
    }
    
    func setDataForPriceCandleStickChartView() {
        var upVals: [CandleChartDataEntry] = []
        
        for (i, trend) in trends.enumerated() {
            if upVals.count > barCount {
                break
            }
            let dataEntry = CandleChartDataEntry(x: Double(i), shadowH: trend.high, shadowL: trend.low, open: trend.open, close: trend.close)
            upVals.append(dataEntry)
        }

        let set1 = CandleChartDataSet(values: upVals, label: "Data Set")
        set1.axisDependency = .left
        set1.setColor(UIColor(white: 80/255, alpha: 1))
        set1.drawIconsEnabled = false
        // set1.shadowColor = .darkGray
        set1.shadowColorSameAsCandle = true
        set1.shadowWidth = barWidth
        set1.decreasingColor = UIColor.upInChart
        set1.decreasingFilled = true
        set1.increasingColor = UIColor.downInChart
        set1.increasingFilled = true
        set1.neutralColor = UIColor.upInChart
        
        let data = CandleChartData(dataSet: set1)
        for set in data.dataSets {
            set.drawValuesEnabled = false
        }
        priceCandleStickChartView.data = data
    }
    
    @objc func pressedRangeButton(_ sender: UIButton) {
        let dict: [Int: TrendInterval] = [
            0: .oneHour,
            1: .oneDay,
            2: .oneWeek,
            3: .oneWeek,
            4: .oneWeek
        ]
        
        for (index, button) in rangeButtons.enumerated() {
            if button == sender {
                print(".....")
                delegate?.trendIntervalUpdated(newTrendInterval: dict[index]!)
            }
            button.isSelected = false
        }
        sender.isSelected = true
    }
    
    class func getCellIdentifier() -> String {
        return "MarketDetailPriceChartTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 285 + 20 + 10
    }

}

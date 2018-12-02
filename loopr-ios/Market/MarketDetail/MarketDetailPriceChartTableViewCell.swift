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
    func trendRangeUpdated(newTrendRange: TrendRange)
}

class MarketDetailPriceChartTableViewCell: UITableViewCell {

    weak var delegate: MarketDetailPriceChartTableViewCellDelegate?
    
    var rangeButtons: [UIButton] = []

    @IBOutlet weak var oneDayRangeButton: UIButton!
    @IBOutlet weak var oneWeekRangeButton: UIButton!
    @IBOutlet weak var oneMonthRangeButton: UIButton!
    @IBOutlet weak var threeMonthRangeButton: UIButton!
    @IBOutlet weak var oneYearRangeButton: UIButton!
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
        oneWeekRangeButton.title = LocalizedString("1W", comment: "")
        oneMonthRangeButton.title = LocalizedString("1M", comment: "")
        threeMonthRangeButton.title = LocalizedString("3M", comment: "")
        oneYearRangeButton.title = LocalizedString("1Y", comment: "")
        allRangeButton.title = LocalizedString("All", comment: "")

        rangeButtons = [oneDayRangeButton, oneWeekRangeButton, oneMonthRangeButton, threeMonthRangeButton, oneYearRangeButton, allRangeButton]
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
        oneMonthRangeButton.isSelected = true

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
        // priceCandleStickChartView.isUserInteractionEnabled = false
        priceCandleStickChartView.xAxis.enabled = false
        priceCandleStickChartView.leftAxis.enabled = false
        priceCandleStickChartView.rightAxis.enabled = false
        priceCandleStickChartView.legend.enabled = false
        priceCandleStickChartView.highlightPerDragEnabled = true
        priceCandleStickChartView.delegate = self
        
        transactionBarChartViewTitle.text = LocalizedString("Volume", comment: "") + ": "
        transactionBarChartViewTitle.font = FontConfigManager.shared.getRegularFont(size: 12)
        transactionBarChartViewTitle.theme_textColor = GlobalPicker.textColor
        
        transactionBarChartView.minOffset = 0
        // transactionBarChartView.isUserInteractionEnabled = false
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
        
        setDataForPriceCandleStickChartView()
        setDataForTransactionBarChartView()
    }
    
    func setDataForPriceCandleStickChartView() {
        var upVals: [CandleChartDataEntry] = []
        
        for (i, trend) in trends.enumerated() {
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
        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.drawVerticalHighlightIndicatorEnabled = true
        set1.highlightColor = UIColor.blue
        
        let data = CandleChartData(dataSet: set1)
        for set in data.dataSets {
            set.drawValuesEnabled = false
        }
        priceCandleStickChartView.data = data
    }

    func setDataForTransactionBarChartView() {
        var upVals: [BarChartDataEntry] = []
        var downVals: [BarChartDataEntry] = []

        // If all trends don't have any volume, hide the bar chart.
        let trendsWithNoVol = trends.filter { $0.vol > 0 }
        if trendsWithNoVol.count == 0 {
            transactionBarChartView.isHidden = true
            return
        } else {
            transactionBarChartView.isHidden = false
        }
        
        for (i, trend) in trends.enumerated() {
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
    
    @objc func pressedRangeButton(_ sender: UIButton) {
        let dict: [Int: TrendRange] = [
            0: .oneDay,
            1: .oneWeek,
            2: .oneMonth,
            3: .threeMonths,
            4: .oneYear,
            5: .all
        ]
        
        for (index, button) in rangeButtons.enumerated() {
            if button == sender {
                print(".....")
                delegate?.trendRangeUpdated(newTrendRange: dict[index]!)
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

extension MarketDetailPriceChartTableViewCell: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("chartValueSelected")
    }

}

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
    func trendDidHighlight(trend: Trend?)
}

class MarketDetailPriceChartTableViewCell: UITableViewCell {

    weak var delegate: MarketDetailPriceChartTableViewCellDelegate?
    
    var rangeButtons: [UIButton] = []
    var selectedRangeButtonIndex: Int = 2

    @IBOutlet weak var oneDayRangeButton: UIButton!
    @IBOutlet weak var oneWeekRangeButton: UIButton!
    @IBOutlet weak var oneMonthRangeButton: UIButton!
    @IBOutlet weak var threeMonthRangeButton: UIButton!
    @IBOutlet weak var oneYearRangeButton: UIButton!
    @IBOutlet weak var allRangeButton: UIButton!
    
    @IBOutlet weak var priceCandleStickChartViewTitle: UILabel!
    @IBOutlet weak var priceCandleStickChartView: CandleStickChartView!

    // Use CandleStickChartView, rather than BarChartView for a consistent UI.
    @IBOutlet weak var transactionBarChartViewTitle: UILabel!
    @IBOutlet weak var transactionBarChartView: CandleStickChartView!
    
    // SeperateLines
    @IBOutlet weak var seperateLine0: UIView!
    @IBOutlet weak var seperateLine1: UIView!
    @IBOutlet weak var seperateLine2: UIView!
    @IBOutlet weak var seperateLine3: UIView!
    @IBOutlet weak var seperateLine4: UIView!
    
    // TODO: need to find params for the width in CandleStickChartView
    let barWidth: CGFloat = 0.8
    
    var trends: [Trend] = []
    
    var hightlightLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        theme_backgroundColor = ColorPicker.backgroundColor

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
        priceCandleStickChartView.xAxis.enabled = false
        priceCandleStickChartView.leftAxis.enabled = false
        priceCandleStickChartView.rightAxis.enabled = false
        priceCandleStickChartView.legend.enabled = false
        priceCandleStickChartView.highlightPerDragEnabled = true
        priceCandleStickChartView.doubleTapToZoomEnabled = false
        priceCandleStickChartView.delegate = self
        
        transactionBarChartViewTitle.text = LocalizedString("Volume", comment: "") + ": "
        transactionBarChartViewTitle.font = FontConfigManager.shared.getRegularFont(size: 12)
        transactionBarChartViewTitle.theme_textColor = GlobalPicker.textColor
        
        transactionBarChartView.minOffset = 0
        transactionBarChartView.xAxis.enabled = false
        transactionBarChartView.leftAxis.enabled = false
        transactionBarChartView.rightAxis.enabled = false
        transactionBarChartView.legend.enabled = false
        transactionBarChartView.highlightPerDragEnabled = true
        transactionBarChartView.doubleTapToZoomEnabled = false
        transactionBarChartView.delegate = self
        
        hightlightLabel.text = LocalizedString("", comment: "") + ": "
        hightlightLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        hightlightLabel.theme_textColor = GlobalPicker.textColor
        hightlightLabel.textAlignment = .center
        addSubview(hightlightLabel)
        hightlightLabel.isHidden = true
    }

    func setup(trends: [Trend]) {
        print("MarketDetailPriceChartTableViewCell")
        print(trends.count)
        self.trends = trends
        
        setDataForPriceCandleStickChartView()
        setDataForTransactionBarChartView()
        
        clearHighlight()
    }
    
    func GenerateCandleChartDataSet(values: [CandleChartDataEntry]) -> CandleChartDataSet {
        let set = CandleChartDataSet(values: values, label: nil)
        set.axisDependency = .left
        set.setColor(UIColor(white: 80/255, alpha: 1))
        set.drawIconsEnabled = false
        // set1.shadowColor = .darkGray
        set.shadowColorSameAsCandle = true
        set.shadowWidth = barWidth
        set.decreasingColor = UIColor.downInChart
        set.decreasingFilled = true
        set.increasingColor = UIColor.upInChart
        set.increasingFilled = true
        set.neutralColor = UIColor.upInChart
        set.drawHorizontalHighlightIndicatorEnabled = false
        set.drawVerticalHighlightIndicatorEnabled = true
        set.highlightColor = UIColor.theme
        set.highlightLineWidth = 1
        
        return set
    }
    
    func setDataForPriceCandleStickChartView() {
        var upVals: [CandleChartDataEntry] = []
        
        for (i, trend) in trends.enumerated() {
            let dataEntry = CandleChartDataEntry(x: Double(i), shadowH: trend.high, shadowL: trend.low, open: trend.open, close: trend.close)
            upVals.append(dataEntry)
        }
        
        let set = GenerateCandleChartDataSet(values: upVals)
        let data = CandleChartData(dataSet: set)
        for set in data.dataSets {
            set.drawValuesEnabled = false
        }
        priceCandleStickChartView.data = data
    }

    func setDataForTransactionBarChartView() {
        var upVals: [CandleChartDataEntry] = []

        // If all trends don't have any volume, hide the bar chart.
        let trendsWithNoVol = trends.filter { $0.vol > 0 }
        if trendsWithNoVol.count == 0 {
            // transactionBarChartView.isHidden = true
            // return
        } else {
            // transactionBarChartView.isHidden = false
        }
        
        for (i, trend) in trends.enumerated() {
            let dataEntry: CandleChartDataEntry
            if trend.vol == 0 {
                dataEntry = CandleChartDataEntry(x: Double(i), shadowH: 0, shadowL: 0, open: 0, close: 0)
            } else if trend.change > 0 {
                dataEntry = CandleChartDataEntry(x: Double(i), shadowH: 0, shadowL: trend.vol, open: 0, close: trend.vol)
            } else {
                dataEntry = CandleChartDataEntry(x: Double(i), shadowH: trend.vol, shadowL: 0, open: trend.vol, close: 0)
            }
            upVals.append(dataEntry)
        }
        
        let upDataSet = GenerateCandleChartDataSet(values: upVals)
        
        let data = CandleChartData(dataSet: upDataSet)
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
                delegate?.trendRangeUpdated(newTrendRange: dict[index]!)
                clearHighlight()

                // Need to hide label.
                selectedRangeButtonIndex = index
                if index == 4 || index == 5 {
                    transactionBarChartViewTitle.isHidden = true
                } else {
                    transactionBarChartViewTitle.isHidden = false
                }
            }
            button.isSelected = false
        }
        sender.isSelected = true
    }
    
    func updateHighlightLabel(trend: Trend, highlight: Highlight) {
        let chartWidth = priceCandleStickChartView.width
        let barWidth = chartWidth/CGFloat(trends.count)

        hightlightLabel.text = trend.getTimeRangeString()
        
        // Adjust the frame for edge cases.
        let textWidth = hightlightLabel.text!.widthOfString(usingFont: hightlightLabel.font)
        var labelX: CGFloat = priceCandleStickChartView.x+barWidth*0.5+barWidth*CGFloat(highlight.x)-textWidth*0.5
        if labelX < priceCandleStickChartView.x {
            labelX = priceCandleStickChartView.x
        } else if labelX + textWidth > UIScreen.main.bounds.width - priceCandleStickChartView.x {
            labelX = UIScreen.main.bounds.width - textWidth - priceCandleStickChartView.x
        }
        hightlightLabel.frame = CGRect(x: labelX, y: 10, width: textWidth, height: 20)

        hightlightLabel.isHidden = false
    }
    
    func clearHighlight() {
        priceCandleStickChartViewTitle.isHidden = false
        if selectedRangeButtonIndex == 4 || selectedRangeButtonIndex == 5 {
            transactionBarChartViewTitle.isHidden = true
        } else {
            transactionBarChartViewTitle.isHidden = false
        }
        
        hightlightLabel.text = ""
        hightlightLabel.isHidden = true
        
        priceCandleStickChartView.highlightValues([])
        transactionBarChartView.highlightValues([])
        
        delegate?.trendDidHighlight(trend: nil)
    }
    
    class func getCellIdentifier() -> String {
        return "MarketDetailPriceChartTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 295
    }

}

extension MarketDetailPriceChartTableViewCell: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        priceCandleStickChartViewTitle.isHidden = true
        transactionBarChartViewTitle.isHidden = true
        
        priceCandleStickChartView.highlightValue(x: highlight.x, dataSetIndex: highlight.dataSetIndex, callDelegate: false)
        transactionBarChartView.highlightValue(x: highlight.x, dataSetIndex: highlight.dataSetIndex, callDelegate: false)
        
        let trend = trends[Int(highlight.x)]
        delegate?.trendDidHighlight(trend: trend)
        
        updateHighlightLabel(trend: trend, highlight: highlight)
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        clearHighlight()
    }

}

//
//  MarketLineChartTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/12/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Charts

class MarketLineChartTableViewCell: UITableViewCell {

    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    
    @IBOutlet weak var oneDayButton: CustomUIButtonForUIToolbar!
    @IBOutlet weak var oneWeekButton: CustomUIButtonForUIToolbar!
    @IBOutlet weak var oneMonthButton: CustomUIButtonForUIToolbar!
    @IBOutlet weak var threeMonthButton: CustomUIButtonForUIToolbar!
    @IBOutlet weak var oneYearButton: CustomUIButtonForUIToolbar!
    @IBOutlet weak var fiveYearButton: CustomUIButtonForUIToolbar!
    
    var pressedBuyButtonClosure: (() -> Void)?
    var pressedSellButtonClosure: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        theme_backgroundColor = ["#fff", "#000"]
        
        drawLineChartView()
        
        oneDayButton.selected()
        oneWeekButton.unselected()
        oneMonthButton.unselected()
        threeMonthButton.unselected()
        oneYearButton.unselected()
        fiveYearButton.unselected()
        
        // Sell button
        sellButton.setTitle(NSLocalizedString("Sell", comment: ""), for: .normal)
        sellButton.theme_backgroundColor = ["#000", "#fff"]
        sellButton.theme_setTitleColor(["#fff", "#000"], forState: .normal)

        sellButton.backgroundColor = UIColor.clear
        sellButton.titleColor = UIColor.black
        sellButton.layer.cornerRadius = 23
        sellButton.layer.borderWidth = 0.5
        sellButton.layer.borderColor = UIColor.black.cgColor
        sellButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        
        // Buy button
        buyButton.setTitle(NSLocalizedString("Buy", comment: ""), for: .normal)
        buyButton.theme_backgroundColor = ["#000", "#fff"]
        buyButton.theme_setTitleColor(["#fff", "#000"], forState: .normal)

        buyButton.backgroundColor = UIColor.black
        buyButton.layer.cornerRadius = 23
        buyButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func drawLineChartView() {
        lineChartView.chartDescription?.enabled = false
        lineChartView.dragEnabled = true
        lineChartView.setScaleEnabled(false)
        lineChartView.pinchZoomEnabled = false
        lineChartView.drawGridBackgroundEnabled = false
        
        // x-axis limit line
        let llXAxis = ChartLimitLine(limit: 10, label: "Index 10")
        llXAxis.lineWidth = 4
        llXAxis.lineDashLengths = [10, 10, 0]
        llXAxis.labelPosition = .rightBottom
        llXAxis.valueFont = .systemFont(ofSize: 10)
        
        lineChartView.xAxis.gridLineDashLengths = [10, 10]
        lineChartView.xAxis.gridLineDashPhase = 0
        
        /*
         let ll1 = ChartLimitLine(limit: 20, label: "Upper Limit")
         ll1.lineWidth = 4
         // ll1.lineDashLengths = [5, 5]
         ll1.labelPosition = .rightTop
         ll1.valueFont = .systemFont(ofSize: 10)
         */
        
        let leftAxis = lineChartView.leftAxis
        leftAxis.removeAllLimitLines()
        // leftAxis.addLimitLine(ll1)
        leftAxis.axisMaximum = 45
        leftAxis.axisMinimum = 15
        // leftAxis.gridLineDashLengths = [5, 5]
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
        lineChartView.rightAxis.enabled = false
        
        //[_chartView.viewPortHandler setMaximumScaleY: 2.f];
        //[_chartView.viewPortHandler setMaximumScaleX: 2.f];
        
        lineChartView.legend.enabled = false // .form = .line
        
        // lineChartView.animate(xAxisDuration: 2.5)
        
        setDataCount(30, range: 10)
        
        for set in lineChartView.data!.dataSets as! [LineChartDataSet] {
            set.mode = (set.mode == .cubicBezier) ? .horizontalBezier : .cubicBezier
        }
        lineChartView.setNeedsDisplay()
    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        let values = (0..<count).map { (i) -> ChartDataEntry in
            let val = Double(arc4random_uniform(range) + 20) + Double(i) * 0.3
            return ChartDataEntry(x: Double(i), y: val)
        }
        
        let set1 = LineChartDataSet(values: values, label: "")
        set1.drawIconsEnabled = false
        
        // set1.lineDashLengths = [5, 2.5]
        set1.highlightLineDashLengths = [5, 2.5]
        set1.setColor(UIColor(red: 34/255, green: 53/255, blue: 89/255, alpha: 1))
        // set1.setCircleColor(.black)
        set1.lineWidth = 1
        set1.circleRadius = 0
        set1.drawCircleHoleEnabled = false
        set1.valueFont = .systemFont(ofSize: 0)
        set1.formLineDashLengths = [5, 2.5]
        set1.formLineWidth = 1
        set1.formSize = 15
        set1.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        
        let gradientColors = [ChartColorTemplates.colorFromString("#005685df").cgColor,
                              ChartColorTemplates.colorFromString("#ff080d16").cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        
        set1.fillAlpha = 1
        set1.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
        set1.fillColor = UIStyleConfig.lineChartFillColor // UIColor(red: 115/255, green: 127/255, blue: 150/255, alpha: 1)
        
        // Enable the filled.
        set1.drawFilledEnabled = true
        
        let data = LineChartData(dataSet: set1)
        
        lineChartView.data = data
        lineChartView.xAxis.enabled = false
        lineChartView.leftAxis.enabled = false
    }
    
    @IBAction func pressedOneDayButton(_ sender: Any) {
        oneDayButton.selected()
        oneWeekButton.unselected()
        oneMonthButton.unselected()
        threeMonthButton.unselected()
        oneYearButton.unselected()
        fiveYearButton.unselected()
    }
    
    @IBAction func pressedOneWeekButton(_ sender: Any) {
        oneDayButton.unselected()
        oneWeekButton.selected()
        oneMonthButton.unselected()
        threeMonthButton.unselected()
        oneYearButton.unselected()
        fiveYearButton.unselected()
    }
    
    @IBAction func pressedOneMonthButton(_ sender: Any) {
        oneDayButton.unselected()
        oneWeekButton.unselected()
        oneMonthButton.selected()
        threeMonthButton.unselected()
        oneYearButton.unselected()
        fiveYearButton.unselected()
    }
    
    @IBAction func pressedThreeMonthButton(_ sender: Any) {
        oneDayButton.unselected()
        oneWeekButton.unselected()
        oneMonthButton.unselected()
        threeMonthButton.selected()
        oneYearButton.unselected()
        fiveYearButton.unselected()
    }
    
    @IBAction func pressedOneYearButton(_ sender: Any) {
        oneDayButton.unselected()
        oneWeekButton.unselected()
        oneMonthButton.unselected()
        threeMonthButton.unselected()
        oneYearButton.selected()
        fiveYearButton.unselected()
    }
    
    @IBAction func pressedFiveYearButton(_ sender: Any) {
        oneDayButton.unselected()
        oneWeekButton.unselected()
        oneMonthButton.unselected()
        threeMonthButton.unselected()
        oneYearButton.unselected()
        fiveYearButton.selected()
    }
    
    @IBAction func pressedSellButton(_ sender: Any) {
        print("pressedBuyButton")
        if let btnAction = self.pressedSellButtonClosure {
            btnAction()
        }
    }
    
    @IBAction func pressedBuyButton(_ sender: Any) {
        if let btnAction = self.pressedBuyButtonClosure {
            btnAction()
        }
    }
    
    class func getCellIdentifier() -> String {
        return "MarketLineChartTableViewCell"
    }
    
    class func getHeight(navigationBarHeight: CGFloat = 0) -> CGFloat {
        let screen = UIScreen.main.bounds
        let screenHeight = screen.height
        return screenHeight - navigationBarHeight
    }
}

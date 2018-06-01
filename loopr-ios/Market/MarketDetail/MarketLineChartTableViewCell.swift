//
//  MarketLineChartTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/12/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Charts

class MarketLineChartTableViewCell: UITableViewCell, ChartViewDelegate {

    var market: Market?
    var trends: [Trend]?
    var interval: String = "1Hr"
    var dateFormat: String = "HH:mm"
    var lowLimit: Double = Double(Int.max)
    var highLimit: Double = Double(Int.min)
    
    var mockData: [ChartDataEntry] = []
    let count: Int = 20
    
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var balanceLabel: TickerLabel!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var trendLabel: UILabel!
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    
    @IBOutlet weak var oneHourButton: CustomUIButtonForUIToolbar!
    @IBOutlet weak var twoHourButton: CustomUIButtonForUIToolbar!
    @IBOutlet weak var fourHourButton: CustomUIButtonForUIToolbar!
    @IBOutlet weak var oneDayButton: CustomUIButtonForUIToolbar!
    @IBOutlet weak var oneWeekButton: CustomUIButtonForUIToolbar!

    var pressedBuyButtonClosure: (() -> Void)?
    var pressedSellButtonClosure: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lineChartView.delegate = self
        theme_backgroundColor = GlobalPicker.backgroundColor
        
        // Label config
        tokenLabel.font = FontConfigManager.shared.getLabelFont()
        tokenLabel.text = "WETH "
        
        balanceLabel.setFont(FontConfigManager.shared.getRegularFont(size: (27)))
        balanceLabel.animationDuration = 0.25
        balanceLabel.textAlignment = NSTextAlignment.center
        balanceLabel.initializeLabel()
        balanceLabel.theme_backgroundColor = GlobalPicker.backgroundColor
        balanceLabel.setText("23.0", animated: true)
        
        displayLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 15)
        displayLabel.text = "$11280.58"
        
        trendLabel.font = FontConfigManager.shared.getRegularFont(size: 15)
        trendLabel.textColor = UIColor.green
        trendLabel.text = "+ 0.000041 (+ 0.37%)"
        
        // line chart config
        refreshTrendMock()
        
        // interval buttons group
        oneHourButton.selected()
        
        // Sell button
        sellButton.setTitle(NSLocalizedString("Sell", comment: ""), for: .normal)
        sellButton.setupRoundWhite()
        
        // Buy button
        buyButton.setTitle(NSLocalizedString("Buy", comment: ""), for: .normal)
        buyButton.setupRoundBlack()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func refreshTrend() {
        if let trends = self.trends {
            for trend in trends {
                if self.highLimit < trend.high {
                    self.highLimit = trend.high
                }
                if self.lowLimit > trend.low {
                    self.lowLimit = trend.low
                }
            }
            switch self.interval {
            case "1H", "2H", "4H":
                self.dateFormat = "HH:mm"
            case "1D", "1W":
                self.dateFormat = "dd MMM"
            default:
                self.dateFormat = "HH:mm"
            }
            self.drawLineChartView()
        }
    }
    
    func refreshTrendMock() {
        var inter: Int
        switch self.interval {
        case "1H":
            inter = 1
            self.dateFormat = "HH:mm"
        case "2H":
            inter = 2
            self.dateFormat = "HH:mm"
        case "4H":
            inter = 4
            self.dateFormat = "HH:mm"
        case "1D":
            inter = 24
            self.dateFormat = "dd MMM"
        case "1W":
            inter = 7 * 24
            self.dateFormat = "dd MMM"
        default:
            inter = 1
            self.dateFormat = "HH:mm"
        }
        let now = Date().timeIntervalSince1970
        let hourSeconds: TimeInterval = TimeInterval(3600 * inter)
        let from = now - (Double(count) / 2) * hourSeconds
        let to = now + (Double(count) / 2) * hourSeconds
        
        mockData = stride(from: from, to: to, by: hourSeconds).map { (x) -> ChartDataEntry in
            let y = arc4random_uniform(10) + 20
            return ChartDataEntry(x: x, y: Double(y))
        }
        self.drawLineChartView()
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        balanceLabel.setText("23.0", animated: true)
        displayLabel.text = "$11280.58"
        trendLabel.textColor = UIColor.green
        trendLabel.text = "+ 0.000041 (+ 0.37%)"
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        // TODO: below not working !!!
//        let point = chartView.getMarkerPosition(highlight: highlight)
//        let circlePath = UIBezierPath(arcCenter: CGPoint(x: point.x, y: point.y), radius: CGFloat(2), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
//
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = circlePath.cgPath
//
//        //change the fill color
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        //you can change the stroke color
//        shapeLayer.strokeColor = UIColor.red.cgColor
//        //you can change the line width
//        shapeLayer.lineWidth = 3.0
//
//        lineChartView.layer.addSublayer(shapeLayer)
//        lineChartView.highlightValue(highlight)
        balanceLabel.setText(entry.y.description, animated: true)
        displayLabel.text = "$ " + (entry.y * 490.46).description
        trendLabel.textColor = UIColor.black
        trendLabel.text = DateUtil.convertToDate(UInt(entry.x), format: "dd/MM/yyyy HH:mm")
        layoutIfNeeded()
    }
    
    func drawLineChartView() {
        lineChartView.chartDescription?.enabled = false
        lineChartView.dragEnabled = true
        lineChartView.setScaleEnabled(true)
        lineChartView.pinchZoomEnabled = true
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.xAxis.enabled = false
        lineChartView.leftAxis.enabled = false
        
        lineChartView.rightAxis.enabled = false
        lineChartView.viewPortHandler.setMaximumScaleY(2)
        lineChartView.viewPortHandler.setMaximumScaleX(2)

        lineChartView.legend.enabled = false
        lineChartView.animate(yAxisDuration: 1.5)
        
        setDataCount(trends?.count ?? 0) // mock
        
        for set in lineChartView.data!.dataSets as! [LineChartDataSet] {
            set.mode = .linear
        }
        lineChartView.setNeedsDisplay()
    }
    
    func setDataCount(_ count: Int) {
//        let values = trends?.map({ (trend) -> ChartDataEntry in
//            let x = trend.start
//            let y = trend.close
//            return ChartDataEntry(x: Double(x), y: y)
//        })
        let set1 = LineChartDataSet(values: mockData, label: "")
        set1.drawIconsEnabled = false
        set1.lineWidth = 0.5
        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.setColor(UIColor(red: 22/255, green: 22/255, blue: 22/255, alpha: 1))
        set1.highlightColor = UIColor(red: 117/255, green: 117/255, blue: 117/255, alpha: 1)
        set1.setCircleColor(UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1))
        set1.drawCirclesEnabled = true
        set1.circleHoleColor = UIColor.black
        set1.drawCircleHoleEnabled = true
        set1.valueFont = .systemFont(ofSize: 0)
        
        let gradientColors = [ChartColorTemplates.colorFromString("#00ffffff").cgColor,
                              ChartColorTemplates.colorFromString("#ffe0e0e0").cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        set1.fillAlpha = 1
        set1.fill = Fill(linearGradient: gradient, angle: 90)
        // Enable the filled.
        set1.drawFilledEnabled = true
        let data = LineChartData(dataSet: set1)
        lineChartView.data = data
    }

    @IBAction func pressedIntervalButtons(_ sender: CustomUIButtonForUIToolbar) {
        let buttonArray = [oneHourButton, twoHourButton, fourHourButton, oneDayButton, oneWeekButton]
        buttonArray.forEach {
            $0?.unselected()
        }
        sender.selected()
        interval = sender.title!
        refreshTrendMock()
    }

    @IBAction func pressedSellButton(_ sender: Any) {
        print("pressedSellButton")
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

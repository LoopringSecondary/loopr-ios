//
//  PortfolioViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 1/31/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Charts

class PortfolioViewController: UIViewController {
    
    @IBOutlet weak var portfolioChartView: PieChartView!
    
    // Mock data
    let parties = ["Bitcoin", "Ethereum", "Loopring", "Ripple",
                   "Bitcoin Cash", "Litecoin"]
    let colors = [UIColor(red: 255/255, green: 153/255, blue: 0/255, alpha: 1),
                  UIColor(red: 132/255, green: 200/255, blue: 242/255, alpha: 1),
                  UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1),
                  UIColor(red: 49/255, green: 163/255, blue: 217/255, alpha: 1),
                  UIColor(red: 21/255, green: 152/255, blue: 57/255, alpha: 1),
                  UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1)]
    let values: [Double] = [25, 23, 18, 15, 10, 10]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.topItem?.title = "Portfolio"
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadData() {
        let count = 6
        let entries = (0..<count).map { (i) -> PieChartDataEntry in
            // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
            return PieChartDataEntry(value: values[i],
                                     label: parties[i % parties.count])
        }
        
        let set = PieChartDataSet(values: entries, label: "")
        set.drawIconsEnabled = false
        set.sliceSpace = 2
        
        set.colors = colors
        
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        data.setValueFont(.systemFont(ofSize: 11, weight: .light))
        data.setValueTextColor(.white)
        
        portfolioChartView.data = data
        portfolioChartView.highlightValues(nil)
        
        portfolioChartView.chartDescription?.text = ""
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

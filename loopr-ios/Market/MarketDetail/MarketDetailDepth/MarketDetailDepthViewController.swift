//
//  MarketDetailDepthViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 7/28/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MarketDetailDepthViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
        
    var market: Market!
    var isLaunching: Bool = true
    private var buys: [Depth] = []
    private var sells: [Depth] = []

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.theme_backgroundColor = GlobalPicker.backgroundColor
        
        getDataFromRelay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getDataFromRelay() {
        MarketDepthDataManager.shared.getDepthFromServer(market: market.name, completionHandler: { buys, sells, _ in
            self.buys = buys
            self.sells = sells
            DispatchQueue.main.async {
                if self.isLaunching == true {
                    self.isLaunching = false
                }
                self.tableView.reloadData()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30 + 10 + 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let screenWidth = view.frame.size.width
        let labelWidth = (screenWidth - 15*2 - 5)*0.5
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30 + 10 + 1))
        headerView.theme_backgroundColor = GlobalPicker.backgroundColor
        
        let baseViewBuy = UIView(frame: CGRect(x: 15, y: 10, width: (screenWidth - 15*2 - 5)*0.5, height: 30))
        baseViewBuy.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        baseViewBuy.round(corners: [.topLeft], radius: 6)
        headerView.addSubview(baseViewBuy)
        
        let label1 = UILabel(frame: CGRect(x: 10, y: 0, width: labelWidth, height: 30))
        label1.theme_textColor = GlobalPicker.textLightColor
        label1.font = FontConfigManager.shared.getMediumFont(size: 14)
        label1.text = LocalizedString("Buy", comment: "")
        label1.textAlignment = .left
        baseViewBuy.addSubview(label1)

        let label2 = UILabel(frame: CGRect(x: 10, y: 0, width: labelWidth-20, height: 30))
        label2.theme_textColor = GlobalPicker.textLightColor
        label2.font = FontConfigManager.shared.getMediumFont(size: 14)
        label2.text = LocalizedString("Amount", comment: "")
        label2.textAlignment = .right
        baseViewBuy.addSubview(label2)
        
        let baseViewSell = UIView(frame: CGRect(x: baseViewBuy.frame.maxX+5, y: baseViewBuy.frame.minY, width: baseViewBuy.width, height: baseViewBuy.height))
        baseViewSell.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        baseViewSell.round(corners: [.topRight], radius: 6)
        headerView.addSubview(baseViewSell)
        
        let label3 = UILabel(frame: CGRect(x: 10, y: 0, width: labelWidth, height: 30))
        label3.theme_textColor = GlobalPicker.textLightColor
        label3.font = FontConfigManager.shared.getMediumFont(size: 14)
        label3.text = LocalizedString("Sell", comment: "")
        label3.textAlignment = .left
        baseViewSell.addSubview(label3)
        
        let label4 = UILabel(frame: CGRect(x: 10, y: 0, width: labelWidth-20, height: 30))
        label4.theme_textColor = GlobalPicker.textLightColor
        label4.font = FontConfigManager.shared.getMediumFont(size: 14)
        label4.text = LocalizedString("Amount", comment: "")
        label4.textAlignment = .right
        baseViewSell.addSubview(label4)
        
        return headerView
    }
    
    func isTableEmpty() -> Bool {
        return buys.count == 0 && sells.count == 0 && !isLaunching
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isTableEmpty() ? 1 : max(buys.count, sells.count)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isTableEmpty() {
            return OrderNoDataTableViewCell.getHeight() - 200
        } else {
            if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                return MarketDetailDepthTableViewCell.getHeight() + 10
            } else {
                return MarketDetailDepthTableViewCell.getHeight()
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isTableEmpty() {
            var cell = tableView.dequeueReusableCell(withIdentifier: OrderNoDataTableViewCell.getCellIdentifier()) as? OrderNoDataTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("OrderNoDataTableViewCell", owner: self, options: nil)
                cell = nib![0] as? OrderNoDataTableViewCell
            }
            cell?.noDataLabel.text = LocalizedString("No_Data_Tip", comment: "")
            cell?.noDataImageView.image = #imageLiteral(resourceName: "No-data-orderbook")
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: MarketDetailDepthTableViewCell.getCellIdentifier()) as? MarketDetailDepthTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("MarketDetailDepthTableViewCell", owner: self, options: nil)
                cell = nib![0] as? MarketDetailDepthTableViewCell
                cell?.fakeBuyButton.isEnabled = false
                cell?.fakeSellButton.isEnabled = false
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
    }
}

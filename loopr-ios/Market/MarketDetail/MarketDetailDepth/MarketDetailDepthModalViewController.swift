//
//  MarketDetailDepthModalViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 8/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MarketDetailDepthModalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var market: Market!
    private var buys: [Depth] = []
    private var sells: [Depth] = []

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerInfoLabel: UILabel!
    @IBOutlet weak var headerLastPriceLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.clear // UIColor.black.withAlphaComponent(0.8)

        headerView.theme_backgroundColor = GlobalPicker.backgroundColor
        headerView.round(corners: [.topLeft, .topRight], radius: 12)

        headerInfoLabel.theme_textColor = GlobalPicker.textLightColor
        headerInfoLabel.font = FontConfigManager.shared.getMediumFont(size: 16)
        headerInfoLabel.text = LocalizedString("Latest Price", comment: "")
        
        headerLastPriceLabel.textColor = UIColor.themeGreen
        headerLastPriceLabel.font = FontConfigManager.shared.getRegularFont(size: 13)
        // Fake data
        headerLastPriceLabel.text = "0.18800000LRC  ≈  $0.22"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.theme_backgroundColor = GlobalPicker.backgroundColor

        self.buys = MarketDepthDataManager.shared.getBuys()
        self.sells = MarketDepthDataManager.shared.getSells()
        var maxCount = buys.count > sells.count ? buys.count : sells.count
        if maxCount > 10 {
            maxCount = 10
        }
        tableViewHeight.constant = 41 + MarketDetailDepthTableViewCell.getHeight() * CGFloat(maxCount) + 10
        
        footerView.theme_backgroundColor = GlobalPicker.backgroundColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // TODO: Improve this UI.
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = UIColor.clear
        }
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
        label1.text = LocalizedString("Amount", comment: "")
        label1.textAlignment = .left
        baseViewBuy.addSubview(label1)
        
        let label2 = UILabel(frame: CGRect(x: 10, y: 0, width: labelWidth-20, height: 30))
        label2.theme_textColor = GlobalPicker.textLightColor
        label2.font = FontConfigManager.shared.getMediumFont(size: 14)
        label2.text = LocalizedString("Buy", comment: "")
        label2.textAlignment = .right
        baseViewBuy.addSubview(label2)
        
        let baseViewSell = UIView(frame: CGRect(x: baseViewBuy.frame.maxX+5, y: baseViewBuy.frame.minY, width: baseViewBuy.width, height: baseViewBuy.height))
        baseViewSell.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        baseViewSell.round(corners: [.topRight], radius: 6)
        headerView.addSubview(baseViewSell)
        
        let label3 = UILabel(frame: CGRect(x: 10, y: 0, width: labelWidth, height: 30))
        label3.theme_textColor = GlobalPicker.textLightColor
        label3.font = FontConfigManager.shared.getMediumFont(size: 14)
        label3.text = LocalizedString("Amount", comment: "")
        label3.textAlignment = .left
        baseViewSell.addSubview(label3)
        
        let label4 = UILabel(frame: CGRect(x: 10, y: 0, width: labelWidth-20, height: 30))
        label4.theme_textColor = GlobalPicker.textLightColor
        label4.font = FontConfigManager.shared.getMediumFont(size: 14)
        label4.text = LocalizedString("Sell", comment: "")
        label4.textAlignment = .right
        baseViewSell.addSubview(label4)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let maxCount = buys.count > sells.count ? buys.count : sells.count
        if maxCount > 10 {
            return 10
        } else {
            return maxCount
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            return MarketDetailDepthTableViewCell.getHeight() + 10
        } else {
            return MarketDetailDepthTableViewCell.getHeight()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: MarketDetailDepthTableViewCell.getCellIdentifier()) as? MarketDetailDepthTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("MarketDetailDepthTableViewCell", owner: self, options: nil)
            cell = nib![0] as? MarketDetailDepthTableViewCell
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

    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        dismiss(animated: true) {
            
        }
    }
}

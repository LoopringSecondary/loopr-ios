//
//  SettingCurrencyViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/22.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class SettingCurrencyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var localCurrentCurrency: Currency!
    var currencies: [Currency] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        localCurrentCurrency = SettingDataManager.shared.getCurrentCurrency()
        currencies = SettingDataManager.shared.getSupportedCurrencies()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: .zero)
        
        self.navigationItem.title = LocalizedString("Currency", comment: "")
        setBackButton()
        view.theme_backgroundColor = ColorPicker.backgroundColor
        tableView.theme_backgroundColor = ColorPicker.backgroundColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if localCurrentCurrency != SettingDataManager.shared.getCurrentCurrency() {
            // TODO: config in setting
            LoopringAPIRequest.getTicker(by: .coinmarketcap) { (markets, error) in
                print("receive LoopringAPIRequest.getMarkets")
                guard error == nil else {
                    print("error=\(String(describing: error))")
                    return
                }
                MarketDataManager.shared.setMarkets(newMarkets: markets)
            }
            NotificationCenter.default.post(name: .needRelaunchCurrentAppWallet, object: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SettingCurrencyTableViewCell.getHeight()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: SettingCurrencyTableViewCell.getCellIdentifier()) as? SettingCurrencyTableViewCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("SettingCurrencyTableViewCell", owner: self, options: nil)
            cell = nib![0] as? SettingCurrencyTableViewCell
        }
        cell?.currency = currencies[indexPath.row]
        if SettingDataManager.shared.getCurrentCurrency() == currencies[indexPath.row] {
            cell?.enabledIcon.isHidden = false
        } else {
            cell?.enabledIcon.isHidden = true
        }
        cell?.update()
        
        if indexPath.row == 0 {
            cell?.seperateLineUp.isHidden = false
        } else {
            cell?.seperateLineUp.isHidden = true
        }

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        SettingDataManager.shared.setCurrentCurrency(currencies[indexPath.row])
        tableView.reloadData()
    }
}

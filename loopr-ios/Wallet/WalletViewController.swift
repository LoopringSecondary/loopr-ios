//
//  WalletViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class WalletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WalletBalanceTableViewCellDelegate {

    @IBOutlet weak var assetTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        assetTableView.dataSource = self
        assetTableView.delegate = self
        
        let button =  UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        var buttonTitle = WalletDataManager.shared.getCurrentWallet()?.name
        if buttonTitle == nil {
            buttonTitle = "Wallet"
        }
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.setTitleColor(defaultTintColor, for: .normal)
        button.setTitleColor(UIColor.init(white: 0.8, alpha: 1), for: .highlighted)

        button.addTarget(self, action: #selector(self.clickOnButton(_:)), for: .touchUpInside)
        self.navigationItem.titleView = button
        
        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(self.pressAddButton(_:)))
        // self.navigationItem.rightBarButtonItem = addButton
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func clickOnButton(_ button: UIButton) {
        print("select another wallet.")
        let viewController = SelectWalletViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func pressAddButton(_ button: UIBarButtonItem) {
        let viewController = AddAssetViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + AssetDataManager.shared.getAssets().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return WalletBalanceTableViewCell.getHeight()
        } else {
            return AssetTableViewCell.getHeight()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            var cell = tableView.dequeueReusableCell(withIdentifier: WalletBalanceTableViewCell.getCellIdentifier()) as? WalletBalanceTableViewCell
            if (cell == nil) {
                let nib = Bundle.main.loadNibNamed("WalletBalanceTableViewCell", owner: self, options: nil)
                cell = nib![0] as? WalletBalanceTableViewCell
                cell?.selectionStyle = .none
                cell?.delegate = self
            }
            
            cell?.setup()
            // cell?.totalBalanceLabel.text = "12000"
            return cell!

        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: AssetTableViewCell.getCellIdentifier()) as? AssetTableViewCell
            if (cell == nil) {
                let nib = Bundle.main.loadNibNamed("AssetTableViewCell", owner: self, options: nil)
                cell = nib![0] as? AssetTableViewCell
            }

            cell?.asset = AssetDataManager.shared.getAssets()[indexPath.row-1]
            cell?.update()
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            let assetDetailViewController = AssetDetailViewController();
            let asset = AssetDataManager.shared.getAssets()[indexPath.row-1]
            assetDetailViewController.asset = asset
            assetDetailViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(assetDetailViewController, animated: true)
        }
    }
    
    func navigatToAddAssetViewController() {
        print("navigatToAddAssetViewController")
        let viewController = AddAssetViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}

//
//  WalletViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class WalletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var assetTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        assetTableView.dataSource = self
        assetTableView.delegate = self
        
        let button =  UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        button.setTitle("Wallet", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.setTitleColor(defaultTintColor, for: .normal)
        button.setTitleColor(UIColor.init(white: 0.8, alpha: 1), for: .highlighted)

        button.addTarget(self, action: #selector(self.clickOnButton(_:)), for: .touchUpInside)
        self.navigationItem.titleView = button
        
        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(self.pressAddButton(_:)))
        self.navigationItem.rightBarButtonItem = addButton
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
        return AssetDataManager.shared.getAssets().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AssetTableViewCell.getHeight()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "AssetCellIdentifier"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AssetTableViewCell
        if (cell == nil) {
            let nib = Bundle.main.loadNibNamed("AssetTableViewCell", owner: self, options: nil)
            cell = nib![0] as? AssetTableViewCell
        }
        
        // Configure the cell...
        cell?.asset = AssetDataManager.shared.getAssets()[indexPath.row]
        cell?.update()
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let assetDetailViewController = AssetDetailViewController();
        let asset = AssetDataManager.shared.getAssets()[indexPath.row]
        assetDetailViewController.asset = asset
        assetDetailViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(assetDetailViewController, animated: true)
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

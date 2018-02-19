//
//  AssetDetailViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AssetDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var asset: Asset? = nil
    
    @IBOutlet weak var tableView: UITableView!

    // TODO: is Transaction the same as Order?
    var orders: [Order] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        
        tableView.dataSource = self
        tableView.delegate = self
    }

    func setupNavigationBar() {
        self.title = asset?.symbol
        
        // For back button in navigation bar
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        // We need to reduce the spacing between two UIBarButtonItems
        let sendButton = UIButton(type: UIButtonType.custom)
        sendButton.setImage(UIImage.init(named: "Send"), for: UIControlState.normal)
        sendButton.setImage(UIImage.init(named: "Send-highlight"), for: UIControlState.highlighted)
        sendButton.addTarget(self, action: #selector(self.pressSendButton(_:)), for: UIControlEvents.touchUpInside)
        sendButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let sendBarButton = UIBarButtonItem(customView: sendButton)
        
        let qrCodebutton = UIButton(type: UIButtonType.custom)
        qrCodebutton.setImage(UIImage.init(named: "QRCode"), for: UIControlState.normal)
        
        // TODO: add a QRCode-highlight icon
        
        qrCodebutton.addTarget(self, action: #selector(self.pressSendButton(_:)), for: UIControlEvents.touchUpInside)
        qrCodebutton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let qrCodeBarButton = UIBarButtonItem(customView: qrCodebutton)
        
        self.navigationItem.rightBarButtonItems = [sendBarButton, qrCodeBarButton]
    }

    // Not going to use a singleton pattern to store asset data.
    func getDataFromServer() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func pressQRCodeButton(_ button: UIBarButtonItem) {
        print("pressQRCodeButton")
    }
    
    @objc func pressSendButton(_ button: UIBarButtonItem) {
        print("pressSendButton")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return AssetBalanceTableViewCell.getHeight()
        } else {
            return AssetTransactionTableViewCell.getHeight()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            var cell = tableView.dequeueReusableCell(withIdentifier: AssetBalanceTableViewCell.getCellIdentifier()) as? AssetBalanceTableViewCell
            if (cell == nil) {
                let nib = Bundle.main.loadNibNamed("AssetBalanceTableViewCell", owner: self, options: nil)
                cell = nib![0] as? AssetBalanceTableViewCell
                cell?.selectionStyle = .none
            }
            
            cell?.balanceLabel.text = asset?.balance.description
            
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: AssetTransactionTableViewCell.getCellIdentifier()) as? AssetTransactionTableViewCell
            if (cell == nil) {
                let nib = Bundle.main.loadNibNamed("AssetTransactionTableViewCell", owner: self, options: nil)
                cell = nib![0] as? AssetTransactionTableViewCell
                cell?.selectionStyle = .none
            }
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

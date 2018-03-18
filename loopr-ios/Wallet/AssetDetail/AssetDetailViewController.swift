//
//  AssetDetailViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AssetDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var asset: Asset?
    var transactions: [Transaction] = []

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var receiveButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        tableView.theme_backgroundColor = GlobalPicker.backgroundColor
        setupNavigationBar()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        // Receive button
        receiveButton.setTitle(NSLocalizedString("Receive", comment: ""), for: .normal)
        receiveButton.theme_backgroundColor = ["#000", "#fff"]
        receiveButton.theme_setTitleColor(["#fff", "#000"], forState: .normal)
        
        receiveButton.backgroundColor = UIColor.clear
        receiveButton.titleColor = UIColor.black
        receiveButton.layer.cornerRadius = 23
        receiveButton.layer.borderWidth = 0.5
        receiveButton.layer.borderColor = UIColor.black.cgColor
        receiveButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        
        // Send button
        sendButton.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
        sendButton.theme_backgroundColor = ["#000", "#fff"]
        sendButton.theme_setTitleColor(["#fff", "#000"], forState: .normal)
        
        sendButton.backgroundColor = UIColor.black
        sendButton.layer.cornerRadius = 23
        sendButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
    }

    func setupNavigationBar() {
        self.title = asset?.name
        
        // For back button in navigation bar
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        // TODO: Remove the button.
        // We need to reduce the spacing between two UIBarButtonItems
        let sendButton = UIButton(type: UIButtonType.custom)
        sendButton.setImage(UIImage.init(named: "Send"), for: UIControlState.normal)
        sendButton.setImage(UIImage.init(named: "Send-highlight"), for: UIControlState.highlighted)
        // sendButton.addTarget(self, action: #selector(self.pressSendButton(_:)), for: UIControlEvents.touchUpInside)
        sendButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let sendBarButton = UIBarButtonItem(customView: sendButton)
        
        let qrCodebutton = UIButton(type: UIButtonType.custom)
        qrCodebutton.theme_setImage(["QRCode-black", "QRCode-white"], forState: UIControlState.normal)
        qrCodebutton.setImage(UIImage(named: "QRCode-black")?.alpha(0.3), for: .highlighted)

        qrCodebutton.addTarget(self, action: #selector(self.pressQRCodeButton(_:)), for: UIControlEvents.touchUpInside)
        qrCodebutton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let qrCodeBarButton = UIBarButtonItem(customView: qrCodebutton)
        
        self.navigationItem.rightBarButtonItems = [sendBarButton, qrCodeBarButton]
    }

    // Not going to use a singleton pattern to store asset data.
    func getDataFromServer() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func pressQRCodeButton(_ button: UIBarButtonItem) {
        print("pressQRCodeButton")
        let viewController = QRCodeViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    /*
    @objc func pressSendButton(_ button: UIBarButtonItem) {
        print("pressSendButton")
    }
    */
    
    @IBAction func pressedSendButton(_ sender: Any) {
        print("pressedSendButton")
        let viewController = SendAssetViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func pressedReceiveButton(_ sender: Any) {
        print("pressedReceiveButton")
        
        // TODO: the design doesn't have the receive page.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + AssetDataManager.shared.getTransactions().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return AssetBalanceTableViewCell.getHeight()
        } else {
            return AssetTransactionTableViewCell.getHeight()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: AssetBalanceTableViewCell.getCellIdentifier()) as? AssetBalanceTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("AssetBalanceTableViewCell", owner: self, options: nil)
                cell = nib![0] as? AssetBalanceTableViewCell
                cell?.selectionStyle = .none
            }
            cell?.balanceLabel.text = asset?.balance.description
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: AssetTransactionTableViewCell.getCellIdentifier()) as? AssetTransactionTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("AssetTransactionTableViewCell", owner: self, options: nil)
                cell = nib![0] as? AssetTransactionTableViewCell
                cell?.accessoryType = .disclosureIndicator
            }
            cell?.transaction = AssetDataManager.shared.getTransactions()[indexPath.row - 1]
            cell?.update()
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            let transaction = AssetDataManager.shared.getTransactions()[indexPath.row - 1]
            let vc = AssetTransactionDetailViewController()
            vc.transaction = transaction
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

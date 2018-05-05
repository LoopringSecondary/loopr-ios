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
        setup()
        // Do any additional setup after loading the view.
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        tableView.theme_backgroundColor = GlobalPicker.backgroundColor
        setupNavigationBar()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        
        // Receive button
        receiveButton.setTitle(NSLocalizedString("Receive", comment: ""), for: .normal)
        receiveButton.setupRoundBlack()
        
        // Send button
        sendButton.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
        sendButton.setupRoundWhite()
    }
    
    func setup() {
        // TODO: putting getMarketsFromServer() here may cause a race condition.
        // It's not perfect, but works. Need improvement in the future.
        self.transactions = CurrentAppWalletDataManager.shared.getTransactions()
        if let asset = asset {
            
            // TODO: pass the address
            CurrentAppWalletDataManager.shared.getTransactionsFromServer(asset: asset) { (transactions, error) in
                guard error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    self.transactions = transactions
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func setupNavigationBar() {
        self.navigationItem.title = asset?.name.capitalized ?? ""

        // For back button in navigation bar
        setBackButton()
        
        // TODO: Remove the button.
        /*
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
         */

        if let asset = asset, asset.symbol.uppercased() == "ETH" || asset.symbol.uppercased() == "WETH" {
            let convertButton = UIButton()
            convertButton.setTitle("   Convert   ", for: .normal)
            convertButton.setTitleColor(UIColor.black, for: .normal)
            convertButton.setTitleColor(UIColor.init(white: 0, alpha: 0.3), for: .highlighted)
            convertButton.titleLabel?.font = FontConfigManager.shared.getButtonTitleLabelFont(size: 13)
            convertButton.addTarget(self, action: #selector(self.pressedConvertButton(_:)), for: UIControlEvents.touchUpInside)
            
            convertButton.backgroundColor = UIColor.clear
            convertButton.layer.cornerRadius = 14
            convertButton.layer.borderWidth = 0.5
            convertButton.layer.borderColor = UIColor.black.cgColor
            
            let convertBarButtton = UIBarButtonItem(customView: convertButton)
            self.navigationItem.rightBarButtonItem = convertBarButtton
        }
    }

    @objc func pressedConvertButton(_ sender: Any) {
        print("pressedConvertButton")
        let viewController = ConvertETHViewController()
        viewController.asset = asset
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func pressedSendButton(_ sender: Any) {
        print("pressedSendButton")
        let viewController = SendAssetViewController()
        viewController.asset = self.asset!
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func pressedReceiveButton(_ sender: Any) {
        print("pressedReceiveButton")
        let viewController = QRCodeViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return self.transactions.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return AssetBalanceTableViewCell.getHeight()
        } else {
            return AssetTransactionTableViewCell.getHeight()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return AssetBalanceTableViewCell.getHeight()
        } else {
            return AssetTransactionTableViewCell.getHeight()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: AssetBalanceTableViewCell.getCellIdentifier()) as? AssetBalanceTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("AssetBalanceTableViewCell", owner: self, options: nil)
                cell = nib![0] as? AssetBalanceTableViewCell
                cell?.selectionStyle = .none
            }
            cell?.asset = asset
            cell?.update()
            cell?.marketButton.addTarget(self, action: #selector(goToMarket), for: .touchUpInside)
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: AssetTransactionTableViewCell.getCellIdentifier()) as? AssetTransactionTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("AssetTransactionTableViewCell", owner: self, options: nil)
                cell = nib![0] as? AssetTransactionTableViewCell
            }
            cell?.transaction = self.transactions[indexPath.row]
            cell?.update()
            return cell!
        }
    }

    @objc func goToMarket(_ sender: AnyObject) {
        if let asset = self.asset {
            if asset.symbol.lowercased() == "eth" || asset.symbol.lowercased() == "weth" {
                let viewController = ConvertETHViewController()
                viewController.asset = asset
                self.navigationController?.pushViewController(viewController, animated: true)
            } else {
                PlaceOrderDataManager.shared.new(tokenA: asset.symbol, tokenB: "WETH")
                let viewController = BuyAndSellSwipeViewController()
                viewController.initialType = .buy
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section >= 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            let transaction = self.transactions[indexPath.row]
            let vc = AssetTransactionDetailViewController()
            vc.transaction = transaction
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

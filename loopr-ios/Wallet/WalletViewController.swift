//
//  WalletViewController.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class WalletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WalletBalanceTableViewCellDelegate, ContextMenuDelegate, QRCodeScanProtocol {

    @IBOutlet weak var assetTableView: UITableView!
    private let refreshControl = UIRefreshControl()

    var isLaunching: Bool = true
    var isReordering: Bool = false
    var isListeningSocketIO: Bool = false
    var contextMenuSourceView: UIView = UIView()
    var numberOfRowsInSection1: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        assetTableView.dataSource = self
        assetTableView.delegate = self
//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 10))
//        headerView.theme_backgroundColor = GlobalPicker.backgroundColor
//
//        assetTableView.tableHeaderView = headerView
//        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 10))
//        footerView.theme_backgroundColor = GlobalPicker.backgroundColor
//        assetTableView.tableFooterView = footerView
        assetTableView.separatorStyle = .none
        
        // Avoid dragging a cell to the top makes the tableview shake
        assetTableView.estimatedRowHeight = 0
        assetTableView.estimatedSectionHeaderHeight = 0
        assetTableView.estimatedSectionFooterHeight = 0

        assetTableView.theme_backgroundColor = GlobalPicker.backgroundColor

        /*
        let qrCodebutton = UIButton(type: UIButtonType.custom)

        // TODO: smaller images.
        qrCodebutton.theme_setImage(["QRCode-black", "QRCode-white"], forState: UIControlState.normal)
        qrCodebutton.setImage(UIImage(named: "QRCode-black")?.alpha(0.3), for: .highlighted)
        qrCodebutton.addTarget(self, action: #selector(self.pressQRCodeButton(_:)), for: UIControlEvents.touchUpInside)
        qrCodebutton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let qrCodeBarButton = UIBarButtonItem(customView: qrCodebutton)
        self.navigationItem.leftBarButtonItem = qrCodeBarButton
        */

        let addBarButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(self.pressAddButton(_:)))
        self.navigationItem.rightBarButtonItem = addBarButton
        
        // Add Refresh Control to Table View
        assetTableView.refreshControl = refreshControl
        refreshControl.theme_tintColor = GlobalPicker.textColor
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        // Creating view for extending background color
        var frame = assetTableView.bounds
        frame.origin.y = -frame.size.height
        let backgroundView = UIView(frame: frame)
        backgroundView.autoresizingMask = .flexibleWidth
        backgroundView.theme_backgroundColor = GlobalPicker.backgroundColor
        
        // Adding the view below the refresh control
        assetTableView.insertSubview(backgroundView, at: 0)
    }
    
    @objc private func refreshData(_ sender: Any) {
        // Fetch Data
        getBalanceFromRelay()
    }
    
    func getBalanceFromRelay() {
        guard CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil else {
            return
        }

        CurrentAppWalletDataManager.shared.getBalanceAndPriceQuote(address: CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address, completionHandler: { _, error in
            print("receive CurrentAppWalletDataManager.shared.getBalanceAndPriceQuote() in WalletViewController")
            guard error == nil else {
                print("error=\(String(describing: error))")
                let banner = NotificationBanner.generate(title: "Sorry. Network error", style: .info)
                banner.duration = 2.0
                banner.show()
                self.refreshControl.endRefreshing()
                return
            }
            DispatchQueue.main.async {
                if self.isLaunching {
                    self.isLaunching = false
                }
                self.assetTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getBalanceFromRelay()
        SendCurrentAppWalletDataManager.shared.getNonceFromEthereum()
        if let cell = assetTableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? WalletBalanceTableViewCell {
            cell.startUpdateBalanceLabelTimer()
        }
        self.navigationItem.title = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.name ?? LocalizedString("Wallet", comment: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isListeningSocketIO = true
        CurrentAppWalletDataManager.shared.startGetBalance()
        // Add observer.
        NotificationCenter.default.addObserver(self, selector: #selector(balanceResponseReceivedNotification), name: .balanceResponseReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(priceQuoteResponseReceivedNotification), name: .priceQuoteResponseReceived, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil else {
            return
        }

        CurrentAppWalletDataManager.shared.stopGetBalance()
        isListeningSocketIO = false
        NotificationCenter.default.removeObserver(self, name: .balanceResponseReceived, object: nil)
        NotificationCenter.default.removeObserver(self, name: .priceQuoteResponseReceived, object: nil)
        
        if let cell = assetTableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? WalletBalanceTableViewCell {
            cell.stopUpdateBalanceLabelTimer()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setResultOfScanningQRCode(valueSent: String, type: QRCodeType) {
        if type == .submitOrder {
            AuthorizeDataManager.shared.getSubmitOrder { (_, error) in
                guard error == nil, let order = AuthorizeDataManager.shared.submitOrder else { return }
                DispatchQueue.main.async {
                    let vc = PlaceOrderConfirmationViewController()
                    vc.order = order
                    vc.isSigning = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else if type == .login {
            AuthorizeDataManager.shared._authorizeLogin { (_, error) in
                let result = error == nil ? true : false
                DispatchQueue.main.async {
                    let vc = LoginResultViewController()
                    vc.result = result
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else if type == .cancelOrder {
            AuthorizeDataManager.shared.getCancelOrder { (_, error) in
                let result = error == nil ? true : false
                DispatchQueue.main.async {
                    let vc = LoginResultViewController()
                    vc.result = result
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else if type == .convert {
            AuthorizeDataManager.shared.getConvertTx { (_, error) in
                let result = error == nil ? true : false
                DispatchQueue.main.async {
                    let vc = LoginResultViewController()
                    vc.result = result
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else if type == .p2pOrder {
            let vc = TradeConfirmationViewController()
            vc.order = TradeDataManager.shared.orders[1]
            self.navigationController?.pushViewController(vc, animated: true)
        } else if type == .address {
            let vc = SendAssetViewController()
            vc.address = valueSent
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func clickNavigationTitleButton(_ button: UIButton) {
        print("select another wallet.")
        let viewController = SelectWalletViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func pressQRCodeButton(_ button: UIBarButtonItem) {
        print("pressQRCodeButton")
        if CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil {
            let viewController = QRCodeViewController()
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @objc func pressAddButton(_ button: UIBarButtonItem) {
        contextMenuSourceView.frame = CGRect(x: self.view.frame.width, y: -5, width: 1, height: 1)
        view.addSubview(contextMenuSourceView)
        
        let icons = [UIImage(named: "Scan-white")!, UIImage(named: "Add-token")!]
        let titles = [LocalizedString("Scan QR Code", comment: ""), LocalizedString("Add Token", comment: "")]
        let menuViewController = AddMenuViewController(rows: 2, titles: titles, icons: icons)
        menuViewController.didSelectRowClosure = { (index) -> Void in
            if index == 0 {
                print("Selected Scan QR code")
                let viewController = ScanQRCodeViewController()
                viewController.delegate = self
                viewController.shouldPop = false
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            } else if index == 1 {
                print("Selected Add Token")
                let viewController = AddTokenViewController()
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        ContextMenu.shared.show(
            sourceViewController: self,
            viewController: menuViewController,
            options: ContextMenu.Options(containerStyle: ContextMenu.ContainerStyle(backgroundColor: UIColor.black), menuStyle: .minimal),
            sourceView: contextMenuSourceView,
            delegate: self
        )
    }
    
    func contextMenuWillDismiss(viewController: UIViewController, animated: Bool) {
        print("will dismiss")
    }
    
    func contextMenuDidDismiss(viewController: UIViewController, animated: Bool) {
        print("did dismiss")
        contextMenuSourceView.removeFromSuperview()
    }
    
    @objc func balanceResponseReceivedNotification() {
        if !isReordering && !isLaunching && isListeningSocketIO {
            print("balanceResponseReceivedNotification WalletViewController reload table")
            // assetTableView.reloadData()
            self.assetTableView.reloadSections(IndexSet(integersIn: 1...1), with: .none)
        }
    }
    
    @objc func priceQuoteResponseReceivedNotification() {
        if !isReordering && !isLaunching {
            print("priceQuoteResponseReceivedNotification WalletViewController reload table")
            // assetTableView.reloadData()
            self.assetTableView.reloadSections(IndexSet(integersIn: 1...1), with: .none)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging")
        CurrentAppWalletDataManager.shared.stopGetBalance()
        isListeningSocketIO = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        isListeningSocketIO = true
        CurrentAppWalletDataManager.shared.startGetBalance()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if isLaunching {
            return 2
        }
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            numberOfRowsInSection1 = CurrentAppWalletDataManager.shared.getAssetsWithHideSmallAssetsOption().count
            return numberOfRowsInSection1
        default:
            return  0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return WalletBalanceTableViewCell.getHeight()
        } else if indexPath.section == 1 {
            return WalletButtonTableViewCell.getHeight()
        } else {
            return AssetTableViewCell.getHeight()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: WalletBalanceTableViewCell.getCellIdentifier()) as? WalletBalanceTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("WalletBalanceTableViewCell", owner: self, options: nil)
                cell = nib![0] as? WalletBalanceTableViewCell
                cell?.delegate = self
            }
            cell?.setup()
            if isLaunching {
                cell?.balanceLabel.setText("", animated: false)
            }
            return cell!
        } else if indexPath.section == 1 {
            var cell = tableView.dequeueReusableCell(withIdentifier: WalletButtonTableViewCell.getCellIdentifier()) as? WalletButtonTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("WalletButtonTableViewCell", owner: self, options: nil)
                cell = nib![0] as? WalletButtonTableViewCell
                cell?.delegate = self
            }
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: AssetTableViewCell.getCellIdentifier()) as? AssetTableViewCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("AssetTableViewCell", owner: self, options: nil)
                cell = nib![0] as? AssetTableViewCell
            }
            cell?.asset = CurrentAppWalletDataManager.shared.getAssetsWithHideSmallAssetsOption()[indexPath.row]
            cell?.update()
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
        
        } else if indexPath.section == 1 {
        
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            let asset = CurrentAppWalletDataManager.shared.getAssetsWithHideSmallAssetsOption()[indexPath.row]
            let viewController = AssetSwipeViewController()
            viewController.asset = asset
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    func updateTableView(isHideSmallAsset: Bool) {
        if !isLaunching {
            if isHideSmallAsset {
                var rows: [IndexPath] = []
                let lastRow = CurrentAppWalletDataManager.shared.getAssetsWithHideSmallAssetsOption().count
                for i in lastRow..<numberOfRowsInSection1 {
                    rows.append(IndexPath.init(row: i, section: 1))
                }
                self.assetTableView.deleteRows(at: rows, with: .top)
            } else {
                var rows: [IndexPath] = []
                let lastRow = CurrentAppWalletDataManager.shared.getAssetsWithHideSmallAssetsOption().count
                for i in numberOfRowsInSection1..<lastRow {
                    rows.append(IndexPath.init(row: i, section: 1))
                }
                self.assetTableView.insertRows(at: rows, with: .top)
            }
        }
    }
    
}

extension WalletViewController: WalletButtonTableViewCellDelegate {

    func navigationToScanViewController() {
        let viewController = ScanQRCodeViewController()
        viewController.delegate = self
        viewController.shouldPop = false
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func navigationToReceiveViewController() {
        if CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil {
            let viewController = QRCodeViewController()
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func navigationToSendViewController() {
        
    }
    
    func navigationToTradeViewController() {
        
    }

}
